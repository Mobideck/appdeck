//
//  MPMRAIDBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerCustomEventMF.h"
#import "MRAdViewMF.h"
#import "MPPrivateBannerCustomEventDelegateMF.h"

@interface MPMRAIDBannerCustomEventMF : MPBannerCustomEventMF <MRAdViewDelegateMF>

@property (nonatomic, assign) id<MPPrivateBannerCustomEventDelegateMF> delegate;

@end
