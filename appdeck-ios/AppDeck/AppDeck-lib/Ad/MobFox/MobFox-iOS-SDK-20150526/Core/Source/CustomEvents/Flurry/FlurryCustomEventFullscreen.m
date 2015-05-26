//
//  FlurryCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 14.07.2014.
//
//

#import "FlurryCustomEventFullscreen.h"

@interface FlurryCustomEventFullscreen()
@property (nonatomic, strong) NSString* adSpace;
@end

@implementation FlurryCustomEventFullscreen

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    NSString* adId;
    NSArray *tmp=[optionalParameters componentsSeparatedByString:@";"];
    
    Class flurryClass = NSClassFromString(@"Flurry");
    Class flurryAdsClass = NSClassFromString(@"FlurryAds");
    if(!flurryClass || !flurryAdsClass || [tmp count] != 2) {
        [self notifyAdFailed];
        return;
    }
    _adSpace = [tmp objectAtIndex:0];
    adId = [tmp objectAtIndex:1];
    
    [flurryClass startSession:adId];
    [flurryAdsClass initialize:[self.delegate viewControllerForPresentingModalView]];
    [flurryAdsClass setAdDelegate:self];
    [flurryAdsClass fetchAdForSpace:_adSpace frame:[self.delegate viewControllerForPresentingModalView].view.frame size:FULLSCREEN];
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    Class flurryAdsClass = NSClassFromString(@"FlurryAds");
    [flurryAdsClass displayAdForSpace:_adSpace onView:rootViewController.view];
}

- (void)dealloc {
    [self finish];
}

-(void)finish {
    [super finish];
    Class flurryAdsClass = NSClassFromString(@"FlurryAds");
    [flurryAdsClass removeAdFromSpace:_adSpace];
    [flurryAdsClass setAdDelegate:nil];
}

-(BOOL)spaceShouldDisplay:(NSString *)adSpace interstitial:(BOOL)interstitial {
    
    if(interstitial) {
        [self notifyAdWillAppear];
    }
    
    return true;
}

-(void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {

    if(interstitial) {
        [self notifyAdWillClose];
    }
}

-(void)spaceDidReceiveAd:(NSString *)adSpace {
    if(![adSpace isEqualToString:_adSpace]) {
        return;
    }
    
    [self notifyAdLoaded];
}

-(void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error {
    if(![adSpace isEqualToString:_adSpace]) {
        return;
    }
    
    [self notifyAdFailed];
}

-(void)spaceWillLeaveApplication:(NSString *)adSpace {
    if(![adSpace isEqualToString:_adSpace]) {
        return;
    }
    [self notifyAdWillLeaveApplication];
}



@end
