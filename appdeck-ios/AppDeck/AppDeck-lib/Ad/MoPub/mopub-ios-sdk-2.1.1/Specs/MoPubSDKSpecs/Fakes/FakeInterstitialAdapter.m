//
//  FakeInterstitialAdapter.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeInterstitialAdapter.h"

@implementation FakeInterstitialAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    self.configurationForLastRequest = configuration;
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    self.presentingViewController = controller;
}

- (void)failToLoad
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)loadSuccessfully
{
    [self.delegate adapterDidFinishLoadingAd:self];
}

@end
