//
//  Chartboost+Specs.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Chartboost/Chartboost.h>

@interface Chartboost (Specs)

+ (void)setDelegate:(id)delegate;
+ (void)setHasInterstitial:(NSNumber *)hasInterstitial forLocation:(CBLocation)location;
+ (void)setHasRewardedVideo:(NSNumber *)hasRewardedVideo forLocation:(CBLocation)location;
+ (void)simulateLoadingLocation:(NSString *)location;
+ (void)simulateUserTap:(NSString *)location;
+ (void)simulateUserDismissingLocation:(NSString *)location;
+ (void)simulateFailingToLoadLocation:(NSString *)location;
+ (NSString *)appId;
+ (NSString *)appSignature;
+ (NSArray *)requestedLocations;
+(NSArray *)requestedRewardedLocations;
+ (void)clearRequestedLocations;
+ (NSString *)currentVisibleLocation;

@end
