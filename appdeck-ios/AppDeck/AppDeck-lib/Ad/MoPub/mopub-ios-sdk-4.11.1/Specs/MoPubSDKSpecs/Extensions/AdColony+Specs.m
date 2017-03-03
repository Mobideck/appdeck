//
//  AdColony+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "AdColony+Specs.h"

#import <objc/runtime.h> // Needed for method swizzling

static NSString *gAppId;
static NSArray *gZoneIds;
static id<AdColonyDelegate> gDelegate;
static NSInteger gZoneStatus;
static BOOL gRewardAvailability;
static BOOL gPlayVideoCalled = NO;
static BOOL gPlayVideoCalledWithPrePopup = NO;
static BOOL gPlayVideoCalledWithPostPopup = NO;
static NSString *gCustomID = nil;

@implementation AdColony (Specs)

+ (void)load
{
    Method original, swizzled;

    original = class_getClassMethod(self, @selector(configureWithAppID:zoneIDs:delegate:logging:));
    swizzled = class_getClassMethod(self, @selector(mp_configureWithAppID:zoneIDs:delegate:logging:));
    method_exchangeImplementations(original, swizzled);

    original = class_getClassMethod(self, @selector(zoneStatusForZone:));
    swizzled = class_getClassMethod(self, @selector(mp_zoneStatusForZone:));
    method_exchangeImplementations(original, swizzled);

    original = class_getClassMethod(self, @selector(isVirtualCurrencyRewardAvailableForZone:));
    swizzled = class_getClassMethod(self, @selector(mp_isVirtualCurrencyRewardAvailableForZone:));
    method_exchangeImplementations(original, swizzled);
}

+ (void)mp_configureWithAppID:(NSString *)appID zoneIDs:(NSArray *)zoneIDs delegate:(id<AdColonyDelegate>)del logging:(BOOL)log
{
    gAppId = [appID copy];
    gZoneIds = [zoneIDs copy];
    gDelegate = del;

    [self mp_configureWithAppID:appID zoneIDs:zoneIDs delegate:del logging:log];
}

+ (ADCOLONY_ZONE_STATUS)mp_zoneStatusForZone:(NSString *)zoneID
{
    return gZoneStatus == -1 ? [self mp_zoneStatusForZone:zoneID] : (ADCOLONY_ZONE_STATUS) gZoneStatus;
}

+ (BOOL)mp_isVirtualCurrencyRewardAvailableForZone:(NSString *)zoneID
{
    return gRewardAvailability;
}

+ (void)mp_setZoneStatus:(NSInteger)status
{
    gZoneStatus = status;
}

+ (void)mp_setZoneRewardAvailability:(BOOL)available
{
    gRewardAvailability = available;
}

+ (NSString *)mp_getAppId
{
    return gAppId;
}

+ (NSArray *)mp_getZoneIds
{
    return gZoneIds;
}

+ (void)mp_setAdColonyDelegate:(id)delegate
{
    gDelegate = delegate;
}

+ (void)mp_onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID
{
    [gDelegate onAdColonyAdAvailabilityChange:available inZone:zoneID];
}

+ (BOOL)mp_playVideoCalled
{
    return gPlayVideoCalled;
}

+ (BOOL)mp_playVideoCalledWithPrePopup
{
    return gPlayVideoCalledWithPrePopup;
}

+ (BOOL)mp_playVideoCalledWithPostPopup
{
    return gPlayVideoCalledWithPostPopup;
}

+ (void)mp_resetPlayeVideoCalledProperties
{
    gPlayVideoCalled = NO;
    gPlayVideoCalledWithPostPopup = NO;
    gPlayVideoCalledWithPrePopup = NO;
}

+ (void)playVideoAdForZone:(NSString *)zoneID withDelegate:(id<AdColonyAdDelegate>)del
{
    gPlayVideoCalled = YES;
    gPlayVideoCalledWithPostPopup = NO;
    gPlayVideoCalledWithPrePopup = NO;
}

+ (void)playVideoAdForZone:(NSString *)zoneID withDelegate:(id<AdColonyAdDelegate>)del withV4VCPrePopup:(BOOL)showPrePopup andV4VCPostPopup:(BOOL)showPostPopup
{
    gPlayVideoCalled = YES;
    gPlayVideoCalledWithPrePopup = showPrePopup;
    gPlayVideoCalledWithPostPopup = showPostPopup;
}

+ (void)setCustomID:(NSString *)customID
{
    gCustomID = customID;
}

+ (NSString *)mp_customID
{
    return gCustomID;
}

+ (void)mp_clearCustomID
{
    gCustomID = nil;
}

@end
