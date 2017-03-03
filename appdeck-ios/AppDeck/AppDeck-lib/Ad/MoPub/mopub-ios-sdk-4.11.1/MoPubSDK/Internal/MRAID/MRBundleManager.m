//
//  MRBundleManager.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRBundleManager.h"
#import "MPGlobal.h"

@implementation MRBundleManager

static MRBundleManager *sharedManager = nil;

+ (MRBundleManager *)sharedManager
{
    if (!sharedManager) {
        sharedManager = [[MRBundleManager alloc] init];
    }
    return sharedManager;
}

- (NSString *)mraidPath
{
    NSBundle *parentBundle = MPResourceBundleForClass(self.class);

    NSString *mraidBundlePath = [parentBundle pathForResource:@"MRAID" ofType:@"bundle"];
    NSBundle *mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
    return [mraidBundle pathForResource:@"mraid" ofType:@"js"];
}

@end
