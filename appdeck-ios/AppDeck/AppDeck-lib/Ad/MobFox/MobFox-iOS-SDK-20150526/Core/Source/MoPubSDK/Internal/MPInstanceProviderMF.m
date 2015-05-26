//
//  MPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProviderMF.h"
#import "MPAdWebViewMF.h"
#import "MPAdWebViewAgentMF.h"
#import "MPInterstitialAdManagerMF.h"
#import "MPInterstitialCustomEventAdapterMF.h"
#import "MPLegacyInterstitialCustomEventAdapterMF.h"
#import "MPHTMLInterstitialViewControllerMF.h"
#import "MPMRAIDInterstitialViewControllerMF.h"
#import "MPInterstitialCustomEventMF.h"
#import "MPBaseBannerAdapterMF.h"
#import "MPBannerCustomEventAdapterMF.h"
#import "MPLegacyBannerCustomEventAdapterMF.h"
#import "MPBannerCustomEventMF.h"
#import "MPBannerAdManagerMF.h"
#import "MpLoggingMF.h"
#import "MRJavaScriptEventEmitterMF.h"
#import "MRImageDownloaderMF.h"
#import "MRBundleManagerMF.h"
#import "MRCalendarManagerMF.h"
#import "MRPictureManagerMF.h"
#import "MRVideoPlayerManagerMF.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MPNativeCustomEventMF.h"



@interface MPInstanceProviderMF ()

@property (nonatomic, retain) NSMutableDictionary *singletons;

@end


@implementation MPInstanceProviderMF

static MPInstanceProviderMF *sharedAdProvider = nil;

+ (instancetype)sharedProvider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedAdProvider = [[self alloc] init];
    });

    return sharedAdProvider;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.singletons = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.singletons = nil;
    [super dealloc];
}

- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider
{
    id singleton = [self.singletons objectForKey:klass];
    if (!singleton) {
        singleton = provider();
        [self.singletons setObject:singleton forKey:(id<NSCopying>)klass];
    }
    return singleton;
}

#pragma mark - Banners

- (MPBannerAdManagerMF *)buildMPBannerAdManagerWithDelegate:(id<MPBannerAdManagerDelegateMF>)delegate
{
    return [[(MPBannerAdManagerMF *)[MPBannerAdManagerMF alloc] initWithDelegate:delegate] autorelease];
}

- (MPBaseBannerAdapterMF *)buildBannerAdapterForConfiguration:(MPAdConfigurationMF *)configuration
                                                   delegate:(id<MPBannerAdapterDelegateMF>)delegate
{
    if (configuration.customEventClass) {
        return [[(MPBannerCustomEventAdapterMF *)[MPBannerCustomEventAdapterMF alloc] initWithDelegate:delegate] autorelease];
    } else if (configuration.customSelectorName) {
        return [[(MPLegacyBannerCustomEventAdapterMF *)[MPLegacyBannerCustomEventAdapterMF alloc] initWithDelegate:delegate] autorelease];
    }

    return nil;
}

- (MPBannerCustomEventMF *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegateMF>)delegate
{
    MPBannerCustomEventMF *customEvent = [[[customClass alloc] init] autorelease];
    if (![customEvent isKindOfClass:[MPBannerCustomEventMF class]]) {
        MPLogErrorMF(@"**** Custom Event Class: %@ does not extend MPBannerCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    customEvent.delegate = delegate;
    return customEvent;
}

#pragma mark - Interstitials

- (MPInterstitialAdManagerMF *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegateMF>)delegate
{
    return [[(MPInterstitialAdManagerMF *)[MPInterstitialAdManagerMF alloc] initWithDelegate:delegate] autorelease];
}


- (MPBaseInterstitialAdapterMF *)buildInterstitialAdapterForConfiguration:(MPAdConfigurationMF *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegateMF>)delegate
{
    if (configuration.customEventClass) {
        return [[(MPInterstitialCustomEventAdapterMF *)[MPInterstitialCustomEventAdapterMF alloc] initWithDelegate:delegate] autorelease];
    } else if (configuration.customSelectorName) {
        return [[(MPLegacyInterstitialCustomEventAdapterMF *)[MPLegacyInterstitialCustomEventAdapterMF alloc] initWithDelegate:delegate] autorelease];
    }

    return nil;
}

- (MPInterstitialCustomEventMF *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegateMF>)delegate
{
    MPInterstitialCustomEventMF *customEvent = [[[customClass alloc] init] autorelease];
    if (![customEvent isKindOfClass:[MPInterstitialCustomEventMF class]]) {
        MPLogErrorMF(@"**** Custom Event Class: %@ does not extend MPInterstitialCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    if ([customEvent respondsToSelector:@selector(customEventDidUnload)]) {
        MPLogWarnMF(@"**** Custom Event Class: %@ implements the deprecated -customEventDidUnload method.  This is no longer called.  Use -dealloc for cleanup instead ****", NSStringFromClass(customClass));
    }
    customEvent.delegate = delegate;
    return customEvent;
}

- (MPHTMLInterstitialViewControllerMF *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateMF>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate
{
    MPHTMLInterstitialViewControllerMF *controller = [[[MPHTMLInterstitialViewControllerMF alloc] init] autorelease];
    controller.delegate = delegate;
    controller.orientationType = type;
    controller.customMethodDelegate = customMethodDelegate;
    return controller;
}

- (MPMRAIDInterstitialViewControllerMF *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateMF>)delegate
                                                                            configuration:(MPAdConfigurationMF *)configuration
{
    MPMRAIDInterstitialViewControllerMF *controller = [[[MPMRAIDInterstitialViewControllerMF alloc] initWithAdConfiguration:configuration] autorelease];
    controller.delegate = delegate;
    return controller;
}

#pragma mark - HTML Ads

- (MPAdWebViewMF *)buildMPAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    MPAdWebViewMF *webView = [[[MPAdWebViewMF alloc] initWithFrame:frame] autorelease];
    webView.delegate = delegate;
    return webView;
}

- (MPAdWebViewAgentMF *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegateMF>)delegate customMethodDelegate:(id)customMethodDelegate
{
    return [[[MPAdWebViewAgentMF alloc] initWithAdWebViewFrame:frame delegate:delegate customMethodDelegate:customMethodDelegate] autorelease];
}

#pragma mark - MRAID

- (MRAdViewMF *)buildMRAdViewWithFrame:(CGRect)frame
                     allowsExpansion:(BOOL)allowsExpansion
                    closeButtonStyle:(MRAdViewCloseButtonStyle)style
                       placementType:(MRAdViewPlacementType)type
                            delegate:(id<MRAdViewDelegateMF>)delegate
{
    MRAdViewMF *mrAdView = [[[MRAdViewMF alloc] initWithFrame:frame allowsExpansion:allowsExpansion closeButtonStyle:style placementType:type] autorelease];
    mrAdView.delegate = delegate;
    return mrAdView;
}

- (MRBundleManagerMF *)buildMRBundleManager
{
    return [MRBundleManagerMF sharedManager];
}

- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame
{
    return [[[UIWebView alloc] initWithFrame:frame] autorelease];
}

- (MRJavaScriptEventEmitterMF *)buildMRJavaScriptEventEmitterWithWebView:(UIWebView *)webView
{
    return [[[MRJavaScriptEventEmitterMF alloc] initWithWebView:webView] autorelease];
}

- (MRCalendarManagerMF *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegateMF>)delegate
{
    return [[[MRCalendarManagerMF alloc] initWithDelegate:delegate] autorelease];
}

- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id<EKEventEditViewDelegate>)editViewDelegate
{
    EKEventEditViewController *controller = [[[EKEventEditViewController alloc] init] autorelease];
    controller.editViewDelegate = editViewDelegate;
    controller.eventStore = [self buildEKEventStore];
    return controller;
}

- (EKEventStore *)buildEKEventStore
{
    return [[[EKEventStore alloc] init] autorelease];
}

- (MRPictureManagerMF *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegateMF>)delegate
{
    return [[[MRPictureManagerMF alloc] initWithDelegate:delegate] autorelease];
}

- (MRImageDownloaderMF *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegateMF>)delegate
{
    return [[[MRImageDownloaderMF alloc] initWithDelegate:delegate] autorelease];
}

- (MRVideoPlayerManagerMF *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegateMF>)delegate
{
    return [[[MRVideoPlayerManagerMF alloc] initWithDelegate:delegate] autorelease];
}

- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL
{
    // ImageContext used to avoid CGErrors
    // http://stackoverflow.com/questions/13203336/iphone-mpmovieplayerviewcontroller-cgcontext-errors/14669166#14669166
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    MPMoviePlayerViewController *playerViewController = [[[MPMoviePlayerViewController alloc] initWithContentURL:URL] autorelease];
    UIGraphicsEndImageContext();

    return playerViewController;
}

#pragma mark - Native

- (MPNativeCustomEventMF *)buildNativeCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPNativeCustomEventDelegateMF>)delegate
{
    MPNativeCustomEventMF *customEvent = [[[customClass alloc] init] autorelease];
    if (![customEvent isKindOfClass:[MPNativeCustomEventMF class]]) {
        MPLogErrorMF(@"**** Custom Event Class: %@ does not extend MPNativeCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    customEvent.delegate = delegate;
    return customEvent;
}


@end

