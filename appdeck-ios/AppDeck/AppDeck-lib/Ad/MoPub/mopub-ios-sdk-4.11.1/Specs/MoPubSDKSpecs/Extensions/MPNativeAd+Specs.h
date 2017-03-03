//
//  MPNativeAd+Specs.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPNativeAd.h"

@protocol MPNativeAdAdapter;

@interface MPNativeAd (Specs)

@property (nonatomic, retain) UIView *associatedView;

+ (NSUInteger)mp_trackMetricURLCallsCount;
+ (void)mp_clearTrackMetricURLCallsCount;

@end
