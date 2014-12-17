//
//  FakeGADBannerView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeGADBannerView.h"

@implementation FakeGADBannerView

- (GADBannerView *)masquerade
{
    return (GADBannerView *)self;
}

- (void)loadRequest:(GADRequest *)request
{
    self.loadedRequest = request;
}

- (void)simulateLoadingAd
{
    [self.delegate adViewDidReceiveAd:self.masquerade];
}

- (void)simulateFailingToLoad
{
    [self.delegate adView:self.masquerade didFailToReceiveAdWithError:nil];
}

- (void)simulateUserTap
{
    [self.delegate adViewWillPresentScreen:self.masquerade];
}

- (void)simulateUserEndingInteraction
{
    [self.delegate adViewDidDismissScreen:self.masquerade];
}

- (void)simulateUserLeavingApplication
{
    [self.delegate adViewWillLeaveApplication:self.masquerade];
}

@end
