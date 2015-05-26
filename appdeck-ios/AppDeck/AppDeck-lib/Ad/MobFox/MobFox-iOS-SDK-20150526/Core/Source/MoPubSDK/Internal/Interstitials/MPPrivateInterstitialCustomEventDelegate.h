//
//  MPPrivateInterstitialcustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPInterstitialCustomEventDelegateMF.h"

@class MPAdConfigurationMF;
@class CLLocation;

@protocol MPPrivateInterstitialCustomEventDelegateMF <MPInterstitialCustomEventDelegateMF>

- (NSString *)adUnitId;
- (MPAdConfigurationMF *)configuration;
- (id)interstitialDelegate;

@end
