
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPInterstitialCustomEvent.h"
    #import "MoPub.h"
#endif

#import <MMAdSDK/MMAdSDK.h>
#import <MMAdSDK/MMInterstitialAd.h>

/*
 * For MMSDK version 6.0
 */

@interface MPMillennialInterstitialCustomEvent : MPInterstitialCustomEvent <MMInterstitialDelegate>

@end
