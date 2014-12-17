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
#import <iAd/iAd.h>
#import "GADInterstitial.h"
#import "GADBannerView.h"
#import "FakeMMInterstitial.h"
#import "FakeInterstitialCustomEvent.h"
#import <Chartboost/Chartboost.h>
#import "FakeGSFullscreenAd.h"
#import "IMInterstitial.h"
#import "IMBanner.h"
#import "MPInterstitialAdManager.h"
#import "GADRequest.h"
#import "FakeMMAdView.h"
#import "FakeMPReachability.h"
#import "FakeGSBannerAdView.h"
#import "MPBaseBannerAdapter.h"
#import "FakeBannerCustomEvent.h"
#import "FakeMPTimer.h"
#import "FakeMPAdAlertManager.h"
#import "FakeMPAdAlertGestureRecognizer.h"
#import "FakeMRAdView.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <Foundation/Foundation.h>
#import "MPNativeAdSource.h"
#import "MPNativePositionSource.h"
#import "MPStreamAdPlacer.h"
#import "FakeMPStreamAdPlacer.h"

@class MRJavaScriptEventEmitter;
@class MRCalendarManager;
@class EKEventStore;
@class EKEventEditViewController;
@class MRPictureManager;
@class MRVideoPlayerManager;
@class MPMoviePlayerViewController;
@class MRBundleManager;
@class MRAdView;
@class MPStreamAdPlacementData;

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

#pragma mark - HTML Ads
@property (nonatomic, strong) MPAdWebView *fakeMPAdWebView;
@property (nonatomic, strong) MPAdWebViewAgent *fakeMPAdWebViewAgent;

#pragma mark - MRAID
@property (nonatomic, strong) MRAdView *fakeMRAdView;
@property (nonatomic, strong) MRBundleManager *fakeMRBundleManager;
@property (nonatomic, strong) UIWebView *fakeUIWebView;
@property (nonatomic, strong) MRJavaScriptEventEmitter *fakeMRJavaScriptEventEmitter;
@property (nonatomic, strong) MRCalendarManager *fakeMRCalendarManager;
@property (nonatomic, strong) EKEventEditViewController *fakeEKEventEditViewController;
@property (nonatomic, strong) EKEventStore *fakeEKEventStore;
@property (nonatomic, strong) MRPictureManager *fakeMRPictureManager;
@property (nonatomic, strong) MRImageDownloader *fakeImageDownloader;
@property (nonatomic, strong) MRVideoPlayerManager *fakeMRVideoPlayerManager;
@property (nonatomic, strong) MPMoviePlayerViewController *fakeMoviePlayerViewController;

#pragma mark - Native
@property (nonatomic, strong) MPNativeAdSource *fakeNativeAdSource;
@property (nonatomic, strong) MPNativePositionSource *fakeNativePositioningSource;
@property (nonatomic, strong) MPStreamAdPlacementData *fakeStreamAdPlacementData;
@property (nonatomic, strong) MPStreamAdPlacer *fakeStreamAdPlacer;

#pragma mark - Third Party Integrations

#pragma mark iAd
@property (nonatomic, strong) ADBannerView *fakeADBannerView;
@property (nonatomic, strong) ADInterstitialAd *fakeADInterstitialAd;

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

#pragma mark Millennial
@property (nonatomic, strong) FakeMMAdView *fakeMMAdView;
@property (nonatomic, strong) FakeMMInterstitial *fakeMMInterstitial;

@end
