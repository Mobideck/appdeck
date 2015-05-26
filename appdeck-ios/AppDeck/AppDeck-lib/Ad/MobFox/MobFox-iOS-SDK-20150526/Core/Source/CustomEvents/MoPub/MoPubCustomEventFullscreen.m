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
    
    interstitial = [MPInterstitialAdControllerMF interstitialAdControllerForAdUnitId:optionalParameters];
    
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
- (void)interstitialDidLoadAd:(MPInterstitialAdControllerMF *)interstitial
{
    [self notifyAdLoaded];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdControllerMF *)interstitial
{
    [self notifyAdFailed];
}

- (void)interstitialWillAppear:(MPInterstitialAdControllerMF *)interstitial
{
    [self notifyAdWillAppear];
}

- (void)interstitialWillDisappear:(MPInterstitialAdControllerMF *)interstitial
{
    [self notifyAdWillClose];
}



@end
