//
//  FakeMPAdWebView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdWebView.h"

@interface FakeMPAdWebView : MPAdWebView <FakeInterstitialAd>

// As an interstitial/banner
- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;

// As a banner
- (void)simulateUserBringingUpModal;
- (void)simulateUserDismissingModal;
- (void)simulateUserLeavingApplication;

// As an interstitial
- (BOOL)didAppear;
- (void)simulateUserDismissingAd;
- (UIViewController *)presentingViewController;

@end
