//
//  FakeMPSampleAppInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPSampleAppInstanceProvider.h"
#import "FakeMPAdView.h"
#import "FakeMPInterstitialAdController.h"

@implementation FakeMPSampleAppInstanceProvider

- (MPAdView *)buildMPAdViewWithAdUnitID:(NSString *)ID size:(CGSize)size
{
    self.lastFakeAdView = [[FakeMPAdView alloc] initWithAdUnitId:ID size:size];
    return self.lastFakeAdView;
}

- (MPInterstitialAdController *)buildMPInterstitialAdControllerWithAdUnitID:(NSString *)ID
{
    self.lastFakeInterstitialAdController = [[FakeMPInterstitialAdController alloc] initWithAdUnitId:ID];
    return self.lastFakeInterstitialAdController;
}

@end
