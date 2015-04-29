//
//  AdMobCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//

#import "CustomEventFullscreen.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"

@interface AdMobCustomEventFullscreen : CustomEventFullscreen <GADInterstitialDelegate> {
    
    GADInterstitial *interstitial_;
}

@end
