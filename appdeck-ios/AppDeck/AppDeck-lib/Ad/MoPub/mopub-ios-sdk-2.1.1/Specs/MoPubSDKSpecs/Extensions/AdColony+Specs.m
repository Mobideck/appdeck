//
//  AdColony+Specs.m
//  MoPubSDK
//
//  Created by Yuan Ren on 10/22/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "AdColony+Specs.h"

#import <objc/runtime.h> // Needed for method swizzling

static NSString *gAppId;
static NSArray *gZoneIds;
static id<AdColonyDelegate> gDelegate;
static NSInteger gZoneStatus;

@implementation AdColony (Specs)

+ (void)mp_swizzleStartMethod
{
    Method original, swizzled;
    
    original = class_getClassMethod(self, @selector(configureWithAppID:zoneIDs:delegate:logging:));
    swizzled = class_getClassMethod(self, @selector(mp_configureWithAppID:zoneIDs:delegate:logging:));
    method_exchangeImplementations(original, swizzled);
}

+ (void)mp_configureWithAppID:(NSString *)appID zoneIDs:(NSArray *)zoneIDs delegate:(id<AdColonyDelegate>)del logging:(BOOL)log
{
    gAppId = [appID copy];
    gZoneIds = [zoneIDs copy];
    gDelegate = [del retain];
    
    [self mp_configureWithAppID:appID zoneIDs:zoneIDs delegate:del logging:log];
}

+ (void)mp_swizzleZoneStatusMethod
{
    Method original, swizzled;
    
    original = class_getClassMethod(self, @selector(zoneStatusForZone:));
    swizzled = class_getClassMethod(self, @selector(mp_zoneStatusForZone:));
    method_exchangeImplementations(original, swizzled);
}

+ (ADCOLONY_ZONE_STATUS)mp_zoneStatusForZone:(NSString *)zoneID
{
    return gZoneStatus == -1 ? [self mp_zoneStatusForZone:zoneID] : gZoneStatus;
}

+ (void)mp_setZoneStatus:(NSInteger)status
{
    gZoneStatus = status;
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
    [gDelegate release];
    gDelegate = [delegate retain];
}

+ (void)mp_onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID
{
    [gDelegate onAdColonyAdAvailabilityChange:available inZone:zoneID];
}

@end
