//
//  VGVunglePub+Specs.h
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <vunglepub/vunglepub.h>

@interface VGVunglePub (Specs)

+ (void)mp_swizzleStartMethod;

+ (NSString *)mp_getAppId;
+ (VGUserData *)mp_getUserData;

+ (void)mp_sendSuccessStatusUpdate;
+ (void)mp_sendNoAdsCachedStatusUpdate;
+ (void)mp_sendNoAdsUnviewedStatusUpdate;
+ (void)mp_sendErrorStatusUpdate;

@end
