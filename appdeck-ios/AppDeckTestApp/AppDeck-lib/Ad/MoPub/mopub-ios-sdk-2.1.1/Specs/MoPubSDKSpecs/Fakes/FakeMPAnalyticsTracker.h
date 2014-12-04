//
//  FakeMPAnalyticsTracker.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAnalyticsTracker.h"

@interface FakeMPAnalyticsTracker : MPAnalyticsTracker

@property (nonatomic, retain) NSMutableArray *trackedImpressionConfigurations;
@property (nonatomic, retain) NSMutableArray *trackedClickConfigurations;

- (void)reset;

@end
