//
//  MPMRAIDInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEventMF.h"
#import "MPMRAIDInterstitialViewControllerMF.h"
#import "MPPrivateInterstitialCustomEventDelegate.h"

@interface MPMRAIDInterstitialCustomEventMF : MPInterstitialCustomEventMF <MPInterstitialViewControllerDelegateMF>

@property (nonatomic, assign) id<MPPrivateInterstitialCustomEventDelegateMF> delegate;

@end
