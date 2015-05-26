//
//  MPInterstitialAdManager.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdServerCommunicatorMF.h"
#import "MPBaseInterstitialAdapterMF.h"

@class CLLocation;
@protocol MPInterstitialAdManagerDelegateMF;

@interface MPInterstitialAdManagerMF : NSObject <MPAdServerCommunicatorDelegateMF,
    MPInterstitialAdapterDelegateMF>

@property (nonatomic, assign) id<MPInterstitialAdManagerDelegateMF> delegate;
@property (nonatomic, assign, readonly) BOOL ready;

- (id)initWithDelegate:(id<MPInterstitialAdManagerDelegateMF>)delegate;

- (void)loadInterstitialWithAdUnitID:(NSString *)ID
                            keywords:(NSString *)keywords
                            location:(CLLocation *)location
                             testing:(BOOL)testing;
- (void)presentInterstitialFromViewController:(UIViewController *)controller;

// Deprecated
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;

@end
