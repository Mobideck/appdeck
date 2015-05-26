//
//  MPHTMLInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPHTMLInterstitialCustomEventMF.h"
#import "MpLoggingMF.h"
#import "MPAdConfigurationMF.h"
#import "MPInstanceProviderMF.h"

@interface MPHTMLInterstitialCustomEventMF ()

@property (nonatomic, retain) MPHTMLInterstitialViewControllerMF *interstitial;

@end

@implementation MPHTMLInterstitialCustomEventMF

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfoMF(@"Loading MoPub HTML interstitial");
    MPAdConfigurationMF *configuration = [self.delegate configuration];
    MPLogTraceMF(@"Loading HTML interstitial with source: %@", [configuration adResponseHTMLString]);

    self.interstitial = [[MPInstanceProviderMF sharedProvider] buildMPHTMLInterstitialViewControllerWithDelegate:self
                                                                                               orientationType:configuration.orientationType
                                                                                          customMethodDelegate:[self.delegate interstitialDelegate]];
    [self.interstitial loadConfiguration:configuration];
}

- (void)dealloc
{
    [self.interstitial setDelegate:nil];
    [self.interstitial setCustomMethodDelegate:nil];
    self.interstitial = nil;
    [super dealloc];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentInterstitialFromViewController:rootViewController];
}

#pragma mark - MPInterstitialViewControllerDelegate

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
    MPLogInfoMF(@"MoPub HTML interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub HTML interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub HTML interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub HTML interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub HTML interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub HTML interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(MPInterstitialViewControllerMF *)interstitial
{
    MPLogInfoMF(@"MoPub HTML interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
