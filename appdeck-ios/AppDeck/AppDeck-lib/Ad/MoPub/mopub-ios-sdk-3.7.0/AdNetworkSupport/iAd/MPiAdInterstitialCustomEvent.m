//
//  MPiAdInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <iAd/iAd.h>
#import "MPiAdInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"
#import "MPInterstitialViewController.h"

@interface MPInstanceProvider (iAdInterstitials)

- (ADInterstitialAd *)buildADInterstitialAd;

@end

@implementation MPInstanceProvider (iAdInterstitials)

- (ADInterstitialAd *)buildADInterstitialAd
{
    return [[ADInterstitialAd alloc] init];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPiAdInterstitialViewControllerDelegate <NSObject>

- (void)closeButtonPressed;
- (void)willPresentInterstitial;
- (void)didPresentInterstitial;

@end

@interface MPiAdInterstitialViewController : MPInterstitialViewController

@property (nonatomic, weak) id<MPiAdInterstitialViewControllerDelegate> iAdVCDelegate;

@end

@implementation MPiAdInterstitialViewController

// override
- (void)closeButtonPressed
{
    [self.iAdVCDelegate closeButtonPressed];
}

// override
- (void)willPresentInterstitial
{
    [self.iAdVCDelegate willPresentInterstitial];
}

// override
- (void)didPresentInterstitial
{
    [self.iAdVCDelegate didPresentInterstitial];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPiAdInterstitialCustomEvent () <MPiAdInterstitialViewControllerDelegate, ADInterstitialAdDelegate>

@property (nonatomic, strong) ADInterstitialAd *iAdInterstitial;
@property (nonatomic, assign) BOOL isOnScreen;
@property (nonatomic, assign) BOOL willBeOnScreen;
@property (nonatomic, strong) UIViewController *presentingRootViewController;
@property (nonatomic, strong) MPiAdInterstitialViewController *iAdInterstitialViewController;

@end

@implementation MPiAdInterstitialCustomEvent

@synthesize iAdInterstitial = _iAdInterstitial;
@synthesize isOnScreen = _isOnScreen;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting iAd interstitial");

    self.iAdInterstitial = [[MPInstanceProvider sharedProvider] buildADInterstitialAd];
    self.iAdInterstitial.delegate = self;

    self.iAdInterstitialViewController = [[MPiAdInterstitialViewController alloc] init];
    self.iAdInterstitialViewController.closeButtonStyle = MPInterstitialCloseButtonStyleAlwaysVisible;
    self.iAdInterstitialViewController.iAdVCDelegate = self;
}

- (void)dealloc
{
    self.iAdInterstitial.delegate = nil;
}

- (void)closeButtonPressed
{
    [self dismissInterstitialAdIfNecessary];
}

- (void)willPresentInterstitial
{
    self.willBeOnScreen = YES;
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)didPresentInterstitial
{
    self.willBeOnScreen = NO;
    self.isOnScreen = YES;
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller {
    if (self.willBeOnScreen || self.isOnScreen) {
        MPLogWarn(@"Cannot show an iAd interstitial that's already been shown or will be shown");
        return;
    }

    // ADInterstitialAd throws an exception if we don't check the loaded flag prior to presenting.
    if (self.iAdInterstitial.loaded) {
        if ([self.iAdInterstitial presentInView:self.iAdInterstitialViewController.view]) {
            self.presentingRootViewController = controller;
            [self.iAdInterstitialViewController presentInterstitialFromViewController:self.presentingRootViewController];
        } else {
            MPLogInfo(@"Failed to show iAd interstitial: presentInView: returned NO");
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        }
    } else {
        MPLogInfo(@"Failed to show iAd interstitial: a previously loaded iAd interstitial now claims not to be ready.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)dismissInterstitialAdIfNecessary
{
    self.willBeOnScreen = NO;

    if (self.isOnScreen) {
        [self.presentingRootViewController dismissViewControllerAnimated:YES completion:nil];
        [self.delegate interstitialCustomEventWillDisappear:self];
        [self.delegate interstitialCustomEventDidDisappear:self];
        self.isOnScreen = NO; //technically not necessary as iAd interstitials are single use
        self.presentingRootViewController = nil;
    }
}

#pragma mark - <ADInterstitialAdDelegate>

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd {
    MPLogInfo(@"iAd interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.iAdInterstitial];
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    MPLogInfo(@"iAd interstitial failed with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
    // This method may be called whether the ad is on-screen or not. We only want to invoke the
    // "disappear" callbacks if the ad is on-screen.
    MPLogInfo(@"iAd interstitial did unload");

    [self dismissInterstitialAdIfNecessary];

    // ADInterstitialAd can't be shown again after it has unloaded, so notify the controller.
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd
                   willLeaveApplication:(BOOL)willLeave {
    MPLogInfo(@"iAd interstitial will begin action");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    return YES; // YES allows the action to execute (NO would instead cancel the action).
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    MPLogInfo(@"iAd interstitial did finish");

    [self dismissInterstitialAdIfNecessary];
}

@end
