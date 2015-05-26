//
//  MPBannerAdManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdServerCommunicatorMF.h"
#import "MPBaseBannerAdapterMF.h"

@protocol MPBannerAdManagerDelegateMF;

@interface MPBannerAdManagerMF : NSObject <MPAdServerCommunicatorDelegateMF, MPBannerAdapterDelegateMF>

@property (nonatomic, assign) id<MPBannerAdManagerDelegateMF> delegate;

- (id)initWithDelegate:(id<MPBannerAdManagerDelegateMF>)delegate;

- (void)loadAd;
- (void)forceRefreshAd;
- (void)stopAutomaticallyRefreshingContents;
- (void)startAutomaticallyRefreshingContents;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

// Deprecated.
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;
- (void)customEventActionDidEnd;

@end
