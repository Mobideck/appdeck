//
//  AdColonyCustomEvent+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "AdColonyCustomEvent+MPSpecs.h"

#import <objc/runtime.h>

static NSInteger gAdColonyInitCount = 0;
static NSString *gAppId = nil;
static NSArray *gAllZoneIds = nil;
static BOOL gEnableAdColonyNetworkInit = NO;

@implementation AdColonyCustomEvent (MPSpecs)

+ (void)load
{
    Method original, swizzled;

    original = class_getClassMethod(self, @selector(initializeAdColonyCustomEventWithAppId:allZoneIds:customerId:));
    swizzled = class_getClassMethod(self, @selector(mp_initializeAdColonyCustomEventWithAppId:allZoneIds:customerId:));
    method_exchangeImplementations(original, swizzled);
}

+ (void)mp_enableAdColonyNetworkInit:(BOOL)allow
{
    gEnableAdColonyNetworkInit = allow;
}

+ (void)mp_initializeAdColonyCustomEventWithAppId:(NSString *)appId allZoneIds:(NSArray *)allZoneIds customerId:(NSString *)customerId
{
    gAppId = [appId copy];
    gAllZoneIds = allZoneIds;

    ++gAdColonyInitCount;

    if (gEnableAdColonyNetworkInit) {
        [self mp_initializeAdColonyCustomEventWithAppId:appId allZoneIds:allZoneIds customerId:customerId];
    }
}

+ (NSString *)mp_appId
{
    return gAppId;
}

+ (NSArray *)mp_allZoneIds
{
    return gAllZoneIds;
}

+ (NSInteger)mp_adColonyInitCount
{
    return gAdColonyInitCount;
}

+ (void)mp_resetAdColonyInitCount
{
    gAdColonyInitCount = 0;
}


@end
