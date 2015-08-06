//
//  FlurryMPConfig.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryMPConfig.h"

@implementation FlurryMPConfig

+ (id)sharedInstance {
    static FlurryMPConfig *si = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        si = [[self alloc] init];
    });
    return si;
}

- (id)init {
    if (self = [super init]) {
        [Flurry startSession:FlurryAPIKey];
        [Flurry addOrigin:FlurryMediationOrigin withVersion:FlurryAdapterVersion];
        [Flurry setDebugLogEnabled:NO];
    }
    return self;
}

@end
