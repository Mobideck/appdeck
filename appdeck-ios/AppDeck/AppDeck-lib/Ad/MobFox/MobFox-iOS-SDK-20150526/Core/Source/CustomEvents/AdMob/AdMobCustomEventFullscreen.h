//
//  AdMobCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AdMobCustomEventFullscreen : MFCustomEventFullscreen <GADInterstitialDelegate> {
    
    GADInterstitial *interstitial_;
}

@end
