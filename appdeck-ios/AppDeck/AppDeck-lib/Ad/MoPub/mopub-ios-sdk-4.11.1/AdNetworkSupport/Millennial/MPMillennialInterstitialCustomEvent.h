//
//  MPMillennialInterstitialCustomEvent.h
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MoPub.h"
#endif

#import <MMAdSDK/MMAdSDK.h>

/*
 * For MMSDK version 6.3.1
 */

@interface MPMillennialInterstitialCustomEvent : MPInterstitialCustomEvent <MMInterstitialDelegate>

@property (nonatomic, readonly) MMInterstitialAd *interstitial;

@end
