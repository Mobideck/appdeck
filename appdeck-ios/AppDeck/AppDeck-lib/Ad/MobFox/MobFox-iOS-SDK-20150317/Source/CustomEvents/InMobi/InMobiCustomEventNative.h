//
//  InMobiCustomEventNative.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 03.07.2014.
//
//

#import "CustomEventNative.h"
#import "IMNative.h"
#import "IMNativeDelegate.h"
#import "InMobi.h"

@interface InMobiCustomEventNative : CustomEventNative <IMNativeDelegate> {
    IMNative* inMobiNative;
}

@end
