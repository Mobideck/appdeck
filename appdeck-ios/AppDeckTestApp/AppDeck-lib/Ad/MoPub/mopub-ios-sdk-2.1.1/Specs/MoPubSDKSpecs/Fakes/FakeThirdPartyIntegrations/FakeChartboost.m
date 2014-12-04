//
//  FakeChartboost.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeChartboost.h"

@implementation FakeChartboost

- (id)init
{
    self = [super init];
    if (self) {
        self.requestedLocations = [NSMutableArray array];
        self.cachedInterstitials = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)startSession
{
    self.didStartSession = YES;
}

- (void)cacheInterstitial:(NSString *)location
{
    [self.requestedLocations addObject:location];
}

- (BOOL)hasCachedInterstitial:(NSString *)location
{
    return [[self.cachedInterstitials objectForKey:location] boolValue];
}

- (void)showInterstitial:(NSString *)location
{
    // chartboost doesn't actually need a view controller
    // this is here as a proxy
    self.presentingViewController = [[[UIViewController alloc] init] autorelease];
}

- (void)simulateLoadingLocation:(NSString *)location
{
    [self.delegate didCacheInterstitial:location];
}

- (void)simulateFailingToLoadLocation:(NSString *)location
{
    [self.delegate didFailToLoadInterstitial:location withError:CBLoadErrorInternal];
}

- (void)simulateUserTap:(NSString *)location
{
    [self simulateUserDismissingLocation:location]; //Chartboost always dismisses the ad when clicked
    [self.delegate didClickInterstitial:location];
}

- (void)simulateUserDismissingLocation:(NSString *)location
{
    self.presentingViewController = nil;
    [self.delegate didDismissInterstitial:location];
}

@end
