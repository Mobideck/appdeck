//
//  UIImageView+MPNativeAd.h
//  Copyright (c) 2014 MoPub All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPNativeAdMF;

@interface UIImageView (MPNativeAdMF)

- (void)mp_setNativeAd:(MPNativeAdMF *)adObject;
- (void)mp_removeNativeAd;
- (MPNativeAdMF *)mp_nativeAd;

@end
