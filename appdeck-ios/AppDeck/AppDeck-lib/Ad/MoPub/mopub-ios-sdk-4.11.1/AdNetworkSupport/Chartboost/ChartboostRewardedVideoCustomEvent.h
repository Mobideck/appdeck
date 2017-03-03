//
//  ChartboostRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPRewardedVideoCustomEvent.h"
#endif

/*
 * Certified with version 6.5.2 of the Chartboost SDK.
 */

@interface ChartboostRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

/**
 * A string that corresponds to a Chartboost CBLocation used for differentiating ad requests.
 */
@property (nonatomic, copy) NSString *location;

@end
