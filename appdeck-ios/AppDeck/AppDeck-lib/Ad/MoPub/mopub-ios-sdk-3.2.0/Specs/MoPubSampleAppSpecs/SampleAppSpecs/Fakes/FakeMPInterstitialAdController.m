//
//  FakeMPInterstitialAdController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPInterstitialAdController.h"

@implementation FakeMPInterstitialAdController

- (void)loadAd
{
    self.wasLoaded = YES;
}

- (void)showFromViewController:(UIViewController *)controller
{
    self.presenter = controller;
}

@end
