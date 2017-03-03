//
//  MPVungleRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPVungleRouter.h"
#import "MPInstanceProvider+Vungle.h"
#import "MPLogging.h"
#import "VungleInstanceMediationSettings.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideo.h"

static NSString * const VunglePluginVersion = @"1_0_0";

static NSString *gAppId = nil;
static NSString *const kMPVungleRewardedAdCompletedView = @"completedView";
static NSString *const kMPVungleAdUserDidDownloadKey = @"didDownload";

static const NSTimeInterval VungleInitTimeout = 2.0;

@interface MPVungleRouter ()

@property (nonatomic, assign) BOOL isWaitingForInit;
@property (nonatomic, assign) BOOL isAdPlaying;

@end

@implementation MPVungleRouter

+ (void)setAppId:(NSString *)appId
{
    gAppId = [appId copy];
}

+ (MPVungleRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPVungleRouter];
}

- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate
{
    if (!self.isAdPlaying) {
        [self requestAdWithCustomEventInfo:info delegate:delegate];
    } else {
        [delegate vungleAdDidFailToLoad:nil];
    }
}

- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate
{
    if (!self.isAdPlaying) {
        [self requestAdWithCustomEventInfo:info delegate:delegate];
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate vungleAdDidFailToLoad:error];
    }
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate
{
    self.delegate = delegate;

    static dispatch_once_t vungleInitToken;
    dispatch_once(&vungleInitToken, ^{
        NSString *appId = [info objectForKey:@"appId"];
        if ([appId length] == 0) {
            appId = gAppId;
        }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[VungleSDK sharedSDK] performSelector:@selector(setPluginName:version:) withObject:@"mopub" withObject:VunglePluginVersion];
#pragma clang diagnostic pop

        [[VungleSDK sharedSDK] startWithAppId:appId];
        [[VungleSDK sharedSDK] setDelegate:self];

        self.isWaitingForInit = YES;
        __weak MPVungleRouter *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(VungleInitTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MPVungleRouter *strongSelf = weakSelf;
            if (strongSelf) {
                if (strongSelf.isWaitingForInit) {
                    strongSelf.isWaitingForInit = NO;
                    [strongSelf.delegate vungleAdDidFailToLoad:nil];
                }
            }
        });
    });

    if (!self.isWaitingForInit) {
        if ([[VungleSDK sharedSDK] isAdPlayable]) {
            [self.delegate vungleAdDidLoad];
        } else {
            [self.delegate vungleAdDidFailToLoad:nil];
        }
    }
}

- (BOOL)isAdAvailable
{
    return [[VungleSDK sharedSDK] isAdPlayable];
}

- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController withDelegate:(id<MPVungleRouterDelegate>)delegate
{
    if (!self.isAdPlaying && self.isAdAvailable) {
        self.delegate = delegate;
        self.isAdPlaying = YES;

        BOOL success = [[VungleSDK sharedSDK] playAd:viewController error:nil];

        if (!success) {
            [delegate vungleAdDidFailToPlay:nil];
        }
    } else {
        [delegate vungleAdDidFailToPlay:nil];
    }
}

- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId settings:(VungleInstanceMediationSettings *)settings delegate:(id<MPVungleRouterDelegate>)delegate
{
    if (!self.isAdPlaying && self.isAdAvailable) {
        self.delegate = delegate;
        self.isAdPlaying = YES;
        NSDictionary *options;

        if (customerId.length > 0) {
            options = @{VunglePlayAdOptionKeyIncentivized : @(YES), VunglePlayAdOptionKeyUser : customerId};
        } else if (settings && [settings.userIdentifier length]) {
            options = @{VunglePlayAdOptionKeyIncentivized : @(YES), VunglePlayAdOptionKeyUser : settings.userIdentifier};
        } else {
            options = @{VunglePlayAdOptionKeyIncentivized : @(YES)};
        }

        BOOL success = [[VungleSDK sharedSDK] playAd:viewController withOptions:options error:nil];

        if (!success) {
            [delegate vungleAdDidFailToPlay:nil];
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [delegate vungleAdDidFailToPlay:error];
    }
}

- (void)clearDelegate:(id<MPVungleRouterDelegate>)delegate
{
    if (self.delegate == delegate) {
        [self setDelegate:nil];
    }
}

#pragma mark - private

- (void)vungleAdDidFinish
{
    [self.delegate vungleAdWillDisappear];
    self.isAdPlaying = NO;
}

#pragma mark - VungleSDKDelegate

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable
{
    if (self.isWaitingForInit && isAdPlayable) {
        self.isWaitingForInit = NO;
        [self.delegate vungleAdDidLoad];
    }
}

- (void)vungleSDKwillShowAd
{
    [self.delegate vungleAdWillAppear];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    if ([viewInfo[kMPVungleAdUserDidDownloadKey] isEqual:@YES]) {
        [self.delegate vungleAdWasTapped];
    }

    if ([[viewInfo objectForKey:kMPVungleRewardedAdCompletedView] boolValue] && [self.delegate respondsToSelector:@selector(vungleAdShouldRewardUser)]) {
        [self.delegate vungleAdShouldRewardUser];
    }

    if (!willPresentProductSheet) {
        [self vungleAdDidFinish];
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    [self vungleAdDidFinish];
}

@end
