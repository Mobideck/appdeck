//
//  MPHTMLBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPHTMLBannerCustomEventMF.h"
#import "MPAdWebViewMF.h"
#import "MpLoggingMF.h"
#import "MPAdConfigurationMF.h"
#import "MPInstanceProviderMF.h"

@interface MPHTMLBannerCustomEventMF ()

@property (nonatomic, retain) MPAdWebViewAgentMF *bannerAgent;

@end

@implementation MPHTMLBannerCustomEventMF

@synthesize bannerAgent = _bannerAgent;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfoMF(@"Loading MoPub HTML banner");
    MPLogTraceMF(@"Loading banner with HTML source: %@", [[self.delegate configuration] adResponseHTMLString]);

    CGRect adWebViewFrame = CGRectMake(0, 0, size.width, size.height);
    self.bannerAgent = [[MPInstanceProviderMF sharedProvider] buildMPAdWebViewAgentWithAdWebViewFrame:adWebViewFrame
                                                                                           delegate:self
                                                                               customMethodDelegate:[self.delegate bannerDelegate]];
    [self.bannerAgent loadConfiguration:[self.delegate configuration]];
}

- (void)dealloc
{
    self.bannerAgent.delegate = nil;
    self.bannerAgent.customMethodDelegate = nil;
    self.bannerAgent = nil;

    [super dealloc];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerAgent rotateToOrientation:newOrientation];
}

#pragma mark - MPAdWebViewAgentDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidFinishLoadingAd:(MPAdWebViewMF *)ad
{
    MPLogInfoMF(@"MoPub HTML banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:ad];
}

- (void)adDidFailToLoadAd:(MPAdWebViewMF *)ad
{
    MPLogInfoMF(@"MoPub HTML banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adDidClose:(MPAdWebViewMF *)ad
{
    //don't care
}

- (void)adActionWillBegin:(MPAdWebViewMF *)ad
{
    MPLogInfoMF(@"MoPub HTML banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adActionDidFinish:(MPAdWebViewMF *)ad
{
    MPLogInfoMF(@"MoPub HTML banner did finish action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adActionWillLeaveApplication:(MPAdWebViewMF *)ad
{
    MPLogInfoMF(@"MoPub HTML banner will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}


@end
