//
//  MPInstanceProvider+AdColony.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPInstanceProvider+AdColony.h"
#import "MPAdColonyRouter.h"

@implementation MPInstanceProvider (AdColony)

- (MPAdColonyRouter *)sharedMPAdColonyRouter
{
    return [self singletonForClass:[MPAdColonyRouter class]
                          provider:^id
            {
                return [[MPAdColonyRouter alloc] init];
            }];
}

@end
