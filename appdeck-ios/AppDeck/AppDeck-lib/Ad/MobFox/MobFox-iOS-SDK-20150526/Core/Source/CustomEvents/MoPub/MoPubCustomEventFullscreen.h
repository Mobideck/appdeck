//
//  MoPubCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import "MPInterstitialAdControllerMF.h"

@interface MoPubCustomEventFullscreen : MFCustomEventFullscreen <MPInterstitialAdControllerDelegateMF> {
    MPInterstitialAdControllerMF* interstitial;
}

@end
