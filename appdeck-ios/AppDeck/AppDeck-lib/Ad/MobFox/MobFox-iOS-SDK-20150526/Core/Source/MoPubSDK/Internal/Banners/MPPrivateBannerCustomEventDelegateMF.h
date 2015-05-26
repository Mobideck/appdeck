//
//  MPPrivateBannerCustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBannerCustomEventDelegateMF.h"

@class MPAdConfiguration;

@protocol MPPrivateBannerCustomEventDelegateMF <MPBannerCustomEventDelegateMF>

- (NSString *)adUnitId;
- (MPAdConfiguration *)configuration;
- (id)bannerDelegate;

@end
