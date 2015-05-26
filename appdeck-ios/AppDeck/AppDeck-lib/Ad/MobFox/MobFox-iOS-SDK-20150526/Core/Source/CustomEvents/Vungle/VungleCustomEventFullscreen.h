//
//  VungleCustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "MFCustomEventFullscreen.h"
#import <VungleSDK/VungleSDK.h>

@interface VungleCustomEventFullscreen : MFCustomEventFullscreen <VungleSDKDelegate> {
    VungleSDK* sdk;
    NSTimer *checkStatusTimer;
}

@end
