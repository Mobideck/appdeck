//
//  FlurryNativeAdAdapter.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "MPNativeAdAdapter.h"
#import "FlurryAdNative.h"

@interface FlurryNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithFlurryAdNative:(FlurryAdNative *)adNative;

@end
