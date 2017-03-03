//
//  FakeMPAnalyticsTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAnalyticsTracker.h"

@implementation FakeMPAnalyticsTracker

- (id)init {
    self = [super init];
    if (self) {
        self.trackedImpressionConfigurations = [NSMutableArray array];
        self.trackedClickConfigurations = [NSMutableArray array];
        self.trackingRequestURLs = [NSMutableArray array];
    }
    return self;
}

- (void)reset
{
    [self.trackedImpressionConfigurations removeAllObjects];
    [self.trackedClickConfigurations removeAllObjects];
}

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration
{
    [self.trackedImpressionConfigurations addObject:configuration];
}

- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration
{
    [self.trackedClickConfigurations addObject:configuration];
}

- (void)sendTrackingRequestForURLs:(NSArray *)URLs
{
    [self.trackingRequestURLs addObjectsFromArray:URLs];
}

@end
