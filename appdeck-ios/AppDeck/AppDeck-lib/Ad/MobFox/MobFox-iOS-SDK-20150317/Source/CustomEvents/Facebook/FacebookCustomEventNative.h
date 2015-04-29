//
//  FacebookCustomEventNative.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 04.07.2014.
//
//

#import "CustomEventNative.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FacebookCustomEventNative : CustomEventNative <FBNativeAdDelegate> {
    FBNativeAd* facebookNativeAd;
}

@end
