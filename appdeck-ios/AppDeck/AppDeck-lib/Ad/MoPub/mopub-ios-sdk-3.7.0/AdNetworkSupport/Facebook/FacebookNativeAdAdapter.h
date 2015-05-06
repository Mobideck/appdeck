//
//  FacebookNativeAdAdapter.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

@class FBNativeAd;

/**
 * Certified with the Facebook iOS SDK version 3.21.1
 */

@interface FacebookNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithFBNativeAd:(FBNativeAd *)fbNativeAd;

@end
