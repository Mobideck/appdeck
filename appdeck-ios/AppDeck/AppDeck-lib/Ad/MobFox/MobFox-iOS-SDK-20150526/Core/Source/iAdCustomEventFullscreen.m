//
//  iAdCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 14.03.2014.
//
//

#import "iAdCustomEventFullscreen.h"
#import "MFCustomEventFullscreen.h"

@implementation iAdCustomEventFullscreen
static ADInterstitialAd *interstitial_;
static BOOL initialized;

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    if(!initialized) {
        interstitial_ = [[ADInterstitialAd alloc] init];
        interstitial_.delegate = self;
        initialized = YES;
    } else if([interstitial_ isLoaded]) {
        [self notifyAdLoaded];
    } else {
        [self notifyAdFailed];
    }
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    [interstitial_ presentFromViewController:rootViewController];
}

#pragma mark delegate methods

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self notifyAdFailed];
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd {
    [self notifyAdLoaded];
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd {
    [self notifyAdWillClose];
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    [self notifyAdWillAppear];
    if(willLeave) {
        [self notifyAdWillLeaveApplication];
    }
    return YES;
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
   
}



@end
