//
//  InMobi+Specs.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "InMobi.h"

@interface InMobi (Specs)

+ (void)mp_swizzleSetLocationMethod;
+ (CGFloat)mp_getLatitude;
+ (CGFloat)mp_getLongitude;
+ (CGFloat)mp_getAccuracy;

@end
