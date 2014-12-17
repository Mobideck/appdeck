//
//  FakeInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEvent.h"

@interface FakeInterstitialCustomEvent : MPInterstitialCustomEvent <FakeInterstitialAd>

@property (nonatomic, strong) NSDictionary *customEventInfo;
@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, assign) BOOL invalidated;
@property (nonatomic, assign) BOOL enableAutomaticImpressionAndClickTracking;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;

- (void)simulateUserTap;

- (void)simulateInterstitialFinishedAppearing;

- (void)simulateUserDismissingAd;
- (void)simulateInterstitialFinishedDisappearing;

@end
