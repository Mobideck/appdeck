//
//  FakeMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPInstanceProvider.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPWebView.h"
#import "FakeMPTimer.h"
#import "MRBundleManager.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface MPInstanceProvider (ThirdPartyAdditions)

#pragma mark - Third Party Integrations Category Interfaces

#pragma mark Chartboost
- (Chartboost *)buildChartboost;

#pragma mark Facebook
- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID
                                      size:(FBAdSize)size
                        rootViewController:(UIViewController *)controller
                                  delegate:(id<FBAdViewDelegate>)delegate;
- (FBInterstitialAd *)buildFBInterstitialAdWithPlacementID:(NSString *)placementID
                                                  delegate:(id<FBInterstitialAdDelegate>)delegate;

#pragma mark Google Ad Mob
- (GADRequest *)buildGADBannerRequest;
- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame;
- (GADRequest *)buildGADInterstitialRequest;
- (GADInterstitial *)buildGADInterstitialAd;

#pragma mark Greystripe
- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;
- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;

#pragma mark InMobi
- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize;
- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId;

@end

@implementation FakeMPInstanceProvider

- (id)returnFake:(id)fake orCall:(IDReturningBlock)block
{
    if (fake) {
        return fake;
    } else {
        return block();
    }
}

#pragma mark - Banners

- (MPBaseBannerAdapter *)buildBannerAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                   delegate:(id<MPBannerAdapterDelegate>)delegate
{
    if (self.fakeBannerAdapter) {
        self.fakeBannerAdapter.delegate = delegate;
        return self.fakeBannerAdapter;
    } else {
        return [super buildBannerAdapterForConfiguration:configuration
                                                delegate:delegate];
    }
}

- (MPBannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegate>)delegate
{
    if (self.fakeBannerCustomEvent) {
        self.fakeBannerCustomEvent.delegate = delegate;
        return self.fakeBannerCustomEvent;
    }

    return [super buildBannerCustomEventFromCustomClass:customClass delegate:delegate];
}

#pragma mark - Interstitials
- (MPInterstitialAdManager *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMPInterstitialAdManager
                     orCall:^{
                         return [super buildMPInterstitialAdManagerWithDelegate:delegate];
                     }];
}

- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegate>)delegate
{
    if (self.fakeInterstitialAdapter) {
        self.fakeInterstitialAdapter.delegate = delegate;
        return self.fakeInterstitialAdapter;
    } else {
        return [super buildInterstitialAdapterForConfiguration:configuration
                                                      delegate:delegate];
    }
}

- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate
{
    if (self.fakeInterstitialCustomEvent) {
        self.fakeInterstitialCustomEvent.delegate = delegate;
        return self.fakeInterstitialCustomEvent;
    }

    return [super buildInterstitialCustomEventFromCustomClass:customClass delegate:delegate];
}

- (MPHTMLInterstitialViewController *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate orientationType:(MPInterstitialOrientationType)type
{
    return [self returnFake:self.fakeMPHTMLInterstitialViewController
                     orCall:^{
                         return [super buildMPHTMLInterstitialViewControllerWithDelegate:delegate orientationType:type];
                     }];
}

- (MPMRAIDInterstitialViewController *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate configuration:(MPAdConfiguration *)configuration
{
    return [self returnFake:self.fakeMPMRAIDInterstitialViewController
                     orCall:^{
                         return [super buildMPMRAIDInterstitialViewControllerWithDelegate:delegate
                                                                            configuration:configuration];
                     }];
}

#pragma mark - Rewarded Video
- (MPRewardedVideoAdManager *)buildRewardedVideoAdManagerWithAdUnitID:(NSString *)adUnitID delegate:(id<MPRewardedVideoAdManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMPRewardedVideoAdManager
                     orCall:^{
                         return [super buildRewardedVideoAdManagerWithAdUnitID:adUnitID delegate:delegate];
                     }];
}

- (MPRewardedVideoAdapter *)buildRewardedVideoAdapterWithDelegate:(id<MPRewardedVideoAdapterDelegate>)delegate
{
    return [self returnFake:self.fakeMPRewardedVideoAdapter
                     orCall:^{
                         return [super buildRewardedVideoAdapterWithDelegate:delegate];
                     }];
}

- (MPRewardedVideoCustomEvent *)buildRewardedVideoCustomEventFromCustomClass:(Class)aClass delegate:(id<MPRewardedVideoCustomEventDelegate>)delegate
{
    return [self returnFake:self.fakeMPRewardedVideoCustomEvent
                     orCall:^{
                         return [super buildRewardedVideoCustomEventFromCustomClass:aClass delegate:delegate];
                     }];
}
#pragma mark - HTML Ads

- (MPWebView *)buildMPWebViewWithFrame:(CGRect)frame delegate:(id<MPWebViewDelegate>)delegate
{
    if (self.fakeMPWebView) {
        self.fakeMPWebView.frame = frame;
        self.fakeMPWebView.delegate = delegate;
        return self.fakeMPWebView;
    } else {
        MPWebView *newWebView = [[MPWebView alloc] initWithFrame:frame];
        newWebView.delegate = delegate;

        return newWebView;
    }
}

- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegate>)delegate
{
    return [self returnFake:self.fakeMPAdWebViewAgent
                     orCall:^{
                         return [super buildMPAdWebViewAgentWithAdWebViewFrame:frame
                                                                      delegate:delegate];
                     }];
}

#pragma mark - MRAID

- (MPClosableView *)buildMRAIDMPClosableViewWithFrame:(CGRect)frame webView:(MPWebView *)webView delegate:(id<MPClosableViewDelegate>)delegate
{
    if (self.fakeMRAIDMPClosableView != nil) {
        return self.fakeMRAIDMPClosableView;
    } else {
        return [super buildMRAIDMPClosableViewWithFrame:frame webView:webView delegate:delegate];
    }
}

- (MRController *)buildBannerMRControllerWithFrame:(CGRect)frame delegate:(id<MRControllerDelegate>)delegate
{
    if (self.fakeMRController) {
        self.fakeMRController.delegate = delegate;
        return self.fakeMRController;
    } else {
        return [super buildBannerMRControllerWithFrame:frame delegate:delegate];
    }
}

- (MRController *)buildInterstitialMRControllerWithFrame:(CGRect)frame delegate:(id<MRControllerDelegate>)delegate
{
    if (self.fakeMRController) {
        self.fakeMRController.delegate = delegate;
        return self.fakeMRController;
    } else {
        return [super buildInterstitialMRControllerWithFrame:frame delegate:delegate];
    }
}

- (MRBundleManager *)buildMRBundleManager
{
    return [self returnFake:self.fakeMRBundleManager
                     orCall:^{
                         return [super buildMRBundleManager];
                     }];
}

- (MRBridge *)buildMRBridgeWithWebView:(MPWebView *)webView delegate:(id<MRBridgeDelegate>)delegate
{
    return [self returnFake:self.fakeMRBridge
                     orCall:^{
                         return [super buildMRBridgeWithWebView:webView delegate:delegate];
                     }];
}

- (MPWebView *)buildMPWebViewWithFrame:(CGRect)frame
{
    return [self buildMPWebViewWithFrame:frame delegate:nil];
}

- (MRVideoPlayerManager *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMRVideoPlayerManager
                     orCall:^{
                         return [super buildMRVideoPlayerManagerWithDelegate:delegate];
                     }];
}

- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL
{
    return [self returnFake:self.fakeMoviePlayerViewController
                     orCall:^{
                         return [super buildMPMoviePlayerViewControllerWithURL:URL];
                     }];
}

- (MRNativeCommandHandler *)buildMRNativeCommandhandlerWithDelegate:(id<MRNativeCommandHandlerDelegate>)delegate
{
    return [self returnFake:self.fakeNativeCommandHandler
                     orCall:^{
                         return [super buildMRNativeCommandHandlerWithDelegate:delegate];
                     }];
}

#pragma mark - Native

- (MPNativeAdSource *)buildNativeAdSourceWithDelegate:(id<MPNativeAdSourceDelegate>)delegate
{
    if (self.fakeNativeAdSource) {
        self.fakeNativeAdSource.delegate = delegate;
        return self.fakeNativeAdSource;
    } else {
        return [super buildNativeAdSourceWithDelegate:delegate];
    }
}

- (MPNativePositionSource *)buildNativePositioningSource
{
    return [self returnFake:self.fakeNativePositioningSource
                     orCall:^{
                         return [super buildNativePositioningSource];
                     }];
}

- (MPStreamAdPlacementData *)buildStreamAdPlacementDataWithPositioning:(MPAdPositioning *)positioning
{
    return [self returnFake:self.fakeStreamAdPlacementData
                     orCall:^{
                         return [super buildStreamAdPlacementDataWithPositioning:positioning];
                     }];
}

- (MPStreamAdPlacer *)buildStreamAdPlacerWithViewController:(UIViewController *)controller adPositioning:(MPAdPositioning *)positioning rendererConfigurations:(NSArray *)rendererConfigurations
{
    return [self returnFake:self.fakeStreamAdPlacer
                     orCall:^{
                         return [super buildStreamAdPlacerWithViewController:controller adPositioning:positioning rendererConfigurations:rendererConfigurations];
                     }];
}

#pragma mark - Third Party Integrations

#pragma mark - Facebook

- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID size:(FBAdSize)size rootViewController:(UIViewController *)controller delegate:(id<FBAdViewDelegate>)delegate
{
    if (self.fakeFBAdView) {
        self.fakeFBAdView.delegate = delegate;
        return self.fakeFBAdView;
    } else {
        return [super buildFBAdViewWithPlacementID:placementID size:size rootViewController:controller delegate:delegate];
    }
}

- (FBInterstitialAd *)buildFBInterstitialAdWithPlacementID:(NSString *)placementID
                                                  delegate:(id<FBInterstitialAdDelegate>)delegate
{
    if (self.fakeFBInterstitialAd) {
        self.fakeFBInterstitialAd.delegate = delegate;
        return self.fakeFBInterstitialAd;
    } else {
        return [super buildFBInterstitialAdWithPlacementID:placementID delegate:delegate];
    }
}

#pragma mark Google Ad Mob

- (GADRequest *)buildGADBannerRequest
{
    return [self returnFake:self.fakeGADBannerRequest
                     orCall:^{
                         return [super buildGADBannerRequest];
                     }];
}

- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame
{
    return [self returnFake:self.fakeGADBannerView
                     orCall:^{
                         return [super buildGADBannerViewWithFrame:frame];
                     }];
}

- (GADRequest *)buildGADInterstitialRequest
{
    return [self returnFake:self.fakeGADInterstitialRequest
                     orCall:^{
                         return [super buildGADInterstitialRequest];
                     }];
}

- (GADInterstitial *)buildGADInterstitialAd
{
    return [self returnFake:self.fakeGADInterstitial
                     orCall:^{
                         return [super buildGADInterstitialAd];
                     }];
}

#pragma mark Greystripe

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;
{
    if (self.fakeGSBannerAdView) {
        self.fakeGSBannerAdView.delegate = delegate;
        self.fakeGSBannerAdView.GUID = GUID;
        return self.fakeGSBannerAdView;
    } else {
        return [super buildGreystripeBannerAdViewWithDelegate:delegate GUID:GUID size:size];
    }
}

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    if (self.fakeGSFullscreenAd) {
        self.fakeGSFullscreenAd.delegate = delegate;
        self.fakeGSFullscreenAd.GUID = GUID;
        return self.fakeGSFullscreenAd;
    } else {
        return [super buildGSFullscreenAdWithDelegate:delegate GUID:GUID];
    }
}

#pragma mark InMobi

- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize
{
    if (self.fakeIMAdView) {
        self.fakeIMAdView.frame = frame;
        self.fakeIMAdView.appId = appId;
        self.fakeIMAdView.adSize = adSize;
        return self.fakeIMAdView;
    }
    return [super buildIMBannerWithFrame:frame appId:appId adSize:adSize];
}

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId
{
    if (self.fakeIMAdInterstitial) {
        self.fakeIMAdInterstitial.appId = appId;
        self.fakeIMAdInterstitial.delegate = delegate;
        return self.fakeIMAdInterstitial;
    }
    return [super buildIMInterstitialWithDelegate:delegate appId:appId];
}

@end
