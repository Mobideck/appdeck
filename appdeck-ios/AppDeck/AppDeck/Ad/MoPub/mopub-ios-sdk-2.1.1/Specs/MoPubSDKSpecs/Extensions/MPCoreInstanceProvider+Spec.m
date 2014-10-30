//
//  MPCoreInstanceProvider+Spec.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPCoreInstanceProvider+Spec.h"

@implementation MPCoreInstanceProvider (Spec)

+ (MPCoreInstanceProvider *)sharedProvider
{
    return fakeCoreProvider;
}


@end
