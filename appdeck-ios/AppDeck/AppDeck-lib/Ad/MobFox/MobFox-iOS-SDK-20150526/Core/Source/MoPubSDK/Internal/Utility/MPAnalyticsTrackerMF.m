//
//  MPAnalyticsTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAnalyticsTrackerMF.h"
#import "MPAdConfigurationMF.h"
#import "MPCoreInstanceProviderMF.h"
#import "MpLoggingMF.h"

@interface MPAnalyticsTrackerMF ()

- (NSURLRequest *)requestForURL:(NSURL *)URL;

@end

@implementation MPAnalyticsTrackerMF

+ (MPAnalyticsTrackerMF *)tracker
{
    return [[[MPAnalyticsTrackerMF alloc] init] autorelease];
}

- (void)trackImpressionForConfiguration:(MPAdConfigurationMF *)configuration
{
    MPLogDebugMF(@"Tracking impression: %@", configuration.impressionTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.impressionTrackingURL]
                                  delegate:nil];
}

- (void)trackClickForConfiguration:(MPAdConfigurationMF *)configuration
{
    MPLogDebugMF(@"Tracking click: %@", configuration.clickTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.clickTrackingURL]
                                  delegate:nil];
}

- (NSURLRequest *)requestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[MPCoreInstanceProviderMF sharedProvider] buildConfiguredURLRequestWithURL:URL];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    return request;
}

@end
