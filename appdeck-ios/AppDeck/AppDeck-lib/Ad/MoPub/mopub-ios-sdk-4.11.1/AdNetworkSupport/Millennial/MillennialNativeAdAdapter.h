//
//  MillennialNativeAdAdapter.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MoPub.h"
#endif

#import <MMAdSDK/MMAdSDK.h>
#import <Foundation/Foundation.h>

@interface MillennialNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithMMNativeAd:(MMNativeAd *)ad;

@end
