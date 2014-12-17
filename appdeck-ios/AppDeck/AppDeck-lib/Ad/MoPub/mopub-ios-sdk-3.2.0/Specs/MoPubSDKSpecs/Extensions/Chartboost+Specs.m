//
//  Chartboost+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "Chartboost+Specs.h"

static NSString *gAppId, *gAppSignature;
static id<ChartboostDelegate> gDelegate;
static NSMutableArray *gRequestedLocations;
static NSMutableDictionary *gCachedInterstitials;
static NSString *gCurrentVisibleLocation;

@implementation Chartboost (Specs)

+ (void)startWithAppId:(NSString*)appId
          appSignature:(NSString*)appSignature
              delegate:(id<ChartboostDelegate>)delegate
{
    gAppId = [appId copy];
    gAppSignature = [appSignature copy];
    [self setDelegate:delegate];

    gRequestedLocations = [NSMutableArray array];
    gCachedInterstitials = [NSMutableDictionary dictionary];
}

+ (void)cacheInterstitial:(CBLocation)location
{
    [gRequestedLocations addObject:location];
}

+ (void)setHasInterstitial:(NSNumber *)hasInterstitial forLocation:(CBLocation)location
{
    [gCachedInterstitials setObject:hasInterstitial forKey:location];
}

+ (BOOL)hasInterstitial:(CBLocation)location
{
    return [[gCachedInterstitials objectForKey:location] boolValue];
}

+ (void)showInterstitial:(CBLocation)location
{
    gCurrentVisibleLocation = [location copy];

    [gDelegate didDisplayInterstitial:location];
}

+ (void)simulateLoadingLocation:(NSString *)location
{
    [gDelegate didCacheInterstitial:location];
}

+ (void)simulateFailingToLoadLocation:(NSString *)location
{
    [gDelegate didFailToLoadInterstitial:location withError:CBLoadErrorInternal];
}

+ (void)simulateUserTap:(NSString *)location
{
    [self simulateUserDismissingLocation:location]; //Chartboost always dismisses the ad when clicked
    [gDelegate didClickInterstitial:location];
}

+ (void)simulateUserDismissingLocation:(NSString *)location
{
    gCurrentVisibleLocation = nil;
    [gDelegate didDismissInterstitial:location];
}

+ (void)setDelegate:(id)delegate
{
    gDelegate = delegate;
}

+ (NSString *)appId
{
    return gAppId;
}

+ (NSString *)appSignature
{
    return gAppSignature;
}

+ (NSArray *)requestedLocations
{
    return gRequestedLocations;
}

+ (void)clearRequestedLocations
{
    [gRequestedLocations removeAllObjects];
}

+ (NSString *)currentVisibleLocation
{
    return gCurrentVisibleLocation;
}

@end
