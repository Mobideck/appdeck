//
//  UnityAds+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "UnityAds+Specs.h"

@implementation UnityAds (Specs)

static NSString *gGameId;
static NSDictionary *gShowDictionary;

- (void)startWithGameId:(NSString *)gameId
{
    gGameId = [gameId copy];
}

- (BOOL)show:(NSDictionary *)dictionary
{
    gShowDictionary = dictionary;
    return YES;
}

+ (NSString *)mp_getGameId
{
    return gGameId;
}

+ (NSDictionary *)mp_getShowDictionary
{
    return gShowDictionary;
}

@end
