//
//  MRBundleManager.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRBundleManagerMF.h"

@implementation MRBundleManagerMF

static MRBundleManagerMF *sharedManager = nil;

+ (MRBundleManagerMF *)sharedManager
{
    if (!sharedManager) {
        sharedManager = [[MRBundleManagerMF alloc] init];
    }
    return sharedManager;
}

- (NSString *)mraidPath
{
    NSString *mraidBundlePath = [[NSBundle mainBundle] pathForResource:@"MRAID" ofType:@"bundle"];
    NSBundle *mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
    return [mraidBundle pathForResource:@"mraid" ofType:@"js"];
}

@end

