//
//  FakeMPSampleAppInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppInstanceProvider.h"

@class FakeMPAdView, FakeMPInterstitialAdController;

@interface FakeMPSampleAppInstanceProvider : MPSampleAppInstanceProvider

@property (nonatomic, strong) FakeMPAdView *lastFakeAdView;
@property (nonatomic, strong) FakeMPInterstitialAdController *lastFakeInterstitialAdController;

@end
