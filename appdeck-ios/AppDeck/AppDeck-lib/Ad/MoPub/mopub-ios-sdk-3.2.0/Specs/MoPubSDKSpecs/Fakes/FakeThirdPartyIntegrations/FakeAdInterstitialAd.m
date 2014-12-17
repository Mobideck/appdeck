//
//  FakeAdInterstitialAd.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeAdInterstitialAd.h"

@implementation FakeADInterstitialAd

- (ADInterstitialAd *)masquerade
{
    return (ADInterstitialAd *)self;
}

- (void)simulateFailingToLoad
{
    self.loaded = NO;
    [self.delegate interstitialAd:self.masquerade didFailWithError:nil];
}

- (void)simulateLoadingAd
{
    self.loaded = YES;
    [self.delegate interstitialAdDidLoad:self.masquerade];
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    
    // in iOS 7, DidUnload is no longer called immediately, instead, ActionDidFinish is called
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.delegate interstitialAdActionDidFinish:self.masquerade];
    } else {
        [self.delegate interstitialAdDidUnload:self.masquerade];
    }
}

- (void)simulateUnloadingAd
{
    self.loaded = NO;
    self.presentingViewController = nil;
    [self.delegate interstitialAdDidUnload:self.masquerade];
}

- (void)simulateUserInteraction
{
    [self.delegate interstitialAdActionShouldBegin:self.masquerade
                              willLeaveApplication:NO];
}

- (void)presentFromViewController:(UIViewController *)controller
{
    self.presentingViewController = controller;
}

@end
