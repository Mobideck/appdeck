//
//  MPNativeAd+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAd+Specs.h"

static NSUInteger gTrackMetricURLCallsCount;

@implementation MPNativeAd (Specs)

@dynamic associatedView;

+ (NSUInteger)mp_trackMetricURLCallsCount
{
    return gTrackMetricURLCallsCount;
}

+ (void)mp_clearTrackMetricURLCallsCount
{
    gTrackMetricURLCallsCount = 0;
}

- (void)trackMetricForURL:(NSURL *)URL
{
    ++gTrackMetricURLCallsCount;
}

@end
