//
//  InMobiCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 08.07.2014.
//
//

#import "InMobiCustomEventFullscreen.h"

@implementation InMobiCustomEventFullscreen

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    
    Class interstitialClass = NSClassFromString(@"IMInterstitial");
    Class sdkClass = NSClassFromString(@"InMobi");
    if(!interstitialClass || !sdkClass) {
        [self notifyAdFailed];
        return;
    }
    [sdkClass initialize:optionalParameters];
    interstitial = [[interstitialClass alloc]initWithAppId:optionalParameters];
    interstitial.delegate = self;
    [interstitial loadInterstitial];
    
    
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    [interstitial presentInterstitialAnimated:YES];
}

- (void)dealloc
{
    interstitial.delegate = nil;
    interstitial = nil;
}

#pragma mark - Delegate methods
-(void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error {
    [self notifyAdFailed];
}

-(void)interstitialDidDismissScreen:(IMInterstitial *)ad {
    [self notifyAdWillClose];
}

-(void)interstitialDidReceiveAd:(IMInterstitial *)ad {
    [self notifyAdLoaded];
}

-(void)interstitialWillLeaveApplication:(IMInterstitial *)ad {
    [self notifyAdWillLeaveApplication];
}

-(void)interstitialWillPresentScreen:(IMInterstitial *)ad {
    [self notifyAdWillAppear];
}

-(void)interstitial:(IMInterstitial *)ad didFailToPresentScreenWithError:(IMError *)error {
    [self notifyAdWillClose];
}



@end
