//
//  MPAdColonyRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//


#import "MPAdColonyRouter.h"
#import "MPLogging.h"
#import "MPInstanceProvider+AdColony.h"
#import "MPRewardedVideoReward.h"

@interface MPAdColonyRouter ()

@property (nonatomic, strong) NSMutableDictionary *events;

@end

@implementation MPAdColonyRouter

+ (MPAdColonyRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPAdColonyRouter];
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _events = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent forZoneId:(NSString *)zoneId
{
    [self.events setObject:customEvent forKey:zoneId];
}

- (void)removeCustomEvent:(id<MPAdColonyRouterDelegate>)customEvent forZoneId:(NSString *)zoneId
{
    if([[self.events objectForKey:zoneId] isEqual:customEvent])
    {
        [self.events removeObjectForKey:zoneId];
    }
}

#pragma mark - AdColonyDelegate

- (void)onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID
{
    id<MPAdColonyRouterDelegate> event = [self.events objectForKey:zoneID];

    if(available)
    {
        MPLogInfo(@"AdColony zone %@ just became available", zoneID);
        if(!event.zoneAvailable)
        {
            [event zoneDidLoad];
        }
    }
    else
    {
        MPLogInfo(@"AdColony zone %@ just became unavailable", zoneID);
        if(event.zoneAvailable)
        {
            [event zoneDidExpire];
        }
    }
}

- (void)onAdColonyV4VCReward:(BOOL)success currencyName:(NSString *)currencyName currencyAmount:(int)amount inZone:(NSString *)zoneID
{
    // If Ad Colony doesn't report success, we won't follow through.
    if (!success) {
        return;
    }

    id<MPAdColonyRouterDelegate> event = [self.events objectForKey:zoneID];

    if ([event respondsToSelector:@selector(shouldRewardUserWithReward:)]) {
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyName amount:@(amount)];
        [event shouldRewardUserWithReward:reward];
    }
}

@end
