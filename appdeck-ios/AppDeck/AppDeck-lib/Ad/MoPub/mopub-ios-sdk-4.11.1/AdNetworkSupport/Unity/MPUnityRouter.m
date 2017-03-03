//
//  MPUnityRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPUnityRouter.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "MPInstanceProvider+Unity.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideo.h"

@interface MPUnityRouter ()

@property (nonatomic, assign) BOOL isAdPlaying;

@end

@implementation MPUnityRouter

+ (MPUnityRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPUnityRouter];
}

- (void)requestRewardedVideoAdWithGameId:(NSString *)gameId zoneId:(NSString *)zoneId delegate:(id<MPUnityRouterDelegate>)delegate;
{
    if (!self.isAdPlaying) {
        self.delegate = delegate;

        static dispatch_once_t unityInitToken;
        dispatch_once(&unityInitToken, ^{
            [[UnityAds sharedInstance] startWithGameId:gameId];
            [[UnityAds sharedInstance] setDelegate:self];
        });

        // Need to check immediately as an ad may be cached.
        if ([self isAdAvailableForZoneId:zoneId]) {
            [self.delegate unityAdsFetchCompleted];
        }
        // MoPub timeout will handle the case for an ad failing to load.
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (BOOL)isAdAvailableForZoneId:(NSString *)zoneId
{
    /*
     * the zone ID is set here because it needs to be set for canShow, canShowAds, and show
     * to work for the correct Unity Ad that cooresponds to the custom event. It's a little
     * bit of a weird side-effect to do it here, but it's the common denominator for requests
     * and presentation of ads and helps ensure that we don't check the status of or show
     * an ad with the wrong zone ID (set from a different custom event).
     */
    if ([zoneId length] > 0) {
        [[UnityAds sharedInstance] setZone:zoneId];
    }
    return [[UnityAds sharedInstance] canShow] && [[UnityAds sharedInstance] canShowAds];
}

- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId zoneId:(NSString *)zoneId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate
{
    if (!self.isAdPlaying && [self isAdAvailableForZoneId:zoneId]) {
        self.isAdPlaying = YES;

        self.delegate = delegate;
        [[UnityAds sharedInstance] setViewController:viewController];

        if (customerId.length >0) {
            [[UnityAds sharedInstance] show:@{kUnityAdsOptionGamerSIDKey : customerId}];
        } else if (settings.userIdentifier.length > 0) {
            [[UnityAds sharedInstance] show:@{kUnityAdsOptionGamerSIDKey : settings.userIdentifier}];
        } else {
            [[UnityAds sharedInstance] show];
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate
{
    if (self.delegate == delegate)
    {
        [self setDelegate:nil];
    }
}

#pragma mark - UnityAdsDelegate

- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped
{
    [self.delegate unityAdsVideoCompleted:rewardItemKey skipped:skipped];
}

- (void)unityAdsWillShow
{
    [self.delegate unityAdsWillShow];
}

- (void)unityAdsDidShow
{
    [self.delegate unityAdsDidShow];
}

- (void)unityAdsWillHide
{
    [self.delegate unityAdsWillHide];
}

- (void)unityAdsDidHide
{
    [self.delegate unityAdsDidHide];
    self.isAdPlaying = NO;
}

- (void)unityAdsWillLeaveApplication
{
    [self.delegate unityAdsWillLeaveApplication];
}

- (void)unityAdsFetchCompleted
{
    [self.delegate unityAdsFetchCompleted];
}

- (void)unityAdsFetchFailed
{
    NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];

    [self.delegate unityAdsDidFailWithError:error];
}

@end
