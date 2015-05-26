//
//  CustomEventNative.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 01.07.2014.
//
//

#import "MobFoxNativeAd.h"
#import "MFCustomEventNativeDelegate.h"

@interface MFCustomEventNative : MobFoxNativeAd

-(void) loadNativeAdWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel;

-(void)addImageAssetWithImageUrl:(NSString*)url andType:(NSString*)type;

-(void)addImpressionTrackerWithUrl:(NSString*)url;

-(void)addExtraAsset:(NSString*)asset withType:(NSString*)type;

-(void)destroy;

@property (nonatomic, strong) id<MFCustomEventNativeDelegate> delegate;

@end
