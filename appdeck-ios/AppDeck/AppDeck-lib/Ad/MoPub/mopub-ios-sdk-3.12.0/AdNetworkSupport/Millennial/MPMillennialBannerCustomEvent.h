
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPBannerCustomEvent.h"
    #import "MoPub.h"
#endif

#import <MMAdSDK/MMAdSDK.h>
#import <MMAdSDK/MMInlineAd.h>

/*
 * For MMSDK version 6.0
 */

@interface MPMillennialBannerCustomEvent : MPBannerCustomEvent <MMInlineDelegate>

@end
