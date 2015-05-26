//
//  MPBannerCustomEventAdapter.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBaseBannerAdapterMF.h"

#import "MPPrivateBannerCustomEventDelegateMF.h"

@class MPBannerCustomEventMF;

@interface MPBannerCustomEventAdapterMF : MPBaseBannerAdapterMF <MPPrivateBannerCustomEventDelegateMF>

@end
