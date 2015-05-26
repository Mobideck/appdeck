//
//  FacebookCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 16.06.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FacebookCustomEventFullscreen : MFCustomEventFullscreen <FBInterstitialAdDelegate> {
    FBInterstitialAd *interstitial;
}

@end
