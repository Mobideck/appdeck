//
//  FakeMPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"
#import "FakeMPAdServerCommunicator.h"
#import "FakeInterstitialAdapter.h"
#import "FakeMPAnalyticsTracker.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "FakeInterstitialCustomEvent.h"
#import <Chartboost/Chartboost.h>
#import "FakeGSFullscreenAd.h"
#import "IMInterstitial.h"
#import "IMBanner.h"
#import "MPInterstitialAdManager.h"
#import "FakeGSBannerAdView.h"
#import "MPBaseBannerAdapter.h"
#import "FakeBannerCustomEvent.h"
#import "FakeMPTimer.h"
#import "FakeMPAdAlertManager.h"
#import "FakeMPAdAlertGestureRecognizer.h"
#import "FakeMRController.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <Foundation/Foundation.h>
#import "MPNativeAdSource.h"
#import "MPNativePositionSource.h"
#import "MPStreamAdPlacer.h"
#import "FakeMPStreamAdPlacer.h"
#import "MPClosableView.h"
#import "MPRewardedVideoAdManager.h"
#import "MPRewardedVideoAdapter.h"
#import "MPRewardedVideoCustomEvent.h"
#import "MPWebView.h"

@class MRVideoPlayerManager;
@class MPMoviePlayerViewController;
@class MRBundleManager;
@class MRBridge;
@class MPStreamAdPlacementData;
@class MRNativeCommandHandler;

@interface FakeMPInstanceProvider : MPInstanceProvider

#pragma mark - Banners
@property (nonatomic, strong) MPBaseBannerAdapter *fakeBannerAdapter;
@property (nonatomic, strong) FakeBannerCustomEvent *fakeBannerCustomEvent;

#pragma mark - Interstitials
@property (nonatomic, strong) MPInterstitialAdManager *fakeMPInterstitialAdManager;
@property (nonatomic, strong) MPBaseInterstitialAdapter *fakeInterstitialAdapter;
@property (nonatomic, strong) FakeInterstitialCustomEvent *fakeInterstitialCustomEvent;
@property (nonatomic, strong) MPHTMLInterstitialViewController *fakeMPHTMLInterstitialViewController;
@property (nonatomic, strong) MPMRAIDInterstitialViewController *fakeMPMRAIDInterstitialViewController;

#pragma mark - Rewarded Video
@property (nonatomic, strong) MPRewardedVideoAdManager *fakeMPRewardedVideoAdManager;
@property (nonatomic, strong) MPRewardedVideoAdapter *fakeMPRewardedVideoAdapter;
@property (nonatomic, strong) MPRewardedVideoCustomEvent *fakeMPRewardedVideoCustomEvent;

#pragma mark - HTML Ads
@property (nonatomic, strong) MPWebView *fakeMPWebView;
@property (nonatomic, strong) MPAdWebViewAgent *fakeMPAdWebViewAgent;

#pragma mark - MRAID
@property (nonatomic, strong) MPClosableView *fakeMRAIDMPClosableView;
@property (nonatomic, strong) MRController *fakeMRController;
@property (nonatomic, strong) MRBridge *fakeMRBridge;
@property (nonatomic, strong) MRBundleManager *fakeMRBundleManager;
@property (nonatomic, strong) MRVideoPlayerManager *fakeMRVideoPlayerManager;
@property (nonatomic, strong) MPMoviePlayerViewController *fakeMoviePlayerViewController;
@property (nonatomic, strong) MRNativeCommandHandler *fakeNativeCommandHandler;

#pragma mark - Native
@property (nonatomic, strong) MPNativeAdSource *fakeNativeAdSource;
@property (nonatomic, strong) MPNativePositionSource *fakeNativePositioningSource;
@property (nonatomic, strong) MPStreamAdPlacementData *fakeStreamAdPlacementData;
@property (nonatomic, strong) MPStreamAdPlacer *fakeStreamAdPlacer;

#pragma mark - Third Party Integrations

#pragma mark Facebook
@property (nonatomic, strong) FBAdView *fakeFBAdView;
@property (nonatomic, strong) FBInterstitialAd *fakeFBInterstitialAd;

#pragma mark Google Ad Mob
@property (nonatomic, strong) GADRequest *fakeGADBannerRequest;
@property (nonatomic, strong) GADBannerView *fakeGADBannerView;
@property (nonatomic, strong) GADRequest *fakeGADInterstitialRequest;
@property (nonatomic, strong) GADInterstitial *fakeGADInterstitial;

#pragma mark Greystripe
@property (nonatomic, strong) FakeGSBannerAdView *fakeGSBannerAdView;
@property (nonatomic, strong) FakeGSFullscreenAd *fakeGSFullscreenAd;

#pragma mark InMobi
@property (nonatomic, strong) IMBanner *fakeIMAdView;
@property (nonatomic, strong) IMInterstitial *fakeIMAdInterstitial;

#pragma mark Build Fake MPWebViews
- (MPWebView *)buildMPWebViewWithFrame:(CGRect)frame delegate:(id<MPWebViewDelegate>)delegate;
- (MPWebView *)buildMPWebViewWithFrame:(CGRect)frame;

@end
