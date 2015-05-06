//
//  InMobiNativeCustomEvent.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPNativeCustomEvent.h"
#endif

/*
 * Certified with version 4.4.1 of the InMobi SDK.
 */

@interface InMobiNativeCustomEvent : MPNativeCustomEvent

/**
 * Registers an InMobi app ID to be used when making ad requests.
 *
 * When making ad requests, the InMobi SDK requires you to provide your app ID. When
 * integrating InMobi using a MoPub custom event, this ID is typically configured via your
 * InMobi network settings on the MoPub website. However, if you wish, you may use this method to
 * manually provide the custom event with your ID.
 */
+ (void)setAppId:(NSString *)appId;

@end
