//
//  FakeMPInterstitialAdController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialAdController.h"

@interface FakeMPInterstitialAdController : MPInterstitialAdController

@property (nonatomic, assign) BOOL wasLoaded;
@property (nonatomic, weak) UIViewController *presenter;

@end

@interface FakeMPInterstitialAdController (Spec)

- (id)initWithAdUnitId:(NSString *)adUnitId;

@end
