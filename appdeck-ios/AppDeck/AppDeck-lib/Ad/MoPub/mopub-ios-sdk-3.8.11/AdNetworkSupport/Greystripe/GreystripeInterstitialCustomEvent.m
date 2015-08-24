//
//  GreystripeInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "GSFullscreenAd.h"
#import "GSAdDelegate.h"
#import "GreystripeInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"
#import "GSSDKInfo.h"

@interface MPInstanceProvider (GreystripeInterstitials)

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;

@end

@implementation MPInstanceProvider (GreystripeInterstitials)

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    return [[GSFullscreenAd alloc] initWithDelegate:delegate GUID:GUID];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

static NSString *gGUID = nil;

#define kGreystripeGUID @"YOUR_GREYSTRIPE_GUID"

@interface GreystripeInterstitialCustomEvent () <GSAdDelegate>

@property (nonatomic, strong) GSFullscreenAd *greystripeFullscreenAd;

@end

@implementation GreystripeInterstitialCustomEvent

@synthesize greystripeFullscreenAd = _greystripeFullscreenAd;

+ (void)setGUID:(NSString *)GUID
{
    MPLogWarn(@"+setGUID for class GreystripeInterstitialCustomEvent is deprecated. Use the GUID parameter when configuring your network in the MoPub website.");
    gGUID = [GUID copy];
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Greystripe interstitial");

    NSString *GUID = [info objectForKey:@"GUID"];
    if (GUID == nil) {
        GUID = gGUID;
        if ([GUID length] == 0) {
            MPLogWarn(@"Setting kGreystripeGUID in GreystripeBannerCustomEvent.m is deprecated. Use the GUID parameter when configuring your network in the MoPub website.");
            GUID = kGreystripeGUID;
        }
    }

    self.greystripeFullscreenAd = [[MPInstanceProvider sharedProvider] buildGSFullscreenAdWithDelegate:self GUID:GUID];

    if (self.delegate.location) {
        [GSSDKInfo updateLocation:self.delegate.location];
    }

    [self.greystripeFullscreenAd fetch];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([self.greystripeFullscreenAd isAdReady]) {
        [self.greystripeFullscreenAd displayFromViewController:rootViewController];
    } else {
        MPLogInfo(@"Failed to show Greystripe interstitial: a previously loaded Greystripe interstitial now claims not to be ready.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)dealloc
{
    [self.greystripeFullscreenAd setDelegate:nil];
}

#pragma mark - GSAdDelegate

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad
{
    MPLogInfo(@"Greystripe interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:a_ad];
}

- (void)greystripeAdFetchFailed:(id<GSAd>)a_ad withError:(GSAdError)a_error
{
    MPLogInfo(@"Greystripe banner failed to load with GSAdError: %d", a_error);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)greystripeAdClickedThrough:(id<GSAd>)a_ad
{
    MPLogInfo(@"Greystripe interstitial was clicked");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)greystripeWillPresentModalViewController
{
    MPLogInfo(@"Greystripe interstitial will present");

    [self.delegate interstitialCustomEventWillAppear:self];

    // Greystripe doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)greystripeWillDismissModalViewController
{
    MPLogInfo(@"Greystripe interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)greystripeDidDismissModalViewController
{
    MPLogInfo(@"Greystripe interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
