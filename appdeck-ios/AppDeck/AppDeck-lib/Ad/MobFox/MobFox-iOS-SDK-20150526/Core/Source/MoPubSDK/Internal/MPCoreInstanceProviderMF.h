//
//  MPCoreInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPGlobalMF.h"


@class MPAdConfigurationMF;

// Fetching Ads
@class MPAdServerCommunicatorMF;
@protocol MPAdServerCommunicatorDelegateMF;

// URL Handling
@class MPURLResolverMF;
@class MPAdDestinationDisplayAgentMF;
@protocol MPAdDestinationDisplayAgentDelegateMF;

// Utilities
@class MPAdAlertManagerMF, MPAdAlertGestureRecognizerMF;
@class MPAnalyticsTrackerMF;
@class MPReachabilityMF;
@class MPTimerMF;

typedef id(^MPSingletonProviderBlock)();

typedef enum {
    MPTwitterAvailabilityNone = 0,
    MPTwitterAvailabilityApp = 1 << 0,
    MPTwitterAvailabilityNative = 1 << 1,
} MPTwitterAvailability;

@interface MPCoreInstanceProviderMF : NSObject

+ (instancetype)sharedProvider;
- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider;

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL;
- (MPAdServerCommunicatorMF *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegateMF>)delegate;

#pragma mark - URL Handling
- (MPURLResolverMF *)buildMPURLResolver;
- (MPAdDestinationDisplayAgentMF *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateMF>)delegate;

#pragma mark - Utilities
- (id<MPAdAlertManagerProtocolMF>)buildMPAdAlertManagerWithDelegate:(id)delegate;
- (MPAdAlertGestureRecognizerMF *)buildMPAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (NSOperationQueue *)sharedOperationQueue;
- (MPAnalyticsTrackerMF *)sharedMPAnalyticsTracker;
- (MPReachabilityMF *)sharedMPReachability;

// This call may return nil and may not update if the user hot-swaps the device's sim card.
- (NSDictionary *)sharedCarrierInfo;

- (MPTimerMF *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;

- (MPTwitterAvailability)twitterAvailabilityOnDevice;
- (void)resetTwitterAppInstallCheck;


@end
