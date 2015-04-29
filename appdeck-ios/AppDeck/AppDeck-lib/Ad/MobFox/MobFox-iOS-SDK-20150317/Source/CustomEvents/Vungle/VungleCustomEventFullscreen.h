//
//  VungleCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "CustomEventFullscreen.h"
#import <VungleSDK/VungleSDK.h>

@interface VungleCustomEventFullscreen : CustomEventFullscreen <VungleSDKDelegate> {
    VungleSDK* sdk;
    NSTimer *checkStatusTimer;
}

@end
