//
//  MPBaseBannerAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPBaseBannerAdapterMF.h"
#import "MPConstantsMF.h"

#import "MPAdConfigurationMF.h"
#import "MPLoggingMF.h"
#import "MPCoreInstanceProviderMF.h"
#import "MPAnalyticsTrackerMF.h"
#import "MPTimerMF.h"

@interface MPBaseBannerAdapterMF ()

@property (nonatomic, retain) MPAdConfigurationMF *configuration;
@property (nonatomic, retain) MPTimerMF *timeoutTimer;

- (void)startTimeoutTimer;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPBaseBannerAdapterMF

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<MPBannerAdapterDelegateMF>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterDelegate];
    self.configuration = nil;

    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;

    [super dealloc];
}

- (void)unregisterDelegate
{
    self.delegate = nil;
}

#pragma mark - Requesting Ads

- (void)getAdWithConfiguration:(MPAdConfigurationMF *)configuration containerSize:(CGSize)size
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MPAdConfigurationMF *)configuration containerSize:(CGSize)size
{
    self.configuration = configuration;

    [self startTimeoutTimer];

    [self retain];
    [self getAdWithConfiguration:configuration containerSize:size];
    [self release];
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)didDisplayAd
{
    [self trackImpression];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
    self.configuration.adTimeoutInterval : BANNER_TIMEOUT_INTERVAL;
    
    if (timeInterval > 0) {
        self.timeoutTimer = [[MPCoreInstanceProviderMF sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO];
        
        [self.timeoutTimer scheduleNow];
    }
}

- (void)timeout
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Rotation

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    // Do nothing by default. Subclasses can override.
    MPLogDebugMF(@"rotateToOrientation %d called for adapter %@ (%p)",
          newOrientation, NSStringFromClass([self class]), self);
}

#pragma mark - Metrics

- (void)trackImpression
{
    [[[MPCoreInstanceProviderMF sharedProvider] sharedMPAnalyticsTracker] trackImpressionForConfiguration:self.configuration];
}

- (void)trackClick
{
    [[[MPCoreInstanceProviderMF sharedProvider] sharedMPAnalyticsTracker] trackClickForConfiguration:self.configuration];
}

@end
