//
//  AdMobCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//

#import "AdMobCustomEventFullscreen.h"

@implementation AdMobCustomEventFullscreen

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    if(interstitial_) {
        interstitial_.delegate = nil;
        interstitial_ = nil;
    }
    
    Class interstitialClass = NSClassFromString(@"GADInterstitial");
    Class requestClass = NSClassFromString(@"GADRequest");
    if(!interstitialClass || !requestClass) {
        [self notifyAdFailed];
        return;
    }
    
    interstitial_ = [[interstitialClass alloc] init];
    interstitial_.adUnitID = optionalParameters;
    interstitial_.delegate = self;
    
    GADRequest *request = [requestClass request];    
    [interstitial_ loadRequest:request];
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    [interstitial_ presentFromRootViewController:rootViewController];
}

- (void)dealloc
{
    interstitial_.delegate = nil;
    interstitial_ = nil;
}

#pragma mark GADInterstitialDelegate methods
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    [self notifyAdLoaded];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self notifyAdFailed];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    [self notifyAdWillAppear];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial
{
    [self notifyAdWillClose];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)interstitial
{
    [self notifyAdWillLeaveApplication];
}



@end
