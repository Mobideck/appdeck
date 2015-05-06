//
//  GreystripeBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPBannerCustomEvent.h"
#endif

/*
 * Certified with version 4.4 of the Greystripe SDK.
 */

@interface GreystripeBannerCustomEvent : MPBannerCustomEvent

/**
 * Registers a Greystripe GUID to be used when making ad requests.
 *
 * When making ad requests, the Greystripe SDK requires you to provide your GUID. When
 * integrating Greystripe using a MoPub custom event, this ID is typically configured via your
 * Greystripe network settings on the MoPub website. However, if you wish, you may use this method to
 * manually provide the custom event with your GUID.
 *
 * **Deprecated**: This method of setting the Greystripe GUID is deprecated. Use the MoPub website to set
 * your GUID in your network settings for Greystripe. See the Custom Native Network Setup guide for more
 * information. https://dev.twitter.com/mopub/ad-networks/network-setup-custom-native
 */
+ (void)setGUID:(NSString *)GUID;

@end
