//
//  MPAnalyticsTracker.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdConfigurationMF;

@interface MPAnalyticsTrackerMF : NSObject

+ (MPAnalyticsTrackerMF *)tracker;

- (void)trackImpressionForConfiguration:(MPAdConfigurationMF *)configuration;
- (void)trackClickForConfiguration:(MPAdConfigurationMF *)configuration;

@end
