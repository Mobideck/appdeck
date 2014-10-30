//
//  InMobi+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "InMobi+Specs.h"

#import <objc/runtime.h> // Needed for method swizzling

@implementation InMobi (Specs)

static CGFloat gLatitude, gLongitude, gAccuracyInMeters;

+ (void)mp_swizzleSetLocationMethod
{
    Method original, swizzled;
    
    original = class_getClassMethod(self, @selector(setLocationWithLatitude:longitude:accuracy:));
    swizzled = class_getClassMethod(self, @selector(mp_setLocationWithLatitude:longitude:accuracy:));
    method_exchangeImplementations(original, swizzled);
}

+ (void)mp_setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude accuracy:(CGFloat)accuracyInMeters
{
    gLatitude = latitude;
    gLongitude = longitude;
    gAccuracyInMeters = accuracyInMeters;
    
    [self mp_setLocationWithLatitude:latitude longitude:longitude accuracy:accuracyInMeters];
}

+ (CGFloat)mp_getLatitude
{
    return gLatitude;
}

+ (CGFloat)mp_getLongitude
{
    return gLongitude;
}

+ (CGFloat)mp_getAccuracy
{
    return gAccuracyInMeters;
}

@end
