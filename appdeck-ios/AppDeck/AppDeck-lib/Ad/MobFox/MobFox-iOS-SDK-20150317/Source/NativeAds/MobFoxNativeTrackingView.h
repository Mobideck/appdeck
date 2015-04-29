//
//  MobFoxNativeTrackingView.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 26.05.2014.
//
//

#import <UIKit/UIKit.h>
#import "MobFoxNativeAdController.h"
#import "MobFoxNativeAd.h"

@interface MobFoxNativeTrackingView : UIView

- (id)initWithFrame:(CGRect)frame andUserAgent:(NSString*)userAgent;

@property (nonatomic, strong) MobFoxNativeAd* nativeAd;

@property (nonatomic, weak) id <MobFoxNativeAdDelegate> delegate;

@end
