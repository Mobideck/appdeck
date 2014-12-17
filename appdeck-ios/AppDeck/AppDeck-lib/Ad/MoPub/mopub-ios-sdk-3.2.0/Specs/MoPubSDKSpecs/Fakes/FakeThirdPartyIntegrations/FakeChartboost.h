//
//  FakeChartboost.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "Chartboost.h"

@interface FakeChartboost : Chartboost <FakeInterstitialAd>

@property (nonatomic, strong) UIViewController *presentingViewController;

@property (nonatomic, strong) NSMutableArray *requestedLocations;

@property (nonatomic, assign) BOOL didStartSession;
@property (nonatomic, strong) NSMutableDictionary *cachedInterstitials;

- (void)simulateLoadingLocation:(NSString *)location;
- (void)simulateFailingToLoadLocation:(NSString *)location;
- (void)simulateUserDismissingLocation:(NSString *)location;
- (void)simulateUserTap:(NSString *)location;

@end
