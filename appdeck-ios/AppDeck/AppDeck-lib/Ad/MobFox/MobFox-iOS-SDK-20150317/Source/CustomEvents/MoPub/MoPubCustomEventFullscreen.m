//
//  MoPubCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "MoPubCustomEventFullscreen.h"

@implementation MoPubCustomEventFullscreen


- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    
    interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:optionalParameters];
    
    interstitial.delegate = self;
    
    [interstitial loadAd];
    
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    if(interstitial.ready) {
        [interstitial showFromViewController:rootViewController];
    }
}

- (void)dealloc
{
    interstitial.delegate = nil;
    interstitial = nil;
}

#pragma mark delegate methods
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    [self notifyAdLoaded];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    [self notifyAdFailed];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    [self notifyAdWillAppear];
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    [self notifyAdWillClose];
}



@end
