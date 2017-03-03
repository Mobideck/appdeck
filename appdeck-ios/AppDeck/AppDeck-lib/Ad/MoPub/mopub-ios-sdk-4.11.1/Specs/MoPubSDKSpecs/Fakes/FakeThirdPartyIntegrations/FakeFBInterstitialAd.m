//
//  FakeFBInterstitialAd.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeFBInterstitialAd.h"

@interface FakeFBInterstitialAd ()

@end

@implementation FakeFBInterstitialAd

- (FBInterstitialAd *)masquerade
{
    return (FBInterstitialAd *)self;
}

- (void)simulateFailingToLoad
{
    self.isAdValid = NO;
    NSError *error;
    [self.delegate interstitialAd:self.masquerade didFailWithError:error];
}

- (void)loadAd
{
    [self simulateLoadingAd];
}

- (void)simulateLoadingAd
{
    self.isAdValid = YES;
    [self.delegate interstitialAdDidLoad:self.masquerade];
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate interstitialAdWillClose:self.masquerade];
}

- (void)simulateUserDismissedAd
{
    if (self.isAdValid) {
        self.isAdValid = NO;
        self.presentingViewController = nil;
        [self.delegate interstitialAdDidClose:self.masquerade];
    }
}
- (void)simulateUserInteraction
{
    [self.delegate interstitialAdDidClick:self.masquerade];
}

- (BOOL)showAdFromRootViewController:(UIViewController *)controller
{
    self.presentingViewController = controller;
    return YES;
}

@end
