//
//  AppURLCache.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 01/09/14.
//  Copyright (c) 2014 Mobideck. All rights reserved.
//

#import "AppDeck.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"

#import "AppURLCache.h"
#import "RE2Regexp.h"

#include "NSString+URLEncoding.h"
#include "NSString+MD5.h"

#import "LogViewController.h"

#include <sys/stat.h>
#include <stdio.h>
#include <unistd.h>

#include "AdBlock.h"

@interface AppURLCachedData : NSObject <NSCoding>
    @property (nonatomic, readwrite, strong) NSData *data;
    @property (nonatomic, readwrite, strong) NSURLResponse *response;
@end

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";

// 1x1 transparent GIF
//static unsigned char gifData[] = {
//    0x47, 0x49, 0x46, 0x38, 0x39, 0x61,
//    0x01, 0x00, 0x01, 0x00, 0x80, 0xff,
//    0x00, 0xff, 0xff, 0xff, 0x00, 0x00,
//    0x00, 0x2c, 0x00, 0x00, 0x00, 0x00,
//    0x01, 0x00, 0x01, 0x00, 0x00, 0x02,
//    0x02, 0x44, 0x01, 0x00, 0x3b
//};

@implementation AppURLCachedData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self data] forKey:kDataKey];
    [aCoder encodeObject:[self response] forKey:kResponseKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        [self setData:[aDecoder decodeObjectForKey:kDataKey]];
        [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];
    }
    
    return self;
}

@end

@implementation AppURLCache


- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path
{
    self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path];
    if (self)
    {
        backgroundQueue = dispatch_queue_create("com.mobideck.cache.bgqueue", NULL);
        memcache = [[NSCache alloc] init];
        cacheRegex = [[NSMutableArray alloc] initWithCapacity:256];
        fileManager = [NSFileManager defaultManager];
        [self checkBeacon];
        [self performSelectorInBackground:@selector(cleanup) withObject:nil];
        // init CDN host list
        cdnregexp = [[RE2Regexp alloc] initWithString:@"(.appdeckcdn.com|appdata.static.appdeck.mobi|static.appdeck.mobi|ajax.googleapis.com|cachedcommons.org|cdnjs.cloudflare.com|code.jquery.com|ajax.aspnetcdn.com|ajax.microsoft.com|ads.mobcdn.com|.akamai.net|.akamaiedge.net|.llnwd.net|edgecastcdn.net|.systemcdn.net|hwcdn.net|.panthercdn.com|.simplecdn.net|.instacontent.net|.footprint.net|.ay1.b.yahoo.com|.yimg.|.google.|googlesyndication.|youtube.|.googleusercontent.com|.internapcdn.net|.cloudfront.net|.netdna-cdn.com|.netdna-ssl.com|.netdna.com|.cotcdn.net|.cachefly.net|bo.lt|.cloudflare.com|.afxcdn.net|.lxdns.com|.att-dsa.net|.vo.msecnd.net|.voxcdn.net|.bluehatnetwork.com|.swiftcdn1.com|.cdngc.net|.fastly.net|.nocookie.net|.gslb.taobao.com|.gslb.tbcache.com|.mirror-image.net|.cubecdn.net|.yottaa.net|.r.cdn77.net|.incapdns.net|.bitgravity.com|.r.worldcdn.net|.r.worldssl.net|tbcdn.cn|.taobaocdn.com|.ngenix.net|.pagerain.net|.ccgslb.com|cdn.sfr.net|.azioncdn.net|.azioncdn.com|.azion.net|.cdncloud.net.au|cdn.viglink.com|.ytimg.com|.dmcdn.net|.googleapis.com|.googleusercontent.com|code.jquery.com|media.mobpartner.mobi|gstatic.com|ytimg.com|[0-9].gravatar.com|.wp.com|.bootstrapcdn.com|.msecnd.net)"];

        // create cache directory if needed
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePathAndDirectory = [cachePath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
        NSError *error;

        if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
    return self;
}

- (NSUInteger)memoryCapacity
{
    return [super memoryCapacity];
}

- (void)removeAllCachedResponses
{
    [super removeAllCachedResponses];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    [memcache removeObjectForKey:request.URL.absoluteString];
    NSString *fullPath = [self getCachePathForRequest:request];
    NSError *error = nil;
    [fileManager removeItemAtPath:fullPath error:&error];
    [fileManager removeItemAtPath:[fullPath stringByAppendingString:@".meta"] error:&error];
    [super removeCachedResponseForRequest:request];
}

- (void)setDiskCapacity:(NSUInteger)diskCapacity
{
    [super setDiskCapacity:diskCapacity];
}

- (void)setMemoryCapacity:(NSUInteger)memoryCapacity
{
    [super setMemoryCapacity:memoryCapacity];
}

#pragma mark - cache cleanup

-(void)cleanup
{
    // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cachesPath error:&error];
    
    NSMutableArray  *filesPathArray = [[NSMutableArray alloc] initWithCapacity:files.count];
    
    long long totalSize = 0;
    long long maxSize = 100 * 1024 * 1024; // max cache size: 100 MO ?
    
    for (NSString *file in files)
    {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", cachesPath, file];
        struct stat st;
        int ret = stat([fullPath UTF8String], &st);
        if (ret == 0)
        {
            totalSize += st.st_size;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:st.st_atimespec.tv_sec];
            [filesPathArray addObject:[NSArray arrayWithObjects:fullPath, date, [NSNumber numberWithLongLong:st.st_size], nil]];
        }
    }
    
    NSArray *sortedArray = [filesPathArray sortedArrayUsingComparator: ^(id file1, id file2) {

        NSDate *date1 = [((NSArray *)file1) objectAtIndex:1];
        NSDate *date2 = [((NSArray *)file2) objectAtIndex:1];
        
        return [date1 compare:date2];
    }];
    
    for (NSArray *file in sortedArray)
    {
        NSString    *path = [file objectAtIndex:0];
        NSDate      *date = [file objectAtIndex:1];
        NSNumber    *size = [file objectAtIndex:2];
        
        if (totalSize > maxSize)
        {
            NSLog(@"cache clean %@: %@", path, date);
            [fileManager removeItemAtPath:path error:&error];
            totalSize -= size.longLongValue;
        } else {
//            NSLog(@"NOT DELETE %@: %@", path, date);
        }
   }
    
}

-(void)cleanall
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cachesPath error:&error];
    
    for (NSString *file in files)
    {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", cachesPath, file];
        [fileManager removeItemAtPath:fullPath error:&error];
    }
    [memcache removeAllObjects];
    [super removeAllCachedResponses];
}

- (void)didReceiveMemoryWarning
{
    [memcache removeAllObjects];
}

#pragma mark - API

-(void)addCacheRegularExpressionFromString:(NSString *)regexString
{
    RE2Regexp *regex = [[RE2Regexp alloc] initWithString:regexString];
    [cacheRegex addObject:regex];    
}

-(void)removeAllRegularExpression
{
    [cacheRegex removeAllObjects];
}

-(BOOL)requestIsInCache:(NSURLRequest *)request date:(NSDate **)date
{
    NSString *cachePath = [self getCachePathForRequest:request];
    const char *path = [cachePath cStringUsingEncoding:NSUTF8StringEncoding];
    struct stat statbuf;
    if (stat(path, &statbuf) == -1)
    {
        return NO;
    }
    *date = [NSDate dateWithTimeIntervalSince1970:statbuf.st_mtime];
    return YES;
}

-(BOOL)requestIsInEmbedCache:(NSURLRequest *)request
{
    NSString *file = [self getCachePathForEmbedResource:request];
    if (file == nil)
        return NO;
    if ([fileManager fileExistsAtPath:file])
        return YES;
    return NO;
}

#pragma mark - beacon

-(void)checkBeacon
{
    NSString *beacon_resource_path = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:@"/embedresource/beacon"];
    NSString *beacon_resource = [NSString stringWithContentsOfFile:beacon_resource_path encoding:NSUTF8StringEncoding error:nil];
    
    NSString *beacon_cache_path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/beacon"];
    NSString *beacon_cache = [NSString stringWithContentsOfFile:beacon_cache_path encoding:NSUTF8StringEncoding error:nil];

    if (beacon_resource == nil)
        return;
    if (beacon_resource != nil && beacon_cache != nil && [beacon_resource isEqualToString:beacon_cache])
        return;
    [self cleanall];
    [beacon_resource writeToFile:beacon_cache_path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - internal

-(NSString *)getCachePathForEmbedResource:(NSURLRequest *)request
{
    NSString *file = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    if (file == nil)
        return nil;
    file = [file urlEncodeUsingEncoding:NSUTF8StringEncoding];
    if (file == nil)
        return nil;
    if ([file length] > 48)
        file = [[file substringToIndex:48] stringByAppendingFormat:@"_%@", [file MD5Hash]];
    if (file == nil)
        return nil;
    file = [@"/embedresource/" stringByAppendingString:file];
    file = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:file];
    return file;
}

-(NSString *)getCachePathForRequest:(NSURLRequest *)request
{
    static NSString *cachesPath = nil;
    // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
    if (cachesPath == nil)
        cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [request.URL.absoluteString urlEncodeUsingEncoding:NSUTF8StringEncoding];
    if (fileName.length > 64)
        fileName = [NSString stringWithFormat:@"%@-%@", [fileName substringToIndex:64], [fileName MD5Hash]];
    return [cachesPath stringByAppendingPathComponent:fileName];
}

-(NSCachedURLResponse *)getCacheResponseForRequest:(NSURLRequest *)request
{
    if (memcache == nil || request == nil || request.URL == nil || request.URL.absoluteString == nil)
        return nil;
    
    NSString *absoluteURL = request.URL.absoluteString;
    
    // in memcache ?
    NSCachedURLResponse *cachedResponse = [memcache objectForKey:absoluteURL];
    if (cachedResponse != nil) {
        NSLog(@"getCacheResponseForRequest: MemCache: %@", absoluteURL);
        return cachedResponse;
    }
    
    NSString *bodyFilePath = nil;
    NSString *headersFilePath = nil;
    
    // in disk cache ?
    NSString *cacheFilePath = [self getCachePathForRequest:request];

    if ([fileManager fileExistsAtPath:[cacheFilePath stringByAppendingString:@".body"]])
    {
        bodyFilePath = [cacheFilePath stringByAppendingString:@".body"];
        headersFilePath = [cacheFilePath stringByAppendingString:@".meta"];
    }
    
    /*AppURLCachedData *cachedData = [NSKeyedUnarchiver unarchiveObjectWithFile:cacheFilePath];
    if (cachedData != nil)
    {
        NSLog(@"getCacheResponseForRequest: DiskCache: %@", request.URL.absoluteString);
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:cachedData.response.MIMEType expectedContentLength:cachedData.data.length textEncodingName:cachedData.response.textEncodingName];
        
        cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:cachedData.data];
        return cachedResponse;
    }*/
    // in resource cache ?
    NSString *file = [self getCachePathForEmbedResource:request];
    if (bodyFilePath == nil && [fileManager fileExistsAtPath:file])
    {
        bodyFilePath = file;
        headersFilePath = [file stringByAppendingString:@".meta"];
    }
    
    if (bodyFilePath != nil)
    {
        NSData *bodyData = [NSData dataWithContentsOfFile:bodyFilePath];

        if (bodyData == nil)
            return nil;
        
        NSData *metaData = [NSData dataWithContentsOfFile:headersFilePath];
        
        NSError *error = NULL;
        
        NSMutableDictionary *headersTMP = [NSJSONSerialization JSONObjectWithData:metaData options:NSJSONReadingMutableContainers error:&error];
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithCapacity:[headersTMP count]];
        
        __block NSString *contentType = nil;
        
        [headersTMP enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([[obj class] isSubclassOfClass:[NSString class]])
            {
                [headers setObject:obj forKey:key];
                if ([[key lowercaseString] isEqualToString:@"content-type"])
                    contentType = obj;
            }
            else if ([[obj class] isSubclassOfClass:[NSArray class]])
            {
                NSArray *values = (NSArray *)obj;
                NSString *value = [values componentsJoinedByString:@", "];
                [headers setObject:value forKey:key];
                if ([[key lowercaseString] isEqualToString:@"content-type"])
                    contentType = value;
            } else
                NSLog(@"EmbedHeaders: failed to convert: %@ for key %@", obj, key);
            
        }];
        if (headers == nil || headers.count == 0 || contentType == nil)
        {
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"application/octet-stream" expectedContentLength:bodyData.length textEncodingName:nil];
            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:bodyData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
            NSLog(@"getCacheResponseForRequest: Embed with bad headers: %@", request.URL.absoluteString);
            return cachedResponse;
        }

        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:contentType expectedContentLength:bodyData.length textEncodingName:nil];
        
        cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:bodyData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
        NSLog(@"getCacheResponseForRequest: Embed: %@", absoluteURL);
        return cachedResponse;
    }
    return nil;
}

-(void)storeToDiskCacheResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    if (request.URL == nil)
        return;
    if ([self requestIsInEmbedCache:request])
        return;
    NSURLResponse   *response = cachedResponse.response;
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        long status = [httpResponse statusCode];
        //NSLog(@"HTTP status code is : %d", status);
        if (status != 200)
        {
            NSLog(@"Not add to cache disk %@ : status code is %ld", request.URL.absoluteString, status);
            return;
        }
        
        // check scheme
        if ([request.URL.scheme isEqualToString:@"http"] == NO && [request.URL.scheme isEqualToString:@"https"] == NO)
            return;
        
/*        // already embed ?
        NSString *file = [self getCachePathForEmbedResource:request];
        if (file != nil)
            return;*/
    }
    NSString *cachePath = [self getCachePathForRequest:request];
    NSError *error;
    [NSFileManager.defaultManager removeItemAtPath:cachePath error:&error];
    AppURLCachedData *cachedData = [[AppURLCachedData alloc] init];
    cachedData.response = cachedResponse.response;
    cachedData.data = cachedResponse.data;
    BOOL ret = [NSKeyedArchiver archiveRootObject:cachedData toFile:cachePath];
    if (ret == NO)
    {
        NSLog(@"failed to write new disk cache file for %@: %@", request, cachePath);
    }
}

-(void)setCacheResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    [self storeToDiskCacheResponse:cachedResponse forRequest:request];
    // update memcache ?
//    if ([memcache objectForKey:request.URL.absoluteString] != nil)
    if (cachedResponse && request)
        [memcache setObject:cachedResponse forKey:request.URL.absoluteString];
}

-(BOOL)hostIsCDN:(NSString *)host
{
    if ([cdnregexp match:host.UTF8String])
        return YES;
    //NSLog(@"Host: %@ is not a CDN", host);
    return NO;
}

-(BOOL)shouldStoreRequest:(NSURLRequest *)request
{
    return [self shouldCacheRequest:request];
}

-(BOOL)shouldCacheRequest:(NSURLRequest *)request
{
/*    if (request.cachePolicy == NSURLRequestReloadIgnoringLocalAndRemoteCacheData ||
        request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData)
        return NO;*/
    
    // check scheme
    if ([request.URL.scheme isEqualToString:@"http"] == NO && [request.URL.scheme isEqualToString:@"https"] == NO)
        return NO;
    
    // cache is only for GET request
    if ([[request HTTPMethod] isEqualToString:@"GET"] == NO)
        return NO;
    
    // CDN ?
    if ([self hostIsCDN:request.URL.host])
        return YES;
    
    NSArray *cacheRegexTmp = [cacheRegex copy];
    
    // check regexp
    const char *absoluteURL = [request.URL.absoluteString UTF8String];
    for (RE2Regexp *regex in cacheRegexTmp) {
        if ([regex match:absoluteURL])
            return YES;
    }
    
    AppDeck *appDeck = [AppDeck sharedInstance];
    if ([request.URL.host isEqualToString:appDeck.loader.conf.baseUrl.host])
    {
        const char *relativeURL = [request.URL.relativePath UTF8String];
        for (RE2Regexp *regex in cacheRegexTmp) {
            if ([regex match:relativeURL])
                return YES;
        }
    }
    
    /*
     for (NSRegularExpression *regex in cacheRegex) {
     if ([regex rangeOfFirstMatchInString:absoluteURL options:0 range:NSMakeRange(0, absoluteURL.length)].location != NSNotFound)
     return YES;
     }
     */
    if (self.alwaysCache == YES)
        return YES;
    
    return NO;
}

-(BOOL)shouldServeRequestFromCache:(NSURLRequest *)request
{
    if ([request.HTTPMethod isEqualToString:@"POST"])
        return NO;
    
    if (request.cachePolicy == NSURLRequestReturnCacheDataDontLoad || request.cachePolicy == NSURLRequestReturnCacheDataElseLoad)
        return YES;
    
    if ([self requestIsInEmbedCache:request])
        return YES;
        
    return [self shouldStoreRequest:request];
    
    //return NO;
}

-(BOOL)isValidResponse:(NSURLResponse *)response
{
    if (![response isKindOfClass:[NSHTTPURLResponse class]])
        return NO;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    // cache is only for 200 OK
    if ([httpResponse statusCode] != 200)
        return NO;
    
    return YES;
}

-(BOOL)shouldStoreResponse:(NSURLResponse *)response
{
    if (![response isKindOfClass:[NSHTTPURLResponse class]])
        return NO;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    // CDN check by Server header
    NSString *server_header = [httpResponse.allHeaderFields objectForKey:@"Server"];
    NSArray *cdn_list = @[@"cloudflare", @"NetDNA"];
    for (NSString *cdn_server in cdn_list)
    {
        NSRange range = [server_header rangeOfString:cdn_server];
        if (range.location != NSNotFound)
            return YES;
    }
    
    return YES;
}


-(BOOL)shouldStoreCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    if ([self isValidResponse:cachedResponse.response] == NO)
        return NO;
    
    // empty response ?
    if (cachedResponse.data.length == 0)
        return NO;

    // not already in mem cache
    if ([memcache objectForKey:request.URL.absoluteString] == cachedResponse)
        return NO;
    
    if ([self shouldStoreRequest:request])
        return YES;

    if ([self shouldStoreResponse:cachedResponse.response])
        return YES;
   
    return NO;
}

-(BOOL)domainShouldBeBlockRec:(NSArray *)subs idx:(NSInteger)idx from:(NSDictionary *)blockedHost
{
    if (idx < 0 || idx >= subs.count)
        return NO;
    
    NSString *sub = [subs objectAtIndex:idx];
//    NSLog(@"check sub %@", sub);
    
    NSObject *item = [blockedHost objectForKey:sub];
    
//    NSLog(@"item: %@", item);
    
    if ([[item class] isSubclassOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)item;
        return [self domainShouldBeBlockRec:subs idx:(idx -1) from:dict];
    } else {
        NSString *val = (NSString *)item;
        if ([val isEqualToString:@"*"])
            return YES;
    }
    
    return NO;
}

-(BOOL)requestShouldBeBlock:(NSURLRequest *)request
{
    NSDictionary *blockedHost = getBlockedHosts();

    NSArray *subs = [request.URL.host componentsSeparatedByString:@"."];
    
    return [self domainShouldBeBlockRec:subs idx:(subs.count - 1) from:blockedHost];
}

#pragma mark - cache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSCachedURLResponse *cachedResponse = [memcache objectForKey:request.URL.absoluteString];
    if (cachedResponse != nil) {
        NSLog(@"getCacheResponseForRequest: MemCache: %@", request.URL.absoluteString);
        return cachedResponse;
    }
    
    if ([self requestIsInEmbedCache:request])
    {
        cachedResponse = [self getCacheResponseForRequest:request];
        if (cachedResponse)
        {
            [memcache setObject:cachedResponse forKey:request.URL.absoluteString];
            return cachedResponse;
        }
    }
    
    /*
    NSLog(@"request: method: %@ url: %@ - cache: %d", [request HTTPMethod], [[request URL] absoluteString], request.cachePolicy);
     */
    /*
    NSCachedURLResponse *cachedResponse = [memcache objectForKey:request.URL.absoluteString];
    if (cachedResponse != nil) {
        NSLog(@"getCacheResponseForRequest: MemCache: %@", request.URL.absoluteString);
        return cachedResponse;
    }*/

    
 /*
    NSCachedURLResponse *cachedResponse = nil;
    BOOL shouldServeRequestFromCache = [self shouldServeRequestFromCache:request];
    if (shouldServeRequestFromCache == YES)
    {
        cachedResponse = [self getCacheResponseForRequest:request];
        if (cachedResponse)
        {
            if (memcache && request && [self shouldStoreRequest:request]) // if we put everything in memory cache, page will not be updated
                [memcache setObject:cachedResponse forKey:request.URL.absoluteString];
            return cachedResponse;
        }
    }*/
    
    return [super cachedResponseForRequest:request];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    [super storeCachedResponse:cachedResponse forRequest:request];
    
    if ([self shouldCacheRequest:request])
        [memcache setObject:cachedResponse forKey:request.URL.absoluteString];
    /*
    __block NSCachedURLResponse *cachedResponse = myCachedResponse;
    __block NSURLRequest *request = myRequest;
    __block AppURLCache *me = self;
    
    if ([request.URL.scheme isEqualToString:@"http"] == NO && [request.URL.scheme isEqualToString:@"https"] == NO)
        return;
    dispatch_async(backgroundQueue, ^(void) {
        if ([me shouldStoreCachedResponse:cachedResponse forRequest:request])
        {
            [me setCacheResponse:cachedResponse forRequest:request];
        }
        // anyway, we store all cached response to disk for offline usage
        else
        {
            // check scheme
            if ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"])
                [me storeToDiskCacheResponse:cachedResponse forRequest:request];
        }
    });*/
    //[super storeCachedResponse:cachedResponse forRequest:request];
}

@end
