//
//  FakeFBAdView.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeFBAdView.h"

@implementation FakeFBAdView

- (void)simulateLoadingAd
{
    self.bannerLoaded = YES;
    [self.delegate adViewDidLoad:self.masquerade];
}

- (void)simulateFailingToLoad
{
    self.bannerLoaded = NO;
    NSError *error;
    [self.delegate adView:self.masquerade didFailWithError:error];
}

- (void)simulateUserInteraction
{
    [self.delegate adViewDidClick:self.masquerade];
}

- (void)simulateUserInteractionFinished
{
    [self.delegate adViewDidFinishHandlingClick:self.masquerade];
}

- (FBAdView *)masquerade
{
    return (FBAdView *)self;
}

- (void)loadAd
{
    [self simulateLoadingAd];
}


@end
