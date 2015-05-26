//
//  MPInterstitialAdManager.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "MPInterstitialAdManagerMF.h"

#import "MPAdServerURLBuilderMF.h"
#import "MPInterstitialAdControllerMF.h"
#import "MPInterstitialCustomEventAdapterMF.h"
#import "MPInstanceProviderMF.h"
#import "MPCoreInstanceProviderMF.h"
#import "MPInterstitialAdManagerDelegateMF.h"
#import "MpLoggingMF.h"

@interface MPInterstitialAdManagerMF ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign, readwrite) BOOL ready;
@property (nonatomic, retain) MPBaseInterstitialAdapterMF *adapter;
@property (nonatomic, retain) MPAdServerCommunicatorMF *communicator;
@property (nonatomic, retain) MPAdConfigurationMF *configuration;

- (void)setUpAdapterWithConfiguration:(MPAdConfigurationMF *)configuration;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPInterstitialAdManagerMF

@synthesize loading = _loading;
@synthesize ready = _ready;
@synthesize delegate = _delegate;
@synthesize communicator = _communicator;
@synthesize adapter = _adapter;
@synthesize configuration = _configuration;

- (id)initWithDelegate:(id<MPInterstitialAdManagerDelegateMF>)delegate
{
    self = [super init];
    if (self) {
        self.communicator = [[MPCoreInstanceProviderMF sharedProvider] buildMPAdServerCommunicatorWithDelegate:self];
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self.communicator cancel];
    [self.communicator setDelegate:nil];
    self.communicator = nil;

    self.adapter = nil;

    self.configuration = nil;

    [super dealloc];
}

- (void)setAdapter:(MPBaseInterstitialAdapterMF *)adapter
{
    if (self.adapter != adapter) {
        [self.adapter unregisterDelegate];
        [_adapter release];
        _adapter = [adapter retain];
    }
}

#pragma mark - Public

- (void)loadAdWithURL:(NSURL *)URL
{
    if (self.loading) {
        MPLogWarnMF(@"Interstitial controller is already loading an ad. "
                  @"Wait for previous load to finish.");
        return;
    }

    MPLogInfoMF(@"Interstitial controller is loading ad with MoPub server URL: %@", URL);

    self.loading = YES;
    [self.communicator loadURL:URL];
}


- (void)loadInterstitialWithAdUnitID:(NSString *)ID keywords:(NSString *)keywords location:(CLLocation *)location testing:(BOOL)testing
{
    if (self.ready) {
        [self.delegate managerDidLoadInterstitial:self];
    } else {
        [self loadAdWithURL:[MPAdServerURLBuilderMF URLWithAdUnitID:ID
                                                         keywords:keywords
                                                         location:location
                                                          testing:testing]];
    }
}

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    if (self.ready) {
        [self.adapter showInterstitialFromViewController:controller];
    }
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (MPInterstitialAdControllerMF *)interstitialAdController
{
    return [self.delegate interstitialAdController];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

#pragma mark - MPAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfigurationMF *)configuration
{
    self.configuration = configuration;

    MPLogInfoMF(@"Interstatial ad view is fetching ad network type: %@", self.configuration.networkType);

    if ([self.configuration.networkType isEqualToString:@"clear"]) {
        MPLogInfoMF(@"Ad server response indicated no ad available.");
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    if (self.configuration.adType != MPAdTypeInterstitial) {
        MPLogWarnMF(@"Could not load ad: interstitial object received a non-interstitial ad unit ID.");
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    [self setUpAdapterWithConfiguration:self.configuration];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;

    [self.delegate manager:self didFailToLoadInterstitialWithError:error];
}

- (void)setUpAdapterWithConfiguration:(MPAdConfigurationMF *)configuration;
{
    MPBaseInterstitialAdapterMF *adapter = [[MPInstanceProviderMF sharedProvider] buildInterstitialAdapterForConfiguration:configuration
                                                                                                              delegate:self];
    if (!adapter) {
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }

    self.adapter = adapter;
    [self.adapter _getAdWithConfiguration:configuration];
}

#pragma mark - MPInterstitialAdapterDelegate

- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapterMF *)adapter
{
    self.ready = YES;
    self.loading = NO;
    [self.delegate managerDidLoadInterstitial:self];
}

- (void)adapter:(MPBaseInterstitialAdapterMF *)adapter didFailToLoadAdWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;
    [self loadAdWithURL:self.configuration.failoverURL];
}

- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapterMF *)adapter
{
    [self.delegate managerWillPresentInterstitial:self];
}

- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapterMF *)adapter
{
    [self.delegate managerDidPresentInterstitial:self];
}

- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapterMF *)adapter
{
    [self.delegate managerWillDismissInterstitial:self];
}

- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapterMF *)adapter
{
    self.ready = NO;
    [self.delegate managerDidDismissInterstitial:self];
}

- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapterMF *)adapter
{
    self.ready = NO;
    [self.delegate managerDidExpireInterstitial:self];
}

- (void)interstitialWillLeaveApplicationForAdapter:(MPBaseInterstitialAdapterMF *)adapter
{
    // TODO: Signal to delegate.
}

#pragma mark - Legacy Custom Events

- (void)customEventDidLoadAd
{
    // XXX: The deprecated custom event behavior is to report an impression as soon as an ad loads,
    // rather than when the ad is actually displayed. Because of this, you may see impression-
    // reporting discrepancies between MoPub and your custom ad networks.
    if ([self.adapter respondsToSelector:@selector(customEventDidLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidLoadAd)];
    }
}

- (void)customEventDidFailToLoadAd
{
    if ([self.adapter respondsToSelector:@selector(customEventDidFailToLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidFailToLoadAd)];
    }
}

- (void)customEventActionWillBegin
{
    if ([self.adapter respondsToSelector:@selector(customEventActionWillBegin)]) {
        [self.adapter performSelector:@selector(customEventActionWillBegin)];
    }
}

@end
