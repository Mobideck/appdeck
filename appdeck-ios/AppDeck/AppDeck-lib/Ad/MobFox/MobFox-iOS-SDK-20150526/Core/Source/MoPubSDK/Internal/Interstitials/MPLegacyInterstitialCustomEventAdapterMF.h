//
//  MPLegacyInterstitialCustomEventAdapter.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBaseInterstitialAdapterMF.h"

@interface MPLegacyInterstitialCustomEventAdapterMF : MPBaseInterstitialAdapterMF

- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;

@end
