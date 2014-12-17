//
//  RNCachingURLProtocol.m
//
//  Created by Robert Napier on 1/10/12.
//  Copyright (c) 2012 Rob Napier. All rights reserved.
//

#import "RNCachingURLProtocol.h"

@interface RNCachedData : NSObject <NSCoding>
@property (nonatomic, readwrite, strong) NSData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
@end

static NSString *RNCachingURLHeader = @"X-RNCache";

@interface RNCachingURLProtocol ()  //<NSURLConnectionDelegate, NSURLConnectionDataDelegate> //iOS5-only
@property (nonatomic, readwrite, strong) NSURLRequest *request;
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
- (void)appendData:(NSData *)newData;
@end

@implementation RNCachingURLProtocol
@synthesize request = request_;
@synthesize connection = connection_;
@synthesize data = data_;
@synthesize response = response_;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"canInitWithRequest: %@", request.URL.relativePath);
    if ([request.URL.absoluteString hasPrefix:@"http://pcinpact.mobideck.net/"] && [[[request URL] scheme] isEqualToString:@"http"] && [request valueForHTTPHeaderField:RNCachingURLHeader] == nil)
    {
        return NO;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

+ (void)removePropertyForKey:(NSString *)key inRequest:(NSMutableURLRequest *)request
{
    [super removePropertyForKey:key inRequest:request];
}

+ (BOOL)registerClass:(Class)protocolClass
{
    return [super registerClass:protocolClass];
}

+ (void)unregisterClass:(Class)protocolClass
{
    [super unregisterClass:protocolClass];
}

+ (id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request
{
    return [super propertyForKey:key inRequest:request];
}

+ (void)setProperty:(id)value forKey:(NSString *)key inRequest:(NSMutableURLRequest *)request
{
    [super setProperty:value forKey:key inRequest:request];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)aRequest toRequest:(NSURLRequest *)bRequest
{
    return [super requestIsCacheEquivalent:aRequest toRequest:bRequest];
}

#pragma mark - instance method

/*- (NSCachedURLResponse *)cachedResponse
{
    
}

- (id < NSURLProtocolClient >)client
{
    
}*/

- (id)initWithRequest:(NSURLRequest *)request
       cachedResponse:(NSCachedURLResponse *)cachedResponse
               client:(id <NSURLProtocolClient>)client
{
  // Modify request so we don't loop
  NSMutableURLRequest *myRequest = [request mutableCopy];
  [myRequest setValue:@"" forHTTPHeaderField:RNCachingURLHeader];

  self = [super initWithRequest:myRequest
                 cachedResponse:cachedResponse
                         client:client];

  if (self)
  {
    [self setRequest:myRequest];
  }
  return self;
}

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest
{
  // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
  NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
  return [cachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%x", (unsigned int)[[[aRequest URL] absoluteString] hash]]];

}

- (void)startLoading
{
    if (self.request.cachePolicy == NSURLRequestReturnCacheDataElseLoad || self.request.cachePolicy == NSURLRequestReturnCacheDataDontLoad)
    {
        RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
        if (cache)
        {
            NSData *data = [cache data];
            NSURLResponse *response = [cache response];
            [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
            [[self client] URLProtocol:self didLoadData:data];
            [[self client] URLProtocolDidFinishLoading:self];
            return;
        }
    }
  if (YES)
  {
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:[self request]
                                                                delegate:self];
    [self setConnection:connection];
  }
  else
  {
    RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
    if (cache)
    {
      NSData *data = [cache data];
      NSURLResponse *response = [cache response];
      [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
      [[self client] URLProtocol:self didLoadData:data];
      [[self client] URLProtocolDidFinishLoading:self];
    }
    else
    {
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:[self request]
                                                                    delegate:self];
        [self setConnection:connection];
/*
      [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];*/
    }
  }
}

- (void)stopLoading
{
  [[self connection] cancel];
}

// NSURLConnection delegates (generally we pass these on to our client)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [[self client] URLProtocol:self didLoadData:data];
  [self appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  [[self client] URLProtocol:self didFailWithError:error];
  [self setConnection:nil];
  [self setData:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [self setResponse:response];
  [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];  // We cache ourselves.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  [[self client] URLProtocolDidFinishLoading:self];

  NSString *cachePath = [self cachePathForRequest:[self request]];
  RNCachedData *cache = [RNCachedData new];
  [cache setResponse:[self response]];
  [cache setData:[self data]];
  [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];

  [self setConnection:nil];
  [self setData:nil];
}

- (void)appendData:(NSData *)newData
{
  if ([self data] == nil)
  {
    [self setData:[[NSMutableData alloc] initWithData:newData]];
  }
  else
  {
    [[self data] appendData:newData];
  }
}

@end

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";

@implementation RNCachedData
@synthesize data = data_;
@synthesize response = response_;

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