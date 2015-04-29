//
//  MoPubCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "CustomEventFullscreen.h"
#import "MPInterstitialAdController.h"

@interface MoPubCustomEventFullscreen : CustomEventFullscreen <MPInterstitialAdControllerDelegate> {
    MPInterstitialAdController* interstitial;
}

@end
