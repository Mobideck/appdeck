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
#import "Chartboost.h"
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

@class MRJavaScriptEventEmitter;
@class MRCalendarManager;
@class EKEventStore;
@class EKEventEditViewController;
@class MRPictureManager;
@class MRVideoPlayerManager;
@class MPMoviePlayerViewController;
@class MRBundleManager;
@class MRAdView;

@interface FakeMPInstanceProvider : MPInstanceProvider

#pragma mark - Banners
@property (nonatomic, assign) MPBaseBannerAdapter *fakeBannerAdapter;
@property (nonatomic, assign) FakeBannerCustomEvent *fakeBannerCustomEvent;

#pragma mark - Interstitials
@property (nonatomic, assign) MPInterstitialAdManager *fakeMPInterstitialAdManager;
@property (nonatomic, assign) MPBaseInterstitialAdapter *fakeInterstitialAdapter;
@property (nonatomic, assign) FakeInterstitialCustomEvent *fakeInterstitialCustomEvent;
@property (nonatomic, assign) MPHTMLInterstitialViewController *fakeMPHTMLInterstitialViewController;
@property (nonatomic, assign) MPMRAIDInterstitialViewController *fakeMPMRAIDInterstitialViewController;

#pragma mark - HTML Ads
@property (nonatomic, assign) MPAdWebView *fakeMPAdWebView;
@property (nonatomic, assign) MPAdWebViewAgent *fakeMPAdWebViewAgent;

#pragma mark - MRAID
@property (nonatomic, assign) MRAdView *fakeMRAdView;
@property (nonatomic, assign) MRBundleManager *fakeMRBundleManager;
@property (nonatomic, assign) UIWebView *fakeUIWebView;
@property (nonatomic, assign) MRJavaScriptEventEmitter *fakeMRJavaScriptEventEmitter;
@property (nonatomic, assign) MRCalendarManager *fakeMRCalendarManager;
@property (nonatomic, assign) EKEventEditViewController *fakeEKEventEditViewController;
@property (nonatomic, assign) EKEventStore *fakeEKEventStore;
@property (nonatomic, assign) MRPictureManager *fakeMRPictureManager;
@property (nonatomic, assign) MRImageDownloader *fakeImageDownloader;
@property (nonatomic, assign) MRVideoPlayerManager *fakeMRVideoPlayerManager;
@property (nonatomic, assign) MPMoviePlayerViewController *fakeMoviePlayerViewController;

#pragma mark - Third Party Integrations

#pragma mark iAd
@property (nonatomic, assign) ADBannerView *fakeADBannerView;
@property (nonatomic, assign) ADInterstitialAd *fakeADInterstitialAd;

#pragma mark Chartboost
@property (nonatomic, assign) Chartboost *fakeChartboost;

#pragma mark Facebook
@property (nonatomic, assign) FBAdView *fakeFBAdView;
@property (nonatomic, assign) FBInterstitialAd *fakeFBInterstitialAd;

#pragma mark Google Ad Mob
@property (nonatomic, assign) GADRequest *fakeGADBannerRequest;
@property (nonatomic, assign) GADBannerView *fakeGADBannerView;
@property (nonatomic, assign) GADRequest *fakeGADInterstitialRequest;
@property (nonatomic, assign) GADInterstitial *fakeGADInterstitial;

#pragma mark Greystripe
@property (nonatomic, assign) FakeGSBannerAdView *fakeGSBannerAdView;
@property (nonatomic, assign) FakeGSFullscreenAd *fakeGSFullscreenAd;

#pragma mark InMobi
@property (nonatomic, assign) IMBanner *fakeIMAdView;
@property (nonatomic, assign) IMInterstitial *fakeIMAdInterstitial;

#pragma mark Millennial
@property (nonatomic, assign) FakeMMAdView *fakeMMAdView;
@property (nonatomic, assign) FakeMMInterstitial *fakeMMInterstitial;

@end
