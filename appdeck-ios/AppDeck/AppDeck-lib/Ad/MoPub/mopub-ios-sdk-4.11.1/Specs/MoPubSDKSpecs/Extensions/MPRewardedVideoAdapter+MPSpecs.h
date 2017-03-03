//
//  MPRewardedVideoAdapter+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPRewardedVideoAdapter.h"
#import "MPRewardedVideoCustomEvent.h"

@class MPTimer;

@interface MPRewardedVideoAdapter (MPSpecs) <MPRewardedVideoCustomEventDelegate>

@property (nonatomic, strong) MPTimer *timeoutTimer;
@property (nonatomic, readonly) MPRewardedVideoCustomEvent *rewardedVideoCustomEvent;

@end
