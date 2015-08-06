//
//  AdBuddizInterstitial.h
//  Copyright (c) 2014 Purple Brain. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPInterstitialCustomEvent.h"
#endif

#import <AdBuddiz/AdBuddizDelegate.h>

@interface AdBuddizInterstitial : MPInterstitialCustomEvent<AdBuddizDelegate>

@end
