//
//  ManagedWebViewURLProtocol.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 28/02/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "ManagedUIWebViewURLProtocol.h"
#import "ManagedUIWebViewController.h"
#import "AppDeck.h"
#import "AppURLCache.h"

extern char code[];
extern long sizeofcode;

extern char codeblank[];
extern long sizeofcodeblank;


@implementation ManagedUIWebViewURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    /*
    id property = [request valueForHTTPHeaderField:@"ManagedUIWebViewController"];
    NSLog(@"%p %@: %@", request, request.URL.absoluteString, property);
    if (property != nil)
    {
        NSLog(@"ManagedUIWebViewRequest: %@", request.URL.relativePath);
        return YES;
    }
    return NO;*/
    
//        [mutableRequest addValue:@"ManagedUIWebViewController" forHTTPHeaderField:@"ManagedUIWebViewController"];
    

    id property = [NSURLProtocol propertyForKey:@"ManagedUIWebViewController" inRequest:request];
    //NSLog(@"%p %@: %@", request, request.URL.absoluteString, property);
    if (property != nil)
    {
        //NSLog(@"ManagedUIWebViewRequest: %@", request.URL.relativePath);
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
    //NSLog(@"Request: %@", request);
    NSMutableURLRequest *myRequest = [request mutableCopy];
    NSMutableArray *me = [NSURLProtocol propertyForKey:@"ManagedUIWebViewController" inRequest:request];
    if (me && [[me class] isSubclassOfClass:[NSMutableArray class]] && me.count > 0)
    {
        ctl = (ManagedUIWebViewController *) [me objectAtIndex:0];
        [me removeAllObjects];
    }
    // remove property
    [NSURLProtocol removePropertyForKey:@"ManagedUIWebViewController" inRequest:myRequest];
    [NSURLProtocol setProperty:@"disableCDN" forKey:@"disableCDN" inRequest:myRequest];
    // this will assign client
    self = [super initWithRequest:myRequest cachedResponse:cachedResponse client:client];
    
    if (self)
    {
        self.myRequest = (NSMutableURLRequest *)myRequest;
    }
    return self;
}

- (void)startLoading
{
    self.MyConnection = [NSURLConnection connectionWithRequest:[self request] delegate:self];
}

- (void)stopLoading
{
    [self.myConnection cancel];
    [self clean];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (tmp)
    {
        [tmp appendData:data];

        data = [ManagedUIWebViewController dataWithInjectedAppDeckJS:data];
        
        if (data == nil)
            return;
        
        tmp = nil;
        /*
        NSData *patched_data = [ManagedUIWebViewController dataWithInjectedAppDeckJS:data];
        if (patched_data != nil)
        {
            
        }*/
        
        //return;
/*
        char *buf = (char *)[tmp bytes];
        long length = [tmp length];
        for (long k = 0; k < length; k++)
        {
            if ((buf[k] == 'h' || buf[k] == 'H') &&
                (buf[k + 1] == 'e' || buf[k + 1] == 'E') &&
                (buf[k + 2] == 'a' || buf[k + 2] == 'A') &&
                (buf[k + 3] == 'd' || buf[k + 3] == 'D'))
            {
                for (long i = k + 4; i < length; i++)
                {
                    if (buf[i] == '>')
                    {
                        i++;
                        void *mem = malloc(length + sizeof(code));
                        memcpy(mem, buf, i);
                        memcpy(mem + i, code, sizeof(code));
                        memcpy(mem + i + sizeof(code), buf + i, length - i);
                        data = [NSData dataWithBytesNoCopy:mem length:length + sizeof(code)];
                        buf = (char *)mem;
                        tmp = nil;
                        break;
                    }
                }
                if (tmp == nil)
                    break;
            }
        }*/
        if (tmp)
            return;
    }
    [[self client] URLProtocol:self didLoadData:data];
    receivedContentLength += data.length;
    __block ManagedUIWebViewController *myCtl = ctl;
    __block NSData *myData = data;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [myCtl initialRequestDidReceiveData:myData offset:receivedContentLength total:expectedContentLength];
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        __block NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        long status = [httpResponse statusCode];
        //NSLog(@"HTTP status code is : %d", status);
        //if (status != 200 && status != 302)
        if (status >= 400 && status != 403)
        {
            NSLog(@"error HTTP status code is : %ld: %@", status, [NSHTTPURLResponse localizedStringForStatusCode:status]);
            [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
            [connection cancel];
            __block ManagedUIWebViewController *myCtl = ctl;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (myCtl)
                    [myCtl initialRequestDidFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
            });
            //[self connection:connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
            return;
        }
        NSDictionary *headers = [httpResponse allHeaderFields];
        NSString *length = [headers objectForKey:@"Content-Length"];
        if (length != nil)
            expectedContentLength = [length longLongValue];

        // inject js ?
        if ([ManagedUIWebViewController shouldInjectAppDeckJSInResponse:response])
        {
            if (length)
            {
                expectedContentLength = expectedContentLength + sizeofcode;
                tmp = [[NSMutableData alloc] initWithCapacity:expectedContentLength];
            }
            else
                tmp = [[NSMutableData alloc] initWithCapacity:128 * 1024];
        }
        else
            NSLog(@"Not Injecting JS in %@ content type is not html", self.request.URL.absoluteString);
        /*
        NSString *contentType = [[headers objectForKey:@"Content-Type"] lowercaseString];
        if (contentType && [contentType rangeOfString:@"html"].location != NSNotFound)
        {
            //NSLog(@"Inject JS in %@", self.request.URL.absoluteString);
            NSMutableDictionary *newHeaders = [headers mutableCopy];
            if (length)
                [newHeaders setObject:[NSString stringWithFormat:@"%ld", expectedContentLength + sizeofcode] forKey:@"Content-Length"];
            NSHTTPURLResponse *newResponse = [[NSHTTPURLResponse alloc] initWithURL:response.URL statusCode:status HTTPVersion:@"HTTP/1.1" headerFields:newHeaders];
            response = newResponse;
            if (length)
            {
                expectedContentLength = expectedContentLength + sizeofcode;
                tmp = [[NSMutableData alloc] initWithCapacity:expectedContentLength];
            }
            else
                tmp = [[NSMutableData alloc] initWithCapacity:128 * 1024];
        }
        else
            NSLog(@"Not Injecting JS in %@ content type is not html (%@)", self.request.URL.absoluteString, contentType);
         */
        __block ManagedUIWebViewController *myCtl = ctl;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [myCtl initialRequestDidReceiveResponse:httpResponse];
        });
    }
    self.response = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
/*    if (cachedResponse)
        [self.client URLProtocol:self cachedResponseIsValid:cachedResponse];*/
    AppDeck *appDeck = [AppDeck sharedInstance];
    [appDeck.cache storeCachedResponse:cachedResponse forRequest:self.request];
    
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
    /*
    {
        NSData *data = [NSData dataWithBytes:codeblank length:sizeofcodeblank];
        [[self client] URLProtocol:self didLoadData:data];
    }
    */
    if (tmp)
    {
        NSData *data = [ManagedUIWebViewController dataWithInjectedAppDeckJS:tmp];
        if (data)
        {
            [[self client] URLProtocol:self didLoadData:data];
        } else {
            NSLog(@"failed to inject appdeck.js in %@", self.request.URL.absoluteString);
            [[self client] URLProtocol:self didLoadData:tmp];
        }
        tmp = nil;
        data = nil;
        
        /*
        char *buf = (char *)[tmp bytes];
        long length = [tmp length];
        for (long k = 0; k < length; k++)
        {
            if ((buf[k] == 'h' || buf[k] == 'H') &&
                (buf[k + 1] == 'e' || buf[k + 1] == 'E') &&
                (buf[k + 2] == 'a' || buf[k + 2] == 'A') &&
                (buf[k + 3] == 'd' || buf[k + 3] == 'D'))
            {
                for (long i = k + 4; i < length; i++)
                {
                    if (buf[i] == '>')
                    {
                        i++;
                        void *mem = malloc(length + sizeofcode);
                        memcpy(mem, buf, i);
                        memcpy(mem + i, code, sizeofcode);
                        memcpy(mem + i + sizeofcode, buf + i, length - i);
                        NSData *data = [NSData dataWithBytesNoCopy:mem length:length + sizeofcode];
                        [[self client] URLProtocol:self didLoadData:data];
                        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:self.response data:data];
                        AppDeck *appDeck = [AppDeck sharedInstance];
                        [appDeck.cache storeCachedResponse:cachedResponse forRequest:self.request];
                        buf = (char *)mem;
                        tmp = nil;
                        break;
                    }
                }
                if (tmp == nil)
                    break;
            }
        }
        if (tmp)
        {
            NSLog(@"failed to inject appdeck.js in %@", self.request.URL.absoluteString);
            [[self client] URLProtocol:self didLoadData:tmp];
            tmp = nil;
        }*/
    }
    [[self client] URLProtocolDidFinishLoading:self];
    __block ManagedUIWebViewController *myCtl = ctl;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [myCtl initialRequestDidFinishLoading];
    });
    [self clean];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
    __block ManagedUIWebViewController *myCtl = ctl;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [myCtl initialRequestDidFailWithError:error];
    });
    [self clean];
}

#pragma mark - internal

-(void)clean
{
//    [NSURLProtocol setProperty:nil forKey:@"ManagedUIWebViewController" inRequest:self.request];
    self.myConnection = nil;
    self.myRequest = nil;
    self.response = nil;
    ctl = nil;
}

@end