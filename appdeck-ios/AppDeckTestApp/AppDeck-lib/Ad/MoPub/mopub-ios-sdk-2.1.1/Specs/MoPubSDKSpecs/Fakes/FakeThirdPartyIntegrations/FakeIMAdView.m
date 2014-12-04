//
//  FakeIMAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeIMAdView.h"

@implementation FakeIMAdView

- (void)dealloc
{
    [super dealloc];
}

- (void)simulateLoadingAd
{
    [self.delegate bannerDidReceiveAd:self];
}

- (void)simulateFailingToLoad
{
    [self.delegate banner:self didFailToReceiveAdWithError:nil];
}

- (void)simulateUserTap
{
    [self.delegate bannerDidInteract:self withParams:nil];
    [self.delegate bannerWillPresentScreen:self];
}

- (void)simulateUserEndingInteraction
{
    [self.delegate bannerDidDismissScreen:self];
}

- (void)simulateUserLeavingApplication
{
    [self.delegate bannerWillLeaveApplication:self];
}

@end
