//
//  MPNativeAdRequest.m
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPNativeAdRequestMF.h"

#import "MPAdServerURLBuilderMF.h"
#import "MPCoreInstanceProviderMF.h"
#import "MPNativeAdErrorMF.h"
#import "MPNativeAdMF+Internal.h"
#import "MPNativeAdRequestTargetingMF.h"
#import "MpLoggingMF.h"
#import "MPImageDownloadQueueMF.h"
#import "MPConstantsMF.h"
#import "MPNativeCustomEventDelegateMF.h"
#import "MPNativeCustomEventMF.h"
#import "MPInstanceProviderMF.h"
#import "NSJSONSerialization+MPAdditionsMF.h"
#import "MPAdServerCommunicatorMF.h"

#import "MPMoPubNativeCustomEventMF.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPNativeAdRequestMF () <MPNativeCustomEventDelegateMF, MPAdServerCommunicatorDelegateMF>

@property (nonatomic, copy) NSString *adUnitIdentifier;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, retain) MPAdServerCommunicatorMF *communicator;
@property (nonatomic, copy) MPNativeAdRequestHandler completionHandler;
@property (nonatomic, retain) MPNativeCustomEventMF *nativeCustomEvent;
@property (nonatomic, retain) MPAdConfigurationMF *adConfiguration;
@property (nonatomic, assign) BOOL loading;

@end

@implementation MPNativeAdRequestMF

- (id)initWithAdUnitIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _adUnitIdentifier = [identifier copy];
        _communicator = [[[MPCoreInstanceProviderMF sharedProvider] buildMPAdServerCommunicatorWithDelegate:self] retain];
    }
    return self;
}

- (void)dealloc
{
    [_adConfiguration release];
    [_adUnitIdentifier release];
    [_URL release];
    [_communicator cancel];
    [_communicator setDelegate:nil];
    [_communicator release];
    [_completionHandler release];
    [_targeting release];
    [_nativeCustomEvent setDelegate:nil];
    [_nativeCustomEvent release];
    [super dealloc];
}

#pragma mark - Public

+ (MPNativeAdRequestMF *)requestWithAdUnitIdentifier:(NSString *)identifier
{
    return [[[self alloc] initWithAdUnitIdentifier:identifier] autorelease];
}

- (void)startWithCompletionHandler:(MPNativeAdRequestHandler)handler
{
    if (handler)
    {
        self.URL = [MPAdServerURLBuilderMF URLWithAdUnitID:self.adUnitIdentifier
                                                keywords:self.targeting.keywords
                                                location:self.targeting.location
                                    versionParameterName:@"nsv"
                                                 version:MP_SDK_VERSION
                                                 testing:NO
                                           desiredAssets:[self.targeting.desiredAssets allObjects]];

        self.completionHandler = handler;

        [self loadAdWithURL:self.URL];
    }
    else
    {
        MPLogWarnMF(@"Native Ad Request did not start - requires completion handler block.");
    }
}

#pragma mark - Private

- (void)loadAdWithURL:(NSURL *)URL
{
    if (self.loading) {
        MPLogWarnMF(@"Native ad request is already loading an ad. Wait for previous load to finish.");
        return;
    }

    [self retain];

    MPLogInfoMF(@"Starting ad request with URL: %@", self.URL);

    self.loading = YES;
    [self.communicator loadURL:URL];
}

- (void)getAdWithConfiguration:(MPAdConfigurationMF *)configuration
{
    MPLogInfoMF(@"Looking for custom event class named %@.", configuration.customEventClass);\
    // Adserver doesn't return a customEventClass for MoPub native ads
    if([configuration.networkType isEqualToString:kAdTypeNativeMF] && configuration.customEventClass == nil) {
        configuration.customEventClass = [MPMoPubNativeCustomEventMF class];
        NSDictionary *classData = [NSJSONSerialization mp_JSONObjectWithData:configuration.adResponseData options:0 clearNullObjects:YES error:nil];
        configuration.customEventClassData = classData;
    }

    self.nativeCustomEvent = [[MPInstanceProviderMF sharedProvider] buildNativeCustomEventFromCustomClass:configuration.customEventClass delegate:self];

    if (self.nativeCustomEvent) {
        [self.nativeCustomEvent requestAdWithCustomEventInfo:configuration.customEventClassData];
    } else if ([[self.adConfiguration.failoverURL absoluteString] length]) {
        self.loading = NO;
        [self loadAdWithURL:self.adConfiguration.failoverURL];
        [self release];
    } else {
        [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomainMF code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
        [self release];
    }
}

- (void)completeAdRequestWithAdObject:(MPNativeAdMF *)adObject error:(NSError *)error
{
    self.loading = NO;
    if (self.completionHandler) {
        self.completionHandler(self, adObject, error);
        self.completionHandler = nil;
    }
}

#pragma mark - <MPAdServerCommunicatorDelegate>

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfigurationMF *)configuration
{
    self.adConfiguration = configuration;

    if ([configuration.networkType isEqualToString:kAdTypeClearMF]) {
        MPLogInfoMF(@"No inventory available for ad unit: %@", self.adUnitIdentifier);

        [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomainMF code:MPNativeAdErrorNoInventory userInfo:nil]];
        [self release];
    }
    else {
        MPLogInfoMF(@"Received data from MoPub to construct Native ad.");

        [self getAdWithConfiguration:configuration];
    }
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    MPLogDebugMF(@"Error: Couldn't retrieve an ad from MoPub. Message: %@", error);

    [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomainMF code:MPNativeAdErrorHTTPError userInfo:nil]];
    [self release];
}

#pragma mark - <MPNativeCustomEventDelegate>

- (void)nativeCustomEvent:(MPNativeCustomEventMF *)event didLoadAd:(MPNativeAdMF *)adObject
{
    // Take the click tracking URL from the header if the ad object doesn't already have one.
    [adObject setEngagementTrackingURL:(adObject.engagementTrackingURL ? : self.adConfiguration.clickTrackingURL)];

    // Add the impression tracker from the header to our set.
    if (self.adConfiguration.impressionTrackingURL) {
        [adObject.impressionTrackers addObject:[self.adConfiguration.impressionTrackingURL absoluteString]];
    }

    // Error if we don't have click tracker or impression trackers.
    if (!adObject.engagementTrackingURL || adObject.impressionTrackers.count < 1) {
        [self completeAdRequestWithAdObject:nil error:[NSError errorWithDomain:MoPubNativeAdsSDKDomainMF code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
    } else {
        [self completeAdRequestWithAdObject:adObject error:nil];
    }

    [self release];

}

- (void)nativeCustomEvent:(MPNativeCustomEventMF *)event didFailToLoadAdWithError:(NSError *)error
{
    if ([[self.adConfiguration.failoverURL absoluteString] length]) {
        self.loading = NO;
        [self loadAdWithURL:self.adConfiguration.failoverURL];
    } else {
        [self completeAdRequestWithAdObject:nil error:error];
    }

    [self release];
}


@end
