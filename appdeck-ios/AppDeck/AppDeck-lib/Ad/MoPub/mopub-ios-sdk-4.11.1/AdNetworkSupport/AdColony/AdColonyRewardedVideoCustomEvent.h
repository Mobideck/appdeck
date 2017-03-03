//
//  AdColonyRewardedVideoCustomEvent.h
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
 * The AdColony SDK does not provide an ad clicked callback. As a result, this custom event will not invoke delegate methods
 * rewardedVideoDidReceiveTapEventForCustomEvent: and rewardedVideoWillLeaveApplicationForCustomEvent:
 */
@interface AdColonyRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

@end
