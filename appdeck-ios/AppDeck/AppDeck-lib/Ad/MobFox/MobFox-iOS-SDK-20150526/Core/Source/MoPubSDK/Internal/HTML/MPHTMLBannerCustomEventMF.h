//
//  MPHTMLBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerCustomEventMF.h"
#import "MPAdWebViewAgentMF.h"
#import "MPPrivateBannerCustomEventDelegateMF.h"

@interface MPHTMLBannerCustomEventMF : MPBannerCustomEventMF <MPAdWebViewAgentDelegateMF>

@property (nonatomic, assign) id<MPPrivateBannerCustomEventDelegateMF> delegate;

@end
