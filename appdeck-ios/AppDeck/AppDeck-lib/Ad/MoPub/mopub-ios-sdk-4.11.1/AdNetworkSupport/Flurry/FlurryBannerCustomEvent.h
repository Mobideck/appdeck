//
//  FlurryBannerCustomEvent.h
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryAdBannerDelegate.h"
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MPBannerCustomEvent.h"
#endif

@interface FlurryBannerCustomEvent : MPBannerCustomEvent <FlurryAdBannerDelegate>

@end
