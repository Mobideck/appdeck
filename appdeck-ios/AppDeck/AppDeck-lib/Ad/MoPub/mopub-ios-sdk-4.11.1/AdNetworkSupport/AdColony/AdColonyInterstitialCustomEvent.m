//
//  AdColonyInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>
#import "AdColonyInterstitialCustomEvent.h"
#import "MPAdColonyRouter.h"
#import "MPInstanceProvider+AdColony.h"
#import "MPLogging.h"
#import "AdColonyCustomEvent.h"

static NSString *gAppId = nil;
static NSString *gDefaultZoneId = nil;
static NSArray *gAllZoneIds = nil;

#define kAdColonyAppId @"YOUR_ADCOLONY_APPID"
#define kAdColonyDefaultZoneId @"YOUR_ADCOLONY_DEFAULT_ZONEID" // This zone id will be used if "zoneId" is not passed through the custom info dictionary

#define AdColonyZoneIds() [NSArray arrayWithObjects:@"YOUR_ADCOLONY_ZONEID1", @"YOUR_ADCOLONY_ZONEID2", nil]

@interface AdColonyInterstitialCustomEvent () <AdColonyAdDelegate, MPAdColonyRouterDelegate>

@property (nonatomic, copy) NSString *zoneId;
@property (nonatomic, assign) BOOL zoneAvailable;

@end

@implementation AdColonyInterstitialCustomEvent

@synthesize zoneId = _zoneId;

+ (void)setAppId:(NSString *)appId
{
    MPLogWarn(@"+setAppId for class AdColonyInterstitialCustomEvent is deprecated. Use the appId parameter when configuring your network in the MoPub website.");
    gAppId = [appId copy];
}

+ (void)setDefaultZoneId:(NSString *)defaultZoneId
{
    MPLogWarn(@"+setDefaultZoneId for class AdColonyInterstitialCustomEvent is deprecated. Use the zoneId parameter when configuring your network in the MoPub website.");
    gDefaultZoneId = [defaultZoneId copy];
}

+ (void)setAllZoneIds:(NSArray *)zoneIds
{
    MPLogWarn(@"+setAllZoneIds for class AdColonyInterstitialCustomEvent is deprecated. Use the allZoneIds parameter when configuring your network in the MoPub website.");
    gAllZoneIds = zoneIds;
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSString *appId = [info objectForKey:@"appId"];
    if(appId == nil)
    {
        appId = gAppId;

        if ([appId length] == 0) {
            MPLogWarn(@"Setting kAdColonyAppId in AdColonyInterstitialCustomEvent.m is deprecated. Use the appId parameter when configuring your network in the MoPub website.");
            appId = kAdColonyAppId;
        }
    }

    NSArray *allZoneIds = [info objectForKey:@"allZoneIds"];
    if(allZoneIds.count == 0)
    {
        allZoneIds = gAllZoneIds;

        if ([allZoneIds count] == 0) {
            MPLogWarn(@"Setting AdColonyZoneIds in AdColonyInterstitialCustomEvent.m is deprecated. Use the allZoneIds parameter when configuring your network in the MoPub website.");
            allZoneIds = AdColonyZoneIds();
        }
    }

    [AdColonyCustomEvent initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds customerId:nil];

    NSString *zoneId = [info objectForKey:@"zoneId"];
    if(zoneId == nil)
    {
        zoneId = gDefaultZoneId;

        if ([zoneId length] == 0) {
            MPLogWarn(@"Setting kAdColonyDefaultZoneId in AdColonyInterstitialCustomEvent.m is deprecated. Use the zondId parameter when configuring your network in the MoPub website.");
            zoneId = kAdColonyDefaultZoneId;
        }
    }

    self.zoneId = zoneId;
    self.zoneAvailable = NO;

    if(self.zoneId != nil && appId != nil)
    {
        [[MPAdColonyRouter sharedRouter] setCustomEvent:self forZoneId:self.zoneId];
    }

    if([AdColony zoneStatusForZone:self.zoneId] == ADCOLONY_ZONE_STATUS_ACTIVE)
    {
        MPLogInfo(@"AdColony zone %@ available", self.zoneId);
        [self zoneDidLoad];
    }

    // let AdColony inform us when the zone becomes available
}
- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([AdColony zoneStatusForZone:self.zoneId] == ADCOLONY_ZONE_STATUS_ACTIVE)
    {
        MPLogInfo(@"AdColony zone %@ attempting to start", self.zoneId);
        [AdColony playVideoAdForZone:self.zoneId withDelegate:self];
        [self.delegate interstitialCustomEventWillAppear:self];
    }
    else
    {
        MPLogInfo(@"Failed to show AdColony video interstitial: AdColony now claims zone %@ is not available", self.zoneId);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)invalidate
{
    [[MPAdColonyRouter sharedRouter] removeCustomEvent:self forZoneId:self.zoneId];
}

#pragma mark - MPAdColonyRouterDelegate

- (void)zoneDidLoad
{
    self.zoneAvailable = YES;
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)zoneDidExpire
{
    self.zoneAvailable = NO;
    [self.delegate interstitialCustomEventDidExpire:self];
}

#pragma mark - AdColonyAdDelegate

- (void)onAdColonyAdStartedInZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ started", zoneID);
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ finished", zoneID);
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
