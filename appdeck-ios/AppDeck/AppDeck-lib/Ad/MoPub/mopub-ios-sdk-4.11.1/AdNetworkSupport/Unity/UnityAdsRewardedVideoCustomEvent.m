//
//  UnityAdsRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "UnityAdsRewardedVideoCustomEvent.h"
#import "MPUnityRouter.h"
#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"
#import "MPLogging.h"
#import "UnityAdsInstanceMediationSettings.h"

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsRewardedVideoCustomEvent () <MPUnityRouterDelegate>

@property (nonatomic, copy) NSString *zoneId;

@end

@implementation UnityAdsRewardedVideoCustomEvent

- (void)dealloc
{
    [[MPUnityRouter sharedRouter] clearDelegate:self];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
    self.zoneId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    [[MPUnityRouter sharedRouter] requestRewardedVideoAdWithGameId:gameId zoneId:self.zoneId delegate:self];
}

- (BOOL)hasAdAvailable
{
    return [[MPUnityRouter sharedRouter] isAdAvailableForZoneId:self.zoneId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        UnityAdsInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[UnityAdsInstanceMediationSettings class]];

        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        [[MPUnityRouter sharedRouter] presentRewardedVideoAdFromViewController:viewController customerId:customerId zoneId:self.zoneId settings:settings delegate:self];
    } else {
        MPLogInfo(@"Failed to show Unity rewarded video: Unity now claims that there is no available video ad.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPUnityRouter sharedRouter] clearDelegate:self];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }}

#pragma mark - MPUnityRouterDelegate

- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped
{
    if (!skipped) {
        NSString *currencyType = kMPRewardedVideoRewardCurrencyTypeUnspecified;
        if (rewardItemKey) {
            currencyType = rewardItemKey;
        }
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyType amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
    }
}

- (void)unityAdsWillShow
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

- (void)unityAdsDidShow
{
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)unityAdsWillHide
{
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
}

- (void)unityAdsDidHide
{
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)unityAdsWillLeaveApplication
{
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

- (void)unityAdsFetchCompleted
{
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)unityAdsDidFailWithError:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

@end
