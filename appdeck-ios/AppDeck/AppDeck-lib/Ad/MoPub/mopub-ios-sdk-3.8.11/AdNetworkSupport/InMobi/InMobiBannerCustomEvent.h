//
//  InMobiBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPBannerCustomEvent.h"
#endif

/*
 * Certified with version 4.4.1 of the InMobi SDK.
 */

@interface InMobiBannerCustomEvent : MPBannerCustomEvent

/**
 * Registers an InMobi app ID to be used when making ad requests.
 *
 * When making ad requests, the InMobi SDK requires you to provide your app ID. When
 * integrating an InMobi banner using a MoPub custom event, you must use this method to
 * provide the custom event with your ID.  This ID should be the same ID you use to
 * initialize InMobi.
 */
+ (void)setAppId:(NSString *)appId;

@end
