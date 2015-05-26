//
//  MPBaseInterstitialAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MPBaseInterstitialAdapterMF.h"
#import "MPAdConfigurationMF.h"
#import "MPGlobalMF.h"
#import "MPAnalyticsTrackerMF.h"
#import "MPCoreInstanceProviderMF.h"
#import "MPTimerMF.h"
#import "MPConstantsMF.h"

@interface MPBaseInterstitialAdapterMF ()

@property (nonatomic, retain) MPAdConfigurationMF *configuration;
@property (nonatomic, retain) MPTimerMF *timeoutTimer;

- (void)startTimeoutTimer;

@end

@implementation MPBaseInterstitialAdapterMF

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<MPInterstitialAdapterDelegateMF>)delegate
{
    self = [super init];
    if (self) {
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

- (void)getAdWithConfiguration:(MPAdConfigurationMF *)configuration
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MPAdConfigurationMF *)configuration
{
    self.configuration = configuration;

    [self startTimeoutTimer];

    [self retain];
    [self getAdWithConfiguration:configuration];
    [self release];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
            self.configuration.adTimeoutInterval : INTERSTITIAL_TIMEOUT_INTERVAL;
    
    if (timeInterval > 0) {
        self.timeoutTimer = [[MPCoreInstanceProviderMF sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO];
        
        [self.timeoutTimer scheduleNow];
    }
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)timeout
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Presentation

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self doesNotRecognizeSelector:_cmd];
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

