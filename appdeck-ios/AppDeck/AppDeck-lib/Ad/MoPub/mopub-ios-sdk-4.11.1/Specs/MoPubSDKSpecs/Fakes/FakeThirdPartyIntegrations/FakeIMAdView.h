//
//  FakeIMAdView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "IMBanner.h"
#import "IMBannerDelegate.h"

@interface FakeIMAdView : IMBanner

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;
- (void)simulateUserLeavingApplication;

@end
