#import "MPMillennialInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"


@interface MPInstanceProvider (MillennialInterstitials)

- (MMInterstitialAd *)buildMMInterstitialWithPlacementId:(NSString *)placementId;

@end

@implementation MPInstanceProvider (MillennialInterstitials)

- (MMInterstitialAd *)buildMMInterstitialWithPlacementId:(NSString *)placementId {
    return [[MMInterstitialAd alloc] initWithPlacementId:placementId];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMillennialInterstitialCustomEvent ()

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) BOOL didDisplay;
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, strong) MMInterstitialAd *interstitial;

@end


@implementation MPMillennialInterstitialCustomEvent

@synthesize interstitial = _interstitial;
@synthesize placementId = _placementId;
@synthesize didDisplay = _didDisplay;
@synthesize didTrackClick = _didTrackClick;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        if ( ![[MMSDK sharedInstance] isInitialized] ) {
            [[MMSDK sharedInstance] initializeWithSettings:[[MMAppSettings alloc] init] withUserSettings:[[MMUserSettings alloc] init]];
        }
    }
    return self;
}

- (void)dealloc
{
    [self invalidate];
}


- (void)invalidate
{
    self.delegate = nil;
    self.interstitial = nil;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSLog(@"Requesting Millennial interstitial");

    // If Custom Event Class Data contains DCN / Position, let's use that instead.
    // { "dcn": "...", "adUnitID": "..."  }
    self.placementId = [info objectForKey:@"adUnitID"];

    [[MMSDK sharedInstance] appSettings].mediator = @"MPMillennialInterstitialCustomEvent";
    if ( [info objectForKey:@"dcn"] ) {
        [[[MMSDK sharedInstance] appSettings] setSiteId:[info objectForKey:@"dcn"]];
    } else {
        [[[MMSDK sharedInstance] appSettings] setSiteId:nil];
    }

    if (!self.placementId || ![[MMSDK sharedInstance] isInitialized]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    [[MMSDK sharedInstance] setSendLocationIfAvailable:[[MoPub sharedInstance] locationUpdatesEnabled]];

    self.interstitial = [[MPInstanceProvider sharedProvider] buildMMInterstitialWithPlacementId:self.placementId];
    self.interstitial.delegate = self;

    [self.interstitial load:nil];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ( !self.didDisplay ) {
        [self.interstitial showFromViewController:rootViewController];
    } else {
        MPLogWarn(@"Interstitial already displayed!");
    }
}


#pragma mark - MMInterstitialDelegate methods:

- (void)interstitialAdLoadDidSucceed:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}


- (void)interstitialAd:(MMInterstitialAd *)ad loadDidFailWithError:(NSError *)error {
    if ( error.code == MMSDKErrorInterstitialAdAlreadyLoaded ) {
        MPLogInfo(@"Millennial interstitial already loaded-- not sending this request onto MM.");
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    } else {
        MPLogError(@"Millennial interstitial ad failed with error (%d) %@", error.code, error.description);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)interstitialAdWillDisplay:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstial will display.");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialAdDidDisplay:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
    [self.delegate trackImpression];
    self.didDisplay = YES;
}

- (void)interstitialAd:(MMInterstitialAd *)ad showDidFailWithError:(NSError *)error {
    MPLogInfo(@"Millennial -- show failed %i: %@", error.code, error.description);
    [self.delegate interstitialCustomEventDidExpire:self];
}


- (void)interstitialAdTapped:(MMInterstitialAd *)ad {
    // Dedupe code might be unnecessary, but just in case...
    if (!self.didTrackClick) {
        MPLogInfo(@"Millennial interstitial-- tracking click");
        [self.delegate trackClick];
        self.didTrackClick = YES;
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    } else {
        MPLogInfo(@"Millennial interstitial-- ignoring duplicate click");
    }
}

- (void)interstitialAdWillDismiss:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialAdDidDismiss:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
    [self.delegate interstitialCustomEventDidExpire:self];
    [self invalidate];
}

- (void)interstitialAdDidExpire:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial has expired.");
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (void)interstitialAdWillLeaveApplication:(MMInterstitialAd *)ad {
    MPLogInfo(@"Millennial interstitial leaving app...");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
