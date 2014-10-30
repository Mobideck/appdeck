//
//  EmbedResources.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmbedResources : NSObject <NSURLConnectionDelegate>
{
    BOOL cancel;
//    dispatch_queue_t backgroundQueue;
    
    NSURLConnection *conn;
    
    NSMutableData *receivedData;
}

-(id)initWithURL:(NSURL *)url shouldOverrideEmbedResource:(BOOL)override downloadInBackground:(BOOL)async;

-(void)sync;

-(void)cancel;

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) BOOL  override;
@property (nonatomic, assign) BOOL  async;

@end
