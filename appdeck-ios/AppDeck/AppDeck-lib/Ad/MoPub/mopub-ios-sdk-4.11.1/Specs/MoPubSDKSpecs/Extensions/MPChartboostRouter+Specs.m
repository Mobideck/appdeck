//
//  MPChartboostRouter+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPChartboostRouter+Specs.h"

@implementation MPChartboostRouter (Specs)

- (void)reset
{
    [self.rewardedVideoEvents removeAllObjects];
    [self.interstitialEvents removeAllObjects];
    [self.activeInterstitialLocations removeAllObjects];
}

@end
