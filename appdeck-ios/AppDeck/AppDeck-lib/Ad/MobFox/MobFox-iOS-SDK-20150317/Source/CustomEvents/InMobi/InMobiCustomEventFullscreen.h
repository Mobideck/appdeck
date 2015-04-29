//
//  InMobiCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 08.07.2014.
//
//

#import "CustomEventFullscreen.h"
#import "IMInterstitial.h"
#import "IMInterstitialDelegate.h"

@interface InMobiCustomEventFullscreen : CustomEventFullscreen <IMInterstitialDelegate> {
    IMInterstitial* interstitial;    
}



@end
