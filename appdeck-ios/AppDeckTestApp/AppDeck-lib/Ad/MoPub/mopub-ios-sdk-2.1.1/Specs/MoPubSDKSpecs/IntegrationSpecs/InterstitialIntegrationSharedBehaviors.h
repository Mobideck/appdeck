//
//  InterstitialIntegrationSharedBehaviors.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

@class MPAdServerCommunicator;
@class MPInterstitialAdController;

@protocol MPInterstitialAdControllerDelegate;
@protocol CedarDouble;

extern NSString *anInterstitialThatStartsLoadingAnAdUnit;
extern NSString *anInterstitialThatHasAlreadyLoaded;
extern NSString *anInterstitialThatPreventsLoading;
extern NSString *anInterstitialThatPreventsShowing;
extern NSString *anInterstitialThatLoadsTheFailoverURL;
extern NSString *anInterstitialThatTimesOut;
extern NSString *anInterstitialThatDoesNotTimeOut;

@protocol FakeInterstitialAd <NSObject>

- (UIViewController *)presentingViewController;

@end

void setUpInterstitialSharedContext(FakeMPAdServerCommunicator *communicator, id<MPInterstitialAdControllerDelegate, CedarDouble> delegate, MPInterstitialAdController *interstitial, NSString *adUnitId, id<FakeInterstitialAd>fakeInterstitialAd, NSURL *failoverURL);
