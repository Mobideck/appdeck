//
//  VGVunglePub+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "VGVunglePub+Specs.h"

#import <objc/runtime.h> // Needed for method swizzling

static NSString *gAppId;
static VGUserData *gUserData;

@implementation VGVunglePub (Specs)

+ (void)mp_swizzleStartMethod
{
    Method original, swizzled;
    
    original = class_getClassMethod(self, @selector(startWithPubAppID:userData:));
    swizzled = class_getClassMethod(self, @selector(mp_swizzledStartWithPubAppID:userData:));
    method_exchangeImplementations(original, swizzled);
}

+ (void)mp_swizzledStartWithPubAppID:(NSString *)appId userData:(VGUserData *)userData
{
    gAppId = [appId copy];
    gUserData = [userData retain];
    
    [self mp_swizzledStartWithPubAppID:appId userData:userData];
}

+ (NSString *)mp_getAppId
{
    return gAppId;
}

+ (VGUserData *)mp_getUserData
{
    return gUserData;
}

+ (void)mp_sendSuccessStatusUpdate
{
    VGStatusData *data = [VGStatusData statusData];
    data.status = VGStatusOkay;
    data.videoAdsCached = 1;
    data.videoAdsUnviewed = 1;
    
    [[VGVunglePub delegate] vungleStatusUpdate:data];
}

+ (void)mp_sendNoAdsCachedStatusUpdate
{
    VGStatusData *data = [VGStatusData statusData];
    data.status = VGStatusOkay;
    data.videoAdsCached = 0;
    data.videoAdsUnviewed = 1;
    
    [[VGVunglePub delegate] vungleStatusUpdate:data];
}

+ (void)mp_sendNoAdsUnviewedStatusUpdate
{
    VGStatusData *data = [VGStatusData statusData];
    data.status = VGStatusOkay;
    data.videoAdsCached = 1;
    data.videoAdsUnviewed = 0;
    
    [[VGVunglePub delegate] vungleStatusUpdate:data];
}

+ (void)mp_sendErrorStatusUpdate
{
    VGStatusData *data = [VGStatusData statusData];
    data.status = VGStatusNetworkError;
    data.videoAdsCached = 1;
    data.videoAdsUnviewed = 1;
    
    [[VGVunglePub delegate] vungleStatusUpdate:data];
}

@end
