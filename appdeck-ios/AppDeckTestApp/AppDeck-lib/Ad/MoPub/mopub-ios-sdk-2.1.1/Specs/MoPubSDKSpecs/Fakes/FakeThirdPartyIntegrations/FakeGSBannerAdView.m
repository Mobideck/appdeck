//
//  FakeGSBannerAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeGSBannerAdView.h"

@implementation FakeGSBannerAdView

- (void)fetch
{
    self.didFetch = YES;
}

- (void)simulateLoadingAd
{
    [self.delegate greystripeAdFetchSucceeded:self];
}

- (void)simulateFailingToLoad
{
    [self.delegate greystripeAdFetchFailed:self withError:kGSUnknown];
}

- (void)simulateUserTap
{
    [self.delegate greystripeWillPresentModalViewController];
}

- (void)simulateUserEndingInteraction
{
    [self.delegate greystripeDidDismissModalViewController];
}

@end
