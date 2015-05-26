//
//  MPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPGlobalMF.h"
#import "MPCoreInstanceProviderMF.h"

// Banners
@class MPBannerAdManagerMF;
@protocol MPBannerAdManagerDelegateMF;
@class MPBaseBannerAdapterMF;
@protocol MPBannerAdapterDelegateMF;
@class MPBannerCustomEventMF;
@protocol MPBannerCustomEventDelegateMF;

// Interstitials
@class MPInterstitialAdManagerMF;
@protocol MPInterstitialAdManagerDelegateMF;
@class MPBaseInterstitialAdapterMF;
@protocol MPInterstitialAdapterDelegateMF;
@class MPInterstitialCustomEventMF;
@protocol MPInterstitialCustomEventDelegateMF;
@class MPHTMLInterstitialViewControllerMF;
@class MPMRAIDInterstitialViewControllerMF;
@protocol MPInterstitialViewControllerDelegateMF;

// HTML Ads
@class MPAdWebViewMF;
@class MPAdWebViewAgentMF;
@protocol MPAdWebViewAgentDelegateMF;

// MRAID
@class MRAdViewMF;
@protocol MRAdViewDelegateMF;
@class MRBundleManagerMF;
@class MRJavaScriptEventEmitterMF;
@class MRCalendarManagerMF;
@protocol MRCalendarManagerDelegateMF;
@class EKEventStore;
@class EKEventEditViewController;
@protocol EKEventEditViewDelegate;
@class MRPictureManagerMF;
@protocol MRPictureManagerDelegateMF;
@class MRImageDownloaderMF;
@protocol MRImageDownloaderDelegateMF;
@class MRVideoPlayerManagerMF;
@protocol MRVideoPlayerManagerDelegateMF;
@class MPMoviePlayerViewController;

//Native
@protocol MPNativeCustomEventDelegateMF;
@class MPNativeCustomEventMF;


@interface MPInstanceProviderMF : NSObject

+(instancetype)sharedProvider;
- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider;

#pragma mark - Banners
- (MPBannerAdManagerMF *)buildMPBannerAdManagerWithDelegate:(id<MPBannerAdManagerDelegateMF>)delegate;
- (MPBaseBannerAdapterMF *)buildBannerAdapterForConfiguration:(MPAdConfigurationMF *)configuration
                                                   delegate:(id<MPBannerAdapterDelegateMF>)delegate;
- (MPBannerCustomEventMF *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegateMF>)delegate;

#pragma mark - Interstitials
- (MPInterstitialAdManagerMF *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegateMF>)delegate;
- (MPBaseInterstitialAdapterMF *)buildInterstitialAdapterForConfiguration:(MPAdConfigurationMF *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegateMF>)delegate;
- (MPInterstitialCustomEventMF *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegateMF>)delegate;
- (MPHTMLInterstitialViewControllerMF *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateMF>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate;
- (MPMRAIDInterstitialViewControllerMF *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateMF>)delegate
                                                                            configuration:(MPAdConfigurationMF *)configuration;

#pragma mark - HTML Ads
- (MPAdWebViewMF *)buildMPAdWebViewWithFrame:(CGRect)frame
                                  delegate:(id<UIWebViewDelegate>)delegate;
- (MPAdWebViewAgentMF *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame
                                                     delegate:(id<MPAdWebViewAgentDelegateMF>)delegate
                                         customMethodDelegate:(id)customMethodDelegate;

#pragma mark - MRAID
- (MRAdViewMF *)buildMRAdViewWithFrame:(CGRect)frame
                     allowsExpansion:(BOOL)allowsExpansion
                    closeButtonStyle:(NSUInteger)style
                       placementType:(NSUInteger)type
                            delegate:(id<MRAdViewDelegateMF>)delegate;
- (MRBundleManagerMF *)buildMRBundleManager;
- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame;
- (MRJavaScriptEventEmitterMF *)buildMRJavaScriptEventEmitterWithWebView:(UIWebView *)webView;
- (MRCalendarManagerMF *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegateMF>)delegate;
- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id<EKEventEditViewDelegate>)editViewDelegate;
- (EKEventStore *)buildEKEventStore;
- (MRPictureManagerMF *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegateMF>)delegate;
- (MRImageDownloaderMF *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegateMF>)delegate;
- (MRVideoPlayerManagerMF *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegateMF>)delegate;
- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL;

#pragma mark - Native

- (MPNativeCustomEventMF *)buildNativeCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPNativeCustomEventDelegateMF>)delegate;


@end
