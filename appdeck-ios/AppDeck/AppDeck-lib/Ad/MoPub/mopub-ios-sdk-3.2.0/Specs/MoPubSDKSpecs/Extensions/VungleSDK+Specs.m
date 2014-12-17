//
//  VungleSDK+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "VungleSDK+Specs.h"

static NSString *gAppId;

@implementation VungleSDK (Specs)

- (void)startWithAppId:(NSString *)appId
{
    gAppId = [appId copy];
}

+ (NSString *)mp_getAppId
{
    return gAppId;
}

@end
