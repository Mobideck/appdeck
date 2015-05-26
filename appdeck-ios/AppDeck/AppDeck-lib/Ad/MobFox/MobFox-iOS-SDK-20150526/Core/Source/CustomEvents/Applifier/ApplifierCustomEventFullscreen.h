//
//  ApplifierCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.08.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import <UnityAds/UnityAds.h>

@interface ApplifierCustomEventFullscreen : MFCustomEventFullscreen <UnityAdsDelegate> {
    UnityAds* sdk;
}

@end
