//
//  LoaderURLProtocol.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 12/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "LoaderURLProtocol.h"
#import "AppDeck.h"
#import "NSString+parseHTTPQuery.h"
#import "AppURLCache.h"

@implementation LoaderURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request.URL.host isEqualToString:@"appdeck"])
    {
        //NSLog(@"LoaderURLProtocol: %@", request.URL.relativePath);
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
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    self.myRequest = request;
    
    return self;
}

- (void)startLoading
{
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"text/plain" expectedContentLength:0 textEncodingName:nil];
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
//    [[self client] URLProtocol:self didLoadData:[NSData alloc]];
//    [[self client] URLProtocolDidFinishLoading:self];
    
    __block LoaderURLProtocol *me = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *body = [[NSString alloc] initWithData:me.request.HTTPBody encoding:NSUTF8StringEncoding];
        NSDictionary *params = [body parseHTTPQuery];
        NSString *url = [params objectForKey:@"url"];
        NSString *cache = [params objectForKey:@"cache"];
        if ([cache isEqualToString:@"on"])
        {
            [[[AppDeck sharedInstance] cache] cleanall];
        }
        [AppDeck reloadFrom:url];
    });

    
}

- (void)stopLoading
{
}

@end
