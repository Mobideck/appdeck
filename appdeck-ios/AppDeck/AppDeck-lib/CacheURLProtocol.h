//
//  CacheURLProtocol.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/01/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheURLProtocol : NSURLProtocol<NSURLSessionDelegate>
{
    BOOL shouldServeFromCache;
    BOOL shouldForceLongCacheTime;
    BOOL shouldStoreRequest;

    
/*    BOOL shouldCache;
    BOOL isInEmbedCache;

    BOOL requestIsInCache;
    
    NSDate *cacheDate;    */
    
    NSString *cachedFilePathBody;
    NSString *cachedFilePathMeta;

    NSString *cachedFilePathBodyTmp;
    NSString *cachedFilePathMetaTmp;    
    
    NSFileHandle *storedCacheFileHandle;
}

@property (nonatomic, strong) NSMutableURLRequest *currentRequest;

@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask*downloadTask;

@property (nonatomic, strong) NSURLResponse *currentResponse;

@end
