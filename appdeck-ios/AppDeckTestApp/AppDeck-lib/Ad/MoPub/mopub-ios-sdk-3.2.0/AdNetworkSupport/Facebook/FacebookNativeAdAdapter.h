//
//  FacebookNativeAdAdapter.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdAdapter.h"

@class FBNativeAd;

/**
 * Certified with the Facebook iOS SDK version 3.18.2
 */

@interface FacebookNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithFBNativeAd:(FBNativeAd *)fbNativeAd;

@end
