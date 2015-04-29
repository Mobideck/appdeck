//
//  ApplifierCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.08.2014.
//
//

#import "CustomEventFullscreen.h"
#import <UnityAds/UnityAds.h>

@interface ApplifierCustomEventFullscreen : CustomEventFullscreen <UnityAdsDelegate> {
    UnityAds* sdk;
}

@end
