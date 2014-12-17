//
//  MobilizeUIWebViewURLProtocol.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 14/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MobilizeUIWebViewURLProtocol.h"
#import "NSString+URLEncoding.h"

@implementation MobilizeUIWebViewURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"MobilizeUIWebViewURLProtocol" inRequest:request] != nil /*&& request.cachePolicy != NSURLRequestReturnCacheDataDontLoad*/)
    {
        NSLog(@"ManagedUIWebViewRequest: %@", request.URL.relativePath);
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

- (id)initWithRequest:(NSURLRequest *)request
       cachedResponse:(NSCachedURLResponse *)cachedResponse
               client:(id <NSURLProtocolClient>)client
{
    // Modify request so we don't loop
    NSMutableURLRequest *myRequest = [request mutableCopy];
//    ctl = (UIViewController *) [NSURLProtocol propertyForKey:@"MobilizeUIWebViewURLProtocol" inRequest:request];
    NSString *mobilize_url_string = [NSString stringWithFormat:@"http://mobilize.mobideck.net/?url=%@", [request.URL.absoluteString urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    myRequest.URL = [NSURL URLWithString:mobilize_url_string];
    [NSURLProtocol setProperty:nil forKey:@"MobilizeUIWebViewURLProtocol" inRequest:myRequest];
    
    // this will assign client
    self = [super initWithRequest:myRequest cachedResponse:cachedResponse client:client];
    
    if (self)
    {
        self.MyRequest = myRequest;
    }
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

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
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
    [[self client] URLProtocolDidFinishLoading:self];
    [self clean];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
    [self clean];
}

#pragma mark - internal

-(void)clean
{
    self.MyConnection = nil;
    self.MyRequest = nil;
    self.response = nil;
}
@end
