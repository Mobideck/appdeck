//
//  CustomEventBanner.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 20.02.2014.
//
//

#import <Foundation/Foundation.h>
#import "MFCustomEventBannerDelegate.h"

@interface MFCustomEventBanner : NSObject

- (void)loadBannerWithSize:(CGSize)size optionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel;

- (void)didDisplayAd;

@property (nonatomic, assign) id<MFCustomEventBannerDelegate> delegate;
@property (nonatomic, retain) NSString* trackingPixel;

@end
