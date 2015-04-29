//
//  FacebookCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 16.06.2014.
//
//

#import "FacebookCustomEventFullscreen.h"

@implementation FacebookCustomEventFullscreen

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    if(interstitial) {
        interstitial.delegate = nil;
        interstitial = nil;
    }
    
    Class interstitialClass = NSClassFromString(@"FBInterstitialAd");
    if(!interstitialClass) {
        [self notifyAdFailed];
        return;
    }
    
    interstitial = [[interstitialClass alloc] initWithPlacementID:optionalParameters];
    interstitial.delegate = self;
    
    [interstitial loadAd];
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    if([interstitial isAdValid]) {
        if([interstitial showAdFromRootViewController:rootViewController]) {
            [self notifyAdWillAppear];
        }
    }
    
}

- (void)dealloc
{
    interstitial.delegate = nil;
    interstitial = nil;
}

#pragma mark delegate methods

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self notifyAdWillLeaveApplication];
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd {
    [self notifyAdWillClose];
}

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self notifyAdLoaded];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self notifyAdFailed];
}






@end
