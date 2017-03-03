//
//  FakeBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerCustomEvent.h"

@interface FakeBannerCustomEvent : MPBannerCustomEvent

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSDictionary *customEventInfo;
@property (nonatomic, assign) BOOL invalidated;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) BOOL enableAutomaticImpressionAndClickTracking;
@property (nonatomic, assign) BOOL didDisplay;

- (id)initWithFrame:(CGRect)frame;
- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;
- (void)simulateUserLeavingApplication;

@end
