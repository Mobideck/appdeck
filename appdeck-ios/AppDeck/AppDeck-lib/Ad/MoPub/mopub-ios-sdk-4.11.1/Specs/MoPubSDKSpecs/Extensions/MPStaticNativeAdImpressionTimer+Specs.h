//
//  MPStaticNativeAdImpressionTimer+Specs.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPStaticNativeAdImpressionTimer.h"

@interface MPStaticNativeAdImpressionTimer (Specs)

@property (nonatomic, assign) CGFloat requiredViewVisibilityPercentage;
@property (nonatomic, readonly) NSTimeInterval requiredSecondsForImpression;
@property (nonatomic, assign) NSTimeInterval firstVisibilityTimestamp;
@property (nonatomic) MPTimer *viewVisibilityTimer;

@end
