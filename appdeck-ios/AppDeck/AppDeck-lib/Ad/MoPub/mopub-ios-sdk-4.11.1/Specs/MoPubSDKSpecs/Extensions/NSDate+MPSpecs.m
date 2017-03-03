//
//  NSDate+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "NSDate+MPSpecs.h"
#import <objc/runtime.h>

// If we swizzle the [NSDate date] method, we'll return fakeDate for [NSDate date].
static NSDate *gFakeDate = nil;

@implementation NSDate (MPSpecs)

+ (NSDate *)mp_date
{
    return gFakeDate;
}

+ (void)mp_swizzleDateMethod
{
    Method original, swizzled;

    original = class_getClassMethod(self, @selector(date));
    swizzled = class_getClassMethod(self, @selector(mp_date));
    method_exchangeImplementations(original, swizzled);
}

+ (void)mp_setFakeDate:(NSDate *)date
{
    gFakeDate = date;
}

@end
