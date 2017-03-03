//
//  FakeGADInterstitial.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeGADInterstitial.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation FakeGADInterstitial

- (GADInterstitial *)masquerade
{
    return (GADInterstitial *)self;
}

- (void)loadRequest:(GADRequest *)request
{
    self.loadedRequest = request;
}

- (void)presentFromRootViewController:(UIViewController *)controller
{
    self.presentingViewController = controller;
    [self.delegate interstitialWillPresentScreen:self.masquerade];
}

- (void)simulateLoadingAd
{
    [self.delegate interstitialDidReceiveAd:self.masquerade];
}

- (void)simulateFailingToLoad
{
    [self.delegate interstitial:self.masquerade didFailToReceiveAdWithError:nil];
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate interstitialWillDismissScreen:self.masquerade];
    [self.delegate interstitialDidDismissScreen:self.masquerade];
}

- (void)simulateUserInteraction
{
    [self.delegate interstitialWillLeaveApplication:self.masquerade];
}

@end
