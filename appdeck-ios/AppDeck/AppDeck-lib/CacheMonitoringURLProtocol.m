//
//  CacheMonitoringURLProtocol.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "CacheMonitoringURLProtocol.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "OpenUDID.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
#import "LogViewController.h"

@implementation CacheMonitoringURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"CacheMonitoringURLProtocol" inRequest:request] == nil /*&& [NSURLProtocol propertyForKey:@"ManagedUIWebViewController" inRequest:request] != nil*/)
    {
        //NSLog(@"CacheMonitoringURLProtocol: %@", request.URL.relativePath);
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)aRequest toRequest:(NSURLRequest *)bRequest
{
    return YES;
}

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

- (id)initWithRequest:(NSURLRequest *)request
       cachedResponse:(NSCachedURLResponse *)cachedResponse
               client:(id <NSURLProtocolClient>)client
{
    // Modify request so we don't loop
    NSMutableURLRequest *myRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@"set" forKey:@"CacheMonitoringURLProtocol" inRequest:myRequest];

    shouldCache = NO;
    AppDeck *appDeck = [AppDeck sharedInstance];
    NSDate *date;
    
    [myRequest addValue:[CacheMonitoringURLProtocol getUserId] forHTTPHeaderField:@"AppDeck-User-ID"];
    [myRequest addValue:appDeck.loader.conf.app_api_key forHTTPHeaderField:@"AppDeck-App-Key"];
    [myRequest addValue:[[AppDeck sharedInstance] userAgent] forHTTPHeaderField:@"User-Agent"];
    
    //NSLog(@"%@", request.URL.absoluteString);
    
    BOOL isInEmbedCache = [appDeck.cache requestIsInEmbedCache:request];
    BOOL shouldStoreRequest = [appDeck.cache shouldStoreRequest:request];
    BOOL requestIsInCache = [appDeck.cache requestIsInCache:request date:&date];
    if (isInEmbedCache == NO && shouldStoreRequest == YES)
        shouldCache = YES;
    
    //NSLog(@"CDN? %@ - shouldcache: %d - cdn enabled: %d", myRequest.URL.absoluteString, shouldCache, appDeck.loader.conf.cdn_enabled);
    
    shouldCDN = NO;
    if ([NSURLProtocol propertyForKey:@"disableCDN" inRequest:request] == nil)
        if (shouldCache == YES)
            if (appDeck.loader.conf.cdn_enabled == YES)
                if ([myRequest.URL.host isEqualToString:appDeck.loader.conf.baseUrl.host])
                {
                    NSString *cdn_url_string = [myRequest.URL.absoluteString stringByReplacingOccurrencesOfString:appDeck.loader.conf.baseUrl.host
                                                                                               withString:[appDeck.loader.conf.cdn_host stringByAppendingString:appDeck.loader.conf.cdn_path]];
                    NSURL *cdn_url = [NSURL URLWithString:cdn_url_string];
                    myRequest.URL = cdn_url;
                    shouldCDN = YES;
                }
    
    // log
    if (glLog && [request.URL.scheme hasPrefix:@"http"])
    {
        //NSString *log_url = ([glLog.host isEqualToString:request.URL.host] ? request.URL.relativePath : request.URL.absoluteString);
        NSString *log_url = ([glLog.host isEqualToString:request.URL.host] ? [request.URL.absoluteString substringFromIndex:(request.URL.scheme.length + 3 + request.URL.host.length)] : request.URL.absoluteString);
        if ([request.HTTPMethod isEqualToString:@"POST"])
            log_url = [NSString stringWithFormat:@"[POST] %@", log_url];
        if (isInEmbedCache)
            [glLog debug:@"EMBED %@", log_url];
        else if (shouldStoreRequest && requestIsInCache)
            [glLog debug:@"CACHE HIT %@", log_url];
        else if ([request.URL.host hasSuffix:@".appdeck.mobi"] || [request.URL.host hasSuffix:@".widespace.com"] || [request.URL.absoluteString containsString:@".google-analytics.com/collect"]|| [request.URL.host hasSuffix:@".mobfox.com"])
            ;
        else if (shouldStoreRequest)
            [glLog debug:@"CACHE MISS %@", log_url];
        else
            [glLog info:@"DOWNLOAD %@", log_url];
    }
    
    // this will assign client
    self = [super initWithRequest:myRequest cachedResponse:cachedResponse client:client];
    
    if (self)
    {
        self.MyRequest = myRequest;
    }
    
/*    if (cachedResponse)
    {
        NSLog(@"SPC %@", myRequest.URL.absoluteString);
        [self.client URLProtocol:self cachedResponseIsValid:cachedResponse];
    }*/
    
    return self;
}

- (void)startLoading
{
    self.MyConnection = [NSURLConnection connectionWithRequest:[self request] delegate:self];
}

- (void)stopLoading
{
    [self.MyConnection cancel];
    [self clean];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    if (shouldCache)
    {
        if (self.data == nil)
            self.data = [data mutableCopy];
        else
            [self.data appendData:data];
    }
}


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
//    [self.client URLProtocol:self cachedResponseIsValid:cachedResponse];
    return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if (redirectResponse)
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:redirectResponse];
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (shouldCache == YES)
    {
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:self.response data:self.data];
        AppDeck *appDeck = [AppDeck sharedInstance];
        [appDeck.cache storeCachedResponse:cachedResponse forRequest:self.request];

    }
    [[self client] URLProtocolDidFinishLoading:self];
    [self clean];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // request failed, we try to get it from cache just in case
    if (self.request && self.request.URL != nil)
    {
        AppDeck *appDeck = [AppDeck sharedInstance];
        NSCachedURLResponse *cachedResponse = [appDeck.cache getCacheResponseForRequest:self.request];
        if (cachedResponse != nil)
        {
            NSLog(@"network failure: force pop %@ from cache", self.request);
            [[self client] URLProtocol:self didReceiveResponse:cachedResponse.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [[self client] URLProtocol:self didLoadData:cachedResponse.data];
            [[self client] URLProtocolDidFinishLoading:self];
            return;
        }
    }
    [[self client] URLProtocol:self didFailWithError:error];
    [self clean];
}

#pragma mark - internal

-(void)clean
{
//    [NSURLProtocol removePropertyForKey:@"CacheMonitoringURLProtocol" inRequest:self.MyRequest];
    self.MyConnection = nil;
    self.MyRequest = nil;
    self.response = nil;
    self.data = nil;
}

@end
