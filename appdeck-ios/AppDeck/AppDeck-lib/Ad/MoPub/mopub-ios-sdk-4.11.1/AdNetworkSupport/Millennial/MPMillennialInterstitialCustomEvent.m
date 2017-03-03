//
//  MPMillennialInterstitialCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MPMillennialInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

@implementation MPInstanceProvider (MillennialInterstitials)

- (MMInterstitialAd *)buildMMInterstitialWithPlacementId:(NSString *)placementId {
    return [[MMInterstitialAd alloc] initWithPlacementId:placementId];
}

@end

@interface MPMillennialInterstitialCustomEvent ()

@property (nonatomic, assign) BOOL didDisplay;
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) MMInterstitialAd *interstitial;

@end


@implementation MPMillennialInterstitialCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (id)init {
    self = [super init];
    if (self) {
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0) {
            MMSDK *mmSDK = [MMSDK sharedInstance];
            if ([mmSDK isInitialized] == NO) {
                MMAppSettings *appSettings = [[MMAppSettings alloc] init];
                [mmSDK initializeWithSettings:appSettings withUserSettings:nil];
            }
        } else {
            self = nil; // No support below minimum OS.
        }
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

- (void)invalidate {
    self.delegate = nil;
    self.interstitial = nil;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary<NSString *, id> *)info {

    MMSDK *mmSDK = [MMSDK sharedInstance];

    if (![mmSDK isInitialized]) {

        MPLogError(@"Millennial adapter not properly intialized yet.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    NSString *placementId = info[kMoPubMMAdapterAdUnit];

    if (!placementId) {
        MPLogError(@"Millennial received invalid placement ID. Request failed.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    [mmSDK appSettings].mediator = NSStringFromClass([MPMillennialInterstitialCustomEvent class]);
    if (info[kMoPubMMAdapterDCN]) {
        [mmSDK appSettings].siteId = info[kMoPubMMAdapterDCN];
    } else {
        [mmSDK appSettings].siteId = nil;
    }

    self.interstitial = [[MPInstanceProvider sharedProvider] buildMMInterstitialWithPlacementId:placementId];
    self.interstitial.delegate = self;

    [self.interstitial load:nil];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if (!self.didDisplay) {
        [self.interstitial showFromViewController:rootViewController];
    } else {
        MPLogWarn(@"Interstitial already displayed.");
    }
}

#pragma mark - MMInterstitialDelegate

- (void)interstitialAdLoadDidSucceed:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ did load.", ad);
    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
}

- (void)interstitialAd:(MMInterstitialAd *)ad loadDidFailWithError:(NSError *)error {
    if (error.code == MMSDKErrorInterstitialAdAlreadyLoaded) {
        MPLogInfo(@"Millennial interstitial %@ already loaded, ignoring this request.", ad);
        [self.delegate interstitialCustomEvent:self didLoadAd:ad];
    } else {
        MPLogError(@"Millennial interstitial %@ failed with error (%d) %@.", ad, error.code, error.description);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)interstitialAdWillDisplay:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstial %@ will display.", ad);
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialAdDidDisplay:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ did appear.", ad);
    [self.delegate interstitialCustomEventDidAppear:self];
    [self.delegate trackImpression];
    self.didDisplay = YES;
}

- (void)interstitialAd:(MMInterstitialAd *)ad showDidFailWithError:(NSError *)error {
    MPLogInfo(@"Millennial interstitial %@ show failed %i: %@", ad, error.code, error.description);
    [self.delegate interstitialCustomEventDidExpire:self];
}


- (void)interstitialAdTapped:(MMInterstitialAd *)ad {
    if (!self.didTrackClick) {
        MPLogInfo(@"Millennial interstitial %@ tracking click.", ad);
        [self.delegate trackClick];
        self.didTrackClick = YES;
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    } else {
        MPLogInfo(@"Millennial interstitial %@ ignoring duplicate click.", ad);
    }
}

- (void)interstitialAdWillDismiss:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ will dismiss.", ad);
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialAdDidDismiss:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ did dismiss.", ad);
    [self.delegate interstitialCustomEventDidDisappear:self];
    [self.delegate interstitialCustomEventDidExpire:self];
    [self invalidate];
}

- (void)interstitialAdDidExpire:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ has expired.", ad);
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (void)interstitialAdWillLeaveApplication:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial %@ leaving app.", ad);
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
