//
//  RemoteCache.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum RemoteAppCacheState: int {
    RemoteAppCacheStateWait = 0,
    RemoteAppCacheStateWork = 1
} RemoteAppCacheState;

@interface RemoteAppCache : NSObject
{
    NSURL   *url;
    float   ttl;
    NSTimer *timer;

    dispatch_queue_t backgroundQueue;
}

-(id)initWithURL:(NSURL *)url andTTL:(float)seconds;
-(void)downloadAppCache:(id)sender;

@property (nonatomic, assign)   RemoteAppCacheState state;
@property (nonatomic, assign)   int lastFetchNbUpdate;
@property (nonatomic, assign)   int lastFetchNbCreate;

+(void)sync:(NSURL *)url nbCreate:(int *)lastFetchNbCreate nbUpdate:(int *)lastFetchNbUpdate;

@end
