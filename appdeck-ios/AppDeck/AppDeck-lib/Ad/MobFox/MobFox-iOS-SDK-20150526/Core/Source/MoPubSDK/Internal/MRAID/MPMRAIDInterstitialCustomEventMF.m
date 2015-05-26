//
//  MPMRAIDInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMRAIDInterstitialCustomEventMF.h"
#import "MPInstanceProviderMF.h"
#import "MpLoggingMF.h"

@interface MPMRAIDInterstitialCustomEventMF ()

@property (nonatomic, retain) MPMRAIDInterstitialViewControllerMF *interstitial;

@end

@implementation MPMRAIDInterstitialCustomEventMF

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfoMF(@"Loading MoPub MRAID interstitial");
    self.interstitial = [[MPInstanceProviderMF sharedProvider] buildMPMRAIDInterstitialViewControllerWithDelegate:self
                                                                                                  configuration:[self.delegate configuration]];
    [self.interstitial setCloseButtonStyle:MPInterstitialCloseButtonStyleAdControlled];
    [self.interstitial startLoading];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;

    [super dealloc];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller
{
    [self.interstitial presentInterstitialFromViewController:controller];
}

#pragma mark - MPMRAIDInterstitialViewControllerDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (void)interstitialDidLoadAd:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub MRAID interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub MRAID interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub MRAID interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub MRAID interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub MRAID interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub MRAID interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub MRAID interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
