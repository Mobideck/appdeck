//
//  FacebookCustomEventNative.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 04.07.2014.
//
//

#import "MFCustomEventNative.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FacebookCustomEventNative : MFCustomEventNative <FBNativeAdDelegate> {
    FBNativeAd* facebookNativeAd;
}

@end
