//
//  VungleRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "VungleRewardedVideoCustomEvent.h"
#import "MPLogging.h"
#import <VungleSDK/VungleSDK.h>
#import "MPRewardedVideoReward.h"
#import "MPVungleRouter.h"
#import "MPRewardedVideoError.h"
#import "VungleInstanceMediationSettings.h"

@interface VungleRewardedVideoCustomEvent ()  <MPVungleRouterDelegate>

@end

@implementation VungleRewardedVideoCustomEvent

- (void)dealloc
{
    [[MPVungleRouter sharedRouter] clearDelegate:self];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    [[MPVungleRouter sharedRouter] requestRewardedVideoAdWithCustomEventInfo:info delegate:self];
}

- (BOOL)hasAdAvailable
{
    return [[VungleSDK sharedSDK] isAdPlayable];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([[MPVungleRouter sharedRouter] isAdAvailable]) {
        VungleInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[VungleInstanceMediationSettings class]];

        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        [[MPVungleRouter sharedRouter] presentRewardedVideoAdFromViewController:viewController customerId:customerId settings:settings delegate:self];
    } else {
        MPLogInfo(@"Failed to show Vungle rewarded video: Vungle now claims that there is no available video ad.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPVungleRouter sharedRouter] clearDelegate:self];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    //empty implementation
}

#pragma mark - MPVungleDelegate

- (void)vungleAdDidLoad
{
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}
- (void)vungleAdWillAppear
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}
- (void)vungleAdWillDisappear
{
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)vungleAdWasTapped
{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)vungleAdShouldRewardUser
{
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)]];
}


- (void)vungleAdDidFailToLoad:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

@end
