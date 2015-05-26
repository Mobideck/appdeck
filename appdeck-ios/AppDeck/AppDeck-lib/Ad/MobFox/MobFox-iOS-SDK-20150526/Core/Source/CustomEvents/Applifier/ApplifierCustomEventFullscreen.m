//
//  ApplifierCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.08.2014.
//
//

#import "ApplifierCustomEventFullscreen.h"

@implementation ApplifierCustomEventFullscreen
static BOOL initialized;

-(void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel {
    
    self.trackingPixel = trackingPixel;
    Class SDKClass = NSClassFromString(@"UnityAds");
    if(!SDKClass) {
        [self notifyAdFailed];
        return;
    }
    
    sdk = [SDKClass sharedInstance];
    if(!initialized) {
        [sdk startWithGameId:optionalParameters];
        [sdk setDelegate:self];
        initialized = true;
    } else {
        if([sdk canShowAds]) {
            [self notifyAdLoaded];
            [sdk setDelegate:self];
        } else {
            [self notifyAdFailed];
        }
    }

}

-(void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped {
}

-(void)unityAdsWillShow {
    [self notifyAdWillAppear];
}

-(void)unityAdsWillHide {
    [self notifyAdWillClose];
}

-(void)unityAdsWillLeaveApplication {
    [self notifyAdWillLeaveApplication];
}

-(void)unityAdsFetchCompleted {
    [self notifyAdLoaded];
}

-(void)unityAdsFetchFailed {
    [self notifyAdFailed];
}

-(void)showFullscreenFromRootViewController:(UIViewController *)rootViewController {
    [sdk setViewController:rootViewController];
    if([sdk canShowAds]) {
        [sdk show];
    }
}

-(void)finish {
    if (sdk) {
        sdk.delegate = nil;
        sdk = nil;
    }
    [super finish];
}

@end
