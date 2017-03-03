//
//  NSDate+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MPSpecs)

+ (void)mp_swizzleDateMethod;
+ (void)mp_setFakeDate:(NSDate *)date;

@end
