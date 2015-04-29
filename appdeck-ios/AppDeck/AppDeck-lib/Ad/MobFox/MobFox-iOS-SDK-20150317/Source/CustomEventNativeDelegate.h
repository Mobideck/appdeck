//
//  CustomEventNativeDelegate.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 01.07.2014.
//
//

#import <Foundation/Foundation.h>

@class MobFoxNativeAd;

@protocol CustomEventNativeDelegate <NSObject>

-(void)customEventNativeFailed;
-(void)customEventNativeLoaded:(MobFoxNativeAd*) nativeAd;

@end
