//
//  FakeGSFullScreenAd.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeGSFullscreenAd.h"

@implementation FakeGSFullscreenAd

- (id)init
{
    return [super initWithDelegate:nil];
}

- (void)fetch
{
    self.didFetch = YES;
}

- (BOOL)displayFromViewController:(UIViewController *)a_viewController
{
    self.presentingViewController = a_viewController;
    [self.delegate greystripeWillPresentModalViewController];
    return YES;
}

- (void)simulateLoadingAd
{
    [self.delegate greystripeAdFetchSucceeded:self];
}

- (void)simulateFailingToLoad
{
    [self.delegate greystripeAdFetchFailed:self withError:0];
}

- (void)simulateUserTap
{
    [self.delegate greystripeAdClickedThrough:self];
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate greystripeWillDismissModalViewController];
}

- (void)simulateInterstitialFinishedDisappearing
{
    [self.delegate greystripeDidDismissModalViewController];
}

@end
