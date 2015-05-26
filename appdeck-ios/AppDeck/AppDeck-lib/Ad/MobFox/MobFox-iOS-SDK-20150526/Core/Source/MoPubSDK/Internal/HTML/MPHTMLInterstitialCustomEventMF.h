//
//  MPHTMLInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEventMF.h"
#import "MPHTMLInterstitialViewControllerMF.h"
#import "MPPrivateInterstitialCustomEventDelegate.h"

@interface MPHTMLInterstitialCustomEventMF : MPInterstitialCustomEventMF <MPInterstitialViewControllerDelegateMF>

@property (nonatomic, assign) id<MPPrivateInterstitialCustomEventDelegateMF> delegate;

@end
