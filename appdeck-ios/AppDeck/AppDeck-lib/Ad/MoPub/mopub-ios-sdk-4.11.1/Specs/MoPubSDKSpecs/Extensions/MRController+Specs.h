//
//  MRController+Specs.h
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRController.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MRBridge.h"

@class MRExpandModalViewController;

@interface MRController (Specs) <MRBridgeDelegate, MPAdDestinationDisplayAgentDelegate, MPClosableViewDelegate>

@property (nonatomic, strong) MPClosableView *mraidAdView;
@property (nonatomic, strong) MPClosableView *mraidAdViewTwoPart;
@property (nonatomic, strong) MRExpandModalViewController *expandModalViewController;
@property (nonatomic, assign) BOOL isAdLoading;
@property (nonatomic, assign) BOOL isAnimatingAdSize;
@property (nonatomic, assign) MRAdViewState currentState;
@property (nonatomic, strong) MRBridge *mraidBridge;
@property (nonatomic, strong) MRBridge *mraidBridgeTwoPart;
@property (nonatomic, assign) BOOL isViewable;
@property (nonatomic, assign) CGSize currentAdSize;
@property (nonatomic, assign) MRAdViewPlacementType placementType;
@property (nonatomic, assign) UIInterfaceOrientation currentInterfaceOrientation;
@property (nonatomic, copy) void (^forceOrientationAfterAnimationBlock)();
@property (nonatomic, weak) MPMRAIDInterstitialViewController *interstitialViewController;

- (void)checkViewability;
- (void)orientationDidChange:(NSNotification *)notification;
- (void)updateMRAIDProperties;

@end
