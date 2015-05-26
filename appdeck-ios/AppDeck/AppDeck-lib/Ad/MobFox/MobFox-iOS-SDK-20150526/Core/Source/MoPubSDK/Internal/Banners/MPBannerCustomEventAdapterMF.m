//
//  MPBannerCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBannerCustomEventAdapterMF.h"

#import "MPAdConfigurationMF.h"
#import "MPBannerCustomEventMF.h"
#import "MPInstanceProviderMF.h"
#import "MpLoggingMF.h"

@interface MPBannerCustomEventAdapterMF ()

@property (nonatomic, retain) MPBannerCustomEventMF *bannerCustomEvent;
@property (nonatomic, retain) MPAdConfigurationMF *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

- (void)trackClickOnce;

@end

@implementation MPBannerCustomEventAdapterMF
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

- (void)unregisterDelegate
{
    if ([self.bannerCustomEvent respondsToSelector:@selector(invalidate)]) {
        // Secret API to allow us to detach the custom event from (shared instance) routers synchronously
        // See the iAd banner custom event for an example use case.
        [self.bannerCustomEvent performSelector:@selector(invalidate)];
    }
    self.bannerCustomEvent.delegate = nil;
    [[_bannerCustomEvent retain] autorelease]; //make sure the custom event isn't released immediately
    self.bannerCustomEvent = nil;

    [super unregisterDelegate];
}

- (void)dealloc {
    self.configuration = nil;
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getAdWithConfiguration:(MPAdConfigurationMF *)configuration containerSize:(CGSize)size
{
    MPLogInfoMF(@"Looking for custom event class named %@.", configuration.customEventClass);
    self.configuration = configuration;

    self.bannerCustomEvent = [[MPInstanceProviderMF sharedProvider] buildBannerCustomEventFromCustomClass:configuration.customEventClass
                                                                                               delegate:self];
    if (self.bannerCustomEvent) {
        [self.bannerCustomEvent requestAdWithSize:size customEventInfo:configuration.customEventClassData];
    } else {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerCustomEvent rotateToOrientation:newOrientation];
}

- (void)didDisplayAd
{
    if ([self.bannerCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedImpression) {
        self.hasTrackedImpression = YES;
        [self trackImpression];
    }

    [self.bannerCustomEvent didDisplayAd];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - MPPrivateBannerCustomEventDelegate

- (NSString *)adUnitId
{
    return [self.delegate banner].adUnitId;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (id)bannerDelegate
{
    return [self.delegate bannerDelegate];
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (void)bannerCustomEvent:(MPBannerCustomEventMF *)event didLoadAd:(UIView *)ad
{
    [self didStopLoading];
    if (ad) {
        [self.delegate adapter:self didFinishLoadingAd:ad];
    } else {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)bannerCustomEvent:(MPBannerCustomEventMF *)event didFailToLoadAdWithError:(NSError *)error
{
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerCustomEventWillBeginAction:(MPBannerCustomEventMF *)event
{
    [self trackClickOnce];
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)bannerCustomEventDidFinishAction:(MPBannerCustomEventMF *)event
{
    [self.delegate userActionDidFinishForAdapter:self];
}

- (void)bannerCustomEventWillLeaveApplication:(MPBannerCustomEventMF *)event
{
    [self trackClickOnce];
    [self.delegate userWillLeaveApplicationFromAdapter:self];
}

- (void)trackClickOnce
{
    if ([self.bannerCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedClick) {
        self.hasTrackedClick = YES;
        [self trackClick];
    }
}

@end
