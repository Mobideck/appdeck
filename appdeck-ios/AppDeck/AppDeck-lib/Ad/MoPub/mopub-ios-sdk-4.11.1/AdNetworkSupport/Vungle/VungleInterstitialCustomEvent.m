//
//  VungleInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#import "VungleInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"
#import "MPVungleRouter.h"

// If you need to play ads with vungle options, you may modify playVungleAdFromRootViewController and create an options dictionary and call the playAd:withOptions: method on the vungle SDK.

@interface VungleInterstitialCustomEvent () <MPVungleRouterDelegate>

@property (nonatomic, assign) BOOL handledAdAvailable;

@end

@implementation VungleInterstitialCustomEvent

+ (void)setAppId:(NSString *)appId
{
    MPLogWarn(@"+setAppId for class VungleInterstitialCustomEvent is deprecated. Use the appId parameter when configuring your network in the MoPub website.");
    [MPVungleRouter setAppId:appId];
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.handledAdAvailable = NO;
    [[MPVungleRouter sharedRouter] requestInterstitialAdWithCustomEventInfo:info delegate:self];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([[MPVungleRouter sharedRouter] isAdAvailable]) {
        [[MPVungleRouter sharedRouter] presentInterstitialAdFromViewController:rootViewController withDelegate:self];
    } else {
        MPLogInfo(@"Failed to show Vungle video interstitial: Vungle now claims that there is no available video ad.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)dealloc
{
    [[MPVungleRouter sharedRouter] clearDelegate:self];
}

- (void)invalidate
{
    [[MPVungleRouter sharedRouter] clearDelegate:self];
}

- (void)handleVungleAdViewWillClose
{
    MPLogInfo(@"Vungle video interstitial did disappear");

    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

#pragma mark - MPVungleRouterDelegate

- (void)vungleAdDidLoad
{
    if (!self.handledAdAvailable) {
        self.handledAdAvailable = YES;
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
}

- (void)vungleAdWillAppear
{
    MPLogInfo(@"Vungle video interstitial will appear");

    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)vungleAdWillDisappear
{
    [self handleVungleAdViewWillClose];
}

- (void)vungleAdWasTapped
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)vungleAdDidFailToLoad:(NSError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

@end
