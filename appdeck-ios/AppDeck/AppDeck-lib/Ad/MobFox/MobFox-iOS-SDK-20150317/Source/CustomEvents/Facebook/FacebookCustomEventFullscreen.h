//
//  FacebookCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 16.06.2014.
//
//

#import "CustomEventFullscreen.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FacebookCustomEventFullscreen : CustomEventFullscreen <FBInterstitialAdDelegate> {
    FBInterstitialAd *interstitial;
}

@end
