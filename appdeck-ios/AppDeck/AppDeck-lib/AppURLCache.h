//
//  AppURLCache.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/09/14.
//  Copyright (c) 2012 Mobideck. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LogViewController;
@class RE2Regexp;

@interface AppURLCache : NSURLCache
{
    NSCache    *memcache;
    
    dispatch_queue_t backgroundQueue;
    NSFileManager *fileManager;
    NSMutableArray  *cacheRegex;
    
    RE2Regexp *cdnregexp;
    
    NSCachedURLResponse *emptyResponse;
}

@property (assign, nonatomic) BOOL alwaysCache;
@property (assign, nonatomic) BOOL enableAdBlock;

-(NSString *)getCachePathForEmbedResource:(NSURLRequest *)request;
-(NSString *)getCachePathForRequest:(NSURLRequest *)request;

-(void)addCacheRegularExpressionFromString:(NSString *)regexString;
-(void)addAdBlockWhiteListCacheRegularExpressionFromString:(NSString *)regexString;
-(void)addAdBlockBlackListCacheRegularExpressionFromString:(NSString *)regexString;

-(void)removeAllRegularExpression;

-(BOOL)requestIsInCache:(NSURLRequest *)request date:(NSDate **)date;

-(BOOL)requestIsInEmbedCache:(NSURLRequest *)request;

-(BOOL)shouldCacheRequest:(NSURLRequest *)request;

-(BOOL)shouldStoreRequest:(NSURLRequest *)request;

-(NSCachedURLResponse *)getCacheResponseForRequest:(NSURLRequest *)request;

- (void)didReceiveMemoryWarning;

-(void)storeToDiskCacheResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request;

-(void)cleanall;

-(BOOL)isValidResponse:(NSURLResponse *)response;
-(BOOL)shouldStoreResponse:(NSURLResponse *)response;

-(BOOL)shouldServeRequestFromCache:(NSURLRequest *)request;

@end
