//
//  VungleSDK+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "VungleSDK+Specs.h"

static NSString *gAppId;
static NSDictionary *gPlayOptions;

@implementation VungleSDK (Specs)

- (void)startWithAppId:(NSString *)appId
{
    gAppId = [appId copy];
}


- (BOOL)playAd:(UIViewController *)viewController withOptions:(id)options error:(NSError **)error
{
    gPlayOptions = options;
    return YES;
}

+ (NSString *)mp_getAppId
{
    return gAppId;
}

+ (NSDictionary *)mp_getPlayOptionsDictionary
{
    return gPlayOptions;
}

@end
