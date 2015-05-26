//
//  MPAdServerCommunicator.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPAdConfigurationMF.h"
#import "MPGlobalMF.h"

@protocol MPAdServerCommunicatorDelegateMF;

////////////////////////////////////////////////////////////////////////////////////////////////////

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
@interface MPAdServerCommunicatorMF : NSObject <NSURLConnectionDataDelegate>
#else
@interface MPAdServerCommunicatorMF : NSObject
#endif

@property (nonatomic, assign) id<MPAdServerCommunicatorDelegateMF> delegate;
@property (nonatomic, assign, readonly) BOOL loading;

- (id)initWithDelegate:(id<MPAdServerCommunicatorDelegateMF>)delegate;

- (void)loadURL:(NSURL *)URL;
- (void)cancel;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPAdServerCommunicatorDelegateMF <NSObject>

@required
- (void)communicatorDidReceiveAdConfiguration:(MPAdConfigurationMF *)configuration;
- (void)communicatorDidFailWithError:(NSError *)error;

@end
