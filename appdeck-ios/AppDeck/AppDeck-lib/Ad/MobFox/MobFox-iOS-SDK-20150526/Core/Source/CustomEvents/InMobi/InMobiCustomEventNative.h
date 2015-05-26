//
//  InMobiCustomEventNative.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 03.07.2014.
//
//

#import "MFCustomEventNative.h"
#import "IMNative.h"
#import "IMNativeDelegate.h"
#import "InMobi.h"

@interface InMobiCustomEventNative : MFCustomEventNative <IMNativeDelegate> {
    IMNative* inMobiNative;
}

@end
