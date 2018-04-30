//
//  CacheURLProtocol.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/01/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import "CacheURLProtocol.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "OpenUDID.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
#import "LogViewController.h"
#include "NSString+URLEncoding.h"
#include "NSString+MD5.h"


// The HttpProtocolHandlerCore class is the bridge between the URLRequest
// and the NSURLProtocolClient.
// Threading and ownership details:
// - The HttpProtocolHandlerCore is owned by the HttpProtocolHandler
// - The HttpProtocolHandler is owned by the system and can be deleted anytime
// - All the methods of HttpProtocolHandlerCore must be called on the IO thread,
//   except its constructor that can be called from any thread.

// Implementation notes from Apple's "Read Me About CustomHttpProtocolHandler":
//
// An NSURLProtocol subclass is expected to call the various methods of the
// NSURLProtocolClient from the loading thread, including all of the following:
//  -URLProtocol:wasRedirectedToRequest:redirectResponse:
//  -URLProtocol:didReceiveResponse:cacheStoragePolicy:
//  -URLProtocol:didLoadData:
//  -URLProtocol:didFinishLoading:
//  -URLProtocol:didFailWithError:
//  -URLProtocol:didReceiveAuthenticationChallenge:
//  -URLProtocol:didCancelAuthenticationChallenge:
//
// The NSURLProtocol subclass must call the client callbacks in the expected
// order. This breaks down into three phases:
//  o pre-response -- In the initial phase the NSURLProtocol can make any number
//    of -URLProtocol:wasRedirectedToRequest:redirectResponse: and
//    -URLProtocol:didReceiveAuthenticationChallenge: callbacks.
//  o response -- It must then call
//    -URLProtocol:didReceiveResponse:cacheStoragePolicy: to indicate the
//    arrival of a definitive response.
//  o post-response -- After receive a response it may then make any number of
//    -URLProtocol:didLoadData: callbacks, followed by a
//    -URLProtocolDidFinishLoading: callback.
//
// The -URLProtocol:didFailWithError: callback can be made at any time
// (although keep in mind the following point).
//
// The NSProtocol subclass must only send one authentication challenge to the
// client at a time. After calling
// -URLProtocol:didReceiveAuthenticationChallenge:, it must wait for the client
// to resolve the challenge before calling any callbacks other than
// -URLProtocol:didCancelAuthenticationChallenge:. This means that, if the
// connection fails while there is an outstanding authentication challenge, the
// NSURLProtocol subclass must call
// -URLProtocol:didCancelAuthenticationChallenge: before calling
// -URLProtocol:didFailWithError:.

@implementation CacheURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"CacheURLProtocol" inRequest:request] == nil && [request.URL.scheme hasPrefix:@"http"])
    {
        return YES;
    }
    return NO;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}
/*
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)aRequest toRequest:(NSURLRequest *)bRequest
{
    return YES;
}
*/
#pragma mark - instance method

+(NSString *)getUserId
{
    static NSString *deviceUuid = nil;
    
    if (deviceUuid == nil)
    {
        if (!NSClassFromString(@"ASIdentifierManager")) {
            // This is will run before iOS6 and you can use openUDID, per example...
            deviceUuid = [OpenUDID value];
        } else {
            UIDevice *dev = [UIDevice currentDevice];
            deviceUuid = dev.identifierForVendor.UUIDString;
        }
    }
    return deviceUuid;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    // Modify request so we don't loop
    NSMutableURLRequest *myRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@"set" forKey:@"CacheURLProtocol" inRequest:myRequest];
    
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    // add AppDeck Headers
    [myRequest addValue:[CacheURLProtocol getUserId] forHTTPHeaderField:@"AppDeck-User-ID"];
    [myRequest addValue:appDeck.loader.conf.app_api_key forHTTPHeaderField:@"AppDeck-App-Key"];
    NSString *userAgent = [myRequest.allHTTPHeaderFields objectForKey:@"User-Agent"];
    if (userAgent)
    {
        userAgent = [userAgent stringByAppendingString:[[AppDeck sharedInstance] userAgentChunk]];
        [myRequest addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
 
    // this will assign client
    self = [super initWithRequest:myRequest cachedResponse:cachedResponse client:client];
    if (!self)
        return self;
    self.currentRequest = myRequest;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // log
    NSString *log_url = nil;
    if (glLog && [request.URL.scheme hasPrefix:@"http"])
    {
        log_url = ([glLog.host isEqualToString:request.URL.host] ? [request.URL.absoluteString substringFromIndex:(request.URL.scheme.length + 3 + request.URL.host.length)] : request.URL.absoluteString);
        if ([request.HTTPMethod isEqualToString:@"POST"])
            log_url = [NSString stringWithFormat:@"[POST] %@", log_url];
    }
    
    // cache is only for GET request
    if ([[self.currentRequest HTTPMethod] isEqualToString:@"GET"] == NO)
    {
        if (glLog)
            [glLog debug:@"DOWNLOAD %@", log_url];
        return self;
    }
    
    shouldStoreRequest = YES;
    
    // embed cache ?
    NSString *embedFilePath = [appDeck.cache getCachePathForEmbedResource:self.currentRequest];
    if ([fileManager fileExistsAtPath:embedFilePath])
    {
        shouldServeFromCache = YES;
        shouldForceLongCacheTime = YES;
        cachedFilePathBody = embedFilePath;
        cachedFilePathMeta = [embedFilePath stringByAppendingString:@".meta"];
        if (glLog)
            [glLog debug:@"EMBED %@", log_url];
        return self;
    }
    
    // init cache path
    NSString *cachedFilePath = [appDeck.cache getCachePathForRequest:self.currentRequest];
    cachedFilePathBody = [cachedFilePath stringByAppendingString:@".body"];
    cachedFilePathMeta = [cachedFilePath stringByAppendingString:@".meta"];
    
    // local cache ?
    if ([appDeck.cache shouldCacheRequest:self.currentRequest])
    {
        shouldForceLongCacheTime = YES;
        if ([fileManager fileExistsAtPath:cachedFilePathBody])
        {
            shouldServeFromCache = YES;
            if (glLog)
                [glLog debug:@"CACHE HIT %@", log_url];
        }
        else if (glLog)
            [glLog debug:@"CACHE MISS %@", log_url];

    }
    
    else if (self.currentRequest.cachePolicy == NSURLRequestReturnCacheDataDontLoad || self.currentRequest.cachePolicy == NSURLRequestReturnCacheDataElseLoad)
    {
        if ([fileManager fileExistsAtPath:cachedFilePathBody])
        {
            shouldServeFromCache = YES;
            if (glLog)
                [glLog debug:@"CACHE POLICY HIT %@", log_url];
        }
        else if (glLog)
            [glLog debug:@"CACHE POLICY MISS %@", log_url];
    }
    
    else
    {
        if (glLog)
        {
            if ([request.URL.host hasSuffix:@".appdeck.mobi"] || [request.URL.host hasSuffix:@".widespace.com"]
                     || [request.URL.absoluteString rangeOfString:@".google-analytics.com/collect"].location != NSNotFound
                     || [request.URL.host hasSuffix:@".mobfox.com"] || [request.URL.host hasSuffix:@".mobpartner.mobi"]
                     || [request.URL.host hasSuffix:@".mopub.com"])
                ;
            else
                [glLog debug:@"DOWNLOAD %@", log_url];
        }
    }

    return self;
}

- (void)startLoading
{
    if (shouldServeFromCache && [self serveFromCache])
    {
        [self clean];
        return;
    }
//    self.currentConnection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    
    NSURLSessionConfiguration*config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue: [NSOperationQueue mainQueue]];

    self.downloadTask =[self.session dataTaskWithRequest:self.request];

    [self.downloadTask resume];
}

- (void)stopLoading
{
    
    //[self.downloadTask cancel];
    [self.session invalidateAndCancel];
    //[self.currentConnection cancel];
    [self clean];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    
    if (response)
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response  completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    
    
    self.currentResponse = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self storeResponseStart:response];
    
    
    completionHandler(NSURLSessionResponseAllow);

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [[self client] URLProtocol:self didLoadData:data];
    [self storeResponseAppendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    
    
    
    if (error){
         [self storeResponseCancel];
        if ([NSFileManager.defaultManager fileExistsAtPath:cachedFilePathBody])
        {
            if ([self serveFromCache])
            {
                [self clean];
                return;
            }
        }
        [[self client] URLProtocol:self didFailWithError:error];
        
    }else{
        [self storeResponseClose];
        [[self client] URLProtocolDidFinishLoading:self];
    }
    [self clean];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    completionHandler(proposedResponse);
}
#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
/*    if (shouldForceLongCacheTime)
    {
        NSHTTPURLResponse *httpResponse =
        int cacheTTL = 3600 * 24 * 31;
        [headers setObject:[NSString stringWithFormat:@"public, max-age=%d", cacheTTL] forKey:@"Cache-Control"];
    }*/
    self.currentResponse = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self storeResponseStart:response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    [self storeResponseAppendData:data];
}
/*
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    //    [self.client URLProtocol:self cachedResponseIsValid:cachedResponse];
    return cachedResponse;
}*/

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if (redirectResponse)
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:redirectResponse];
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self storeResponseClose];
    [[self client] URLProtocolDidFinishLoading:self];
    [self clean];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self storeResponseCancel];
    // request failed, we try to get it from cache just in case
    if ([NSFileManager.defaultManager fileExistsAtPath:cachedFilePathBody])
    {
        if ([self serveFromCache])
        {
            [self clean];
            return;
        }
    }
    [[self client] URLProtocol:self didFailWithError:error];
    [self clean];
}

#pragma mark - internal

- (void)storeResponseStart:(NSURLResponse *)response
{
    if (!shouldStoreRequest)
        return;
    
    cachedFilePathBodyTmp = [cachedFilePathBody stringByAppendingString:@".tmp"];
    cachedFilePathMetaTmp = [cachedFilePathMeta stringByAppendingString:@".tmp"];
    
    AppDeck *appDeck = [AppDeck sharedInstance];
 
    if (![appDeck.cache isValidResponse:response])
        return;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    // store headers
    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:[httpResponse allHeaderFields] options:0 error:&error];
    if (json == nil)
    {
        NSLog(@"Error while parsing http headers: %@", error);
        return;
    }
    
    if (![json writeToFile:cachedFilePathMetaTmp atomically:YES])
    {
        NSLog(@"Error while caching http headers: %@", error);
        return;
    }

    [NSFileManager.defaultManager createFileAtPath:cachedFilePathBodyTmp contents:nil attributes:nil];
    storedCacheFileHandle = [NSFileHandle fileHandleForWritingAtPath:cachedFilePathBodyTmp];
}

-(void)storeResponseAppendData:(NSData *)data
{
    if (storedCacheFileHandle == nil)
        return;
    
    @try {
        [storedCacheFileHandle writeData:data];
    }
    @catch (NSException *exception) {
        [self storeResponseCancel];
    }
}

-(void)storeResponseClose
{
    if (storedCacheFileHandle == nil)
        return;
    [storedCacheFileHandle closeFile];
    if ([NSFileManager.defaultManager moveItemAtPath:cachedFilePathMetaTmp toPath:cachedFilePathMeta error:nil] == NO
        || [NSFileManager.defaultManager moveItemAtPath:cachedFilePathBodyTmp toPath:cachedFilePathBody error:nil] == NO)
    {
        [self storeResponseCancel];
    }
    storedCacheFileHandle = nil;
}

-(void)storeResponseCancel
{
    if (storedCacheFileHandle != nil)
    {
        [storedCacheFileHandle closeFile];
        storedCacheFileHandle = nil;
    }
    [NSFileManager.defaultManager removeItemAtPath:cachedFilePathBodyTmp error:nil];
    [NSFileManager.defaultManager removeItemAtPath:cachedFilePathMetaTmp error:nil];
}

-(BOOL)serveFromCache
{
    @try {
        NSFileHandle *cacheFileHandle = [NSFileHandle fileHandleForReadingAtPath:cachedFilePathBody];
        if (cacheFileHandle == nil)
            return NO;

        NSError *error;
        NSDictionary *dictionary = @{};
        NSData *data = [NSFileManager.defaultManager contentsAtPath:cachedFilePathMeta];
        if (data)
            dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSMutableDictionary<NSString *,NSString *> *headers = [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];
        for (NSString *headerName in dictionary) {
            NSString *headerValue = [dictionary objectForKey:headerName];
            NSString *finalHeaderName = [headerName stringByReplacingOccurrencesOfString:@"-" withString:@" "];
            finalHeaderName = [finalHeaderName.capitalizedString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            [headers setObject:headerValue forKey:finalHeaderName];
        }
        // clean cache headers
        [headers removeObjectForKey:@"ETag"];
        [headers removeObjectForKey:@"Age"];
        [headers removeObjectForKey:@"Expires"];
        [headers removeObjectForKey:@"Set-Cookie"];
        [headers removeObjectForKey:@"Cache-Control"];
        if (shouldForceLongCacheTime)
        {
            int cacheTTL = 3600 * 24 * 31;
            [headers setObject:[NSString stringWithFormat:@"public, max-age=%d", cacheTTL] forKey:@"Cache-Control"];
        }
        //[headers setObject:@"AppDeckForceCache" forKey:@"ETag"];
        //response.setHeader('Expires', new Date(Date.now() + cacheTTL * 1000).toUTCString());

        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.currentRequest.URL statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        
        while (1)
        {
            NSData *data = [cacheFileHandle readDataOfLength:4096];
            if (data.length == 0)
                break;
            [[self client] URLProtocol:self didLoadData:data];
        }
        [[self client] URLProtocolDidFinishLoading:self];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"serveFromCache failed: %@", exception);
    }
    return NO;
}


-(void)clean
{
    if (self.currentRequest)
        [NSURLProtocol removePropertyForKey:@"CacheURLProtocol" inRequest:self.currentRequest];
    //self.currentConnection = nil;
    self.session=nil;
    self.currentRequest = nil;
    self.currentResponse = nil;
    
    if (storedCacheFileHandle != nil)
    {
        [storedCacheFileHandle closeFile];
        storedCacheFileHandle = nil;
    }
}

@end
