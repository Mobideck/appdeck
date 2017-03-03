//
//  AdColonyRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>

#import "AdColonyRewardedVideoCustomEvent.h"
#import "AdColonyInstanceMediationSettings.h"
#import "AdColonyCustomEvent.h"
#import "MoPub.h"
#import "MPAdColonyRouter.h"
#import "MPInstanceProvider+AdColony.h"
#import "MPLogging.h"
#import "MPRewardedVideoReward.h"

@interface AdColonyRewardedVideoCustomEvent () <AdColonyAdDelegate, MPAdColonyRouterDelegate>

@property (nonatomic, copy) NSString *zoneId;
@property (nonatomic, assign) BOOL zoneAvailable;

@end

@implementation AdColonyRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    NSString *appId = [info objectForKey:@"appId"];
    NSArray *allZoneIds = [info objectForKey:@"allZoneIds"];
    NSString *zoneId = [info objectForKey:@"zoneId"];

    NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];

    [AdColonyCustomEvent initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds customerId:customerId];

    // Set the customID again since the above init call can only run once. We want to set the customID
    // if the caller gives us a customer id.
    if (customerId.length > 0) {
        [AdColony setCustomID:customerId];
    }

    self.zoneId = zoneId;
    self.zoneAvailable = NO;

    if(self.zoneId != nil && appId != nil) {
        [[MPAdColonyRouter sharedRouter] setCustomEvent:self forZoneId:self.zoneId];
    }

    if([self hasAdAvailable]) {
        MPLogInfo(@"AdColony zone %@ available", self.zoneId);
        [self zoneDidLoad];
    }
}

- (BOOL)hasAdAvailable
{
    return [AdColony isVirtualCurrencyRewardAvailableForZone:self.zoneId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        MPLogInfo(@"AdColony zone %@ attempting to start", self.zoneId);

        AdColonyInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[AdColonyInstanceMediationSettings class]];
        BOOL showPrePopup = (settings) ? settings.showPrePopup : NO;
        BOOL showPostPopup = (settings) ? settings.showPostPopup : NO;

        [AdColony playVideoAdForZone:self.zoneId
                        withDelegate:self
                    withV4VCPrePopup:showPrePopup
                    andV4VCPostPopup:showPostPopup];

        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    } else {
        MPLogInfo(@"Failed to show AdColony rewarded video: AdColony now claims zone %@ is not available", self.zoneId);
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this custom event has reported its ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPAdColonyRouter sharedRouter] removeCustomEvent:self forZoneId:self.zoneId];
}

#pragma mark - AdColonyAdDelegate

- (void)onAdColonyAdStartedInZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ started", zoneID);
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
    MPLogInfo(@"AdColony zone %@ finished", zoneID);
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

#pragma mark - MPAdColonyRouterDelegate

- (void)zoneDidLoad
{
    self.zoneAvailable = YES;
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)zoneDidExpire
{
    self.zoneAvailable = NO;
    [self.delegate rewardedVideoDidExpireForCustomEvent:self];
}

- (void)shouldRewardUserWithReward:(MPRewardedVideoReward *)reward
{
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
}

@end
