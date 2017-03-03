//
//  Chartboost+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "Chartboost+Specs.h"

static NSString *gAppId, *gAppSignature;
static id<ChartboostDelegate> gDelegate;
static NSMutableArray *gRequestedInterstitialLocations;
static NSMutableArray *gRequestedRewardedVideoLocations;
static NSMutableDictionary *gCachedInterstitials;
static NSMutableDictionary *gCachedRewardedVideos;
static NSString *gCurrentVisibleLocation;

@implementation Chartboost (Specs)

+ (void)startWithAppId:(NSString*)appId
          appSignature:(NSString*)appSignature
              delegate:(id<ChartboostDelegate>)delegate
{
    gAppId = [appId copy];
    gAppSignature = [appSignature copy];
    [self setDelegate:delegate];

    gRequestedInterstitialLocations = [NSMutableArray array];
    gRequestedRewardedVideoLocations = [NSMutableArray array];
    [self initCachedInterstitials];
}

+ (void)initCachedInterstitials
{
    if (gCachedInterstitials == nil) {
        gCachedInterstitials = [NSMutableDictionary dictionary];
    }

    if (gCachedRewardedVideos == nil) {
        gCachedRewardedVideos = [NSMutableDictionary dictionary];
    }
}

+ (void)cacheInterstitial:(CBLocation)location
{
    [gRequestedInterstitialLocations addObject:location];
}

+ (void)setHasInterstitial:(NSNumber *)hasInterstitial forLocation:(CBLocation)location
{
    [self initCachedInterstitials];
    [gCachedInterstitials setObject:hasInterstitial forKey:location];
}

+ (void)setHasRewardedVideo:(NSNumber *)hasRewardedVideo forLocation:(CBLocation)location
{
    [self initCachedInterstitials];
    [gCachedRewardedVideos setObject:hasRewardedVideo forKey:location];
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
    return gRequestedInterstitialLocations;
}

+(NSArray *)requestedRewardedLocations
{
    return gRequestedRewardedVideoLocations;
}

+ (void)clearRequestedLocations
{
    [gRequestedInterstitialLocations removeAllObjects];
    [gRequestedRewardedVideoLocations removeAllObjects];
}

+ (NSString *)currentVisibleLocation
{
    return gCurrentVisibleLocation;
}

@end
