//
//  InMobiCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 08.07.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import "IMInterstitial.h"
#import "IMInterstitialDelegate.h"

@interface InMobiCustomEventFullscreen : MFCustomEventFullscreen <IMInterstitialDelegate> {
    IMInterstitial* interstitial;    
}



@end
