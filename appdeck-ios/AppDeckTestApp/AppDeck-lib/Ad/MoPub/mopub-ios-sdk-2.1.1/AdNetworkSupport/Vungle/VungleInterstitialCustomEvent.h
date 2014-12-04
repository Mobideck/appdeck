//
//  VungleInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEvent.h"

#import <vunglepub/vunglepub.h>

/*
 * Certified with version 2.0.1 of the Vungle SDK.
 *
 * The Vungle SDK does not provide an ad clicked callback. As a result, this custom event will not invoke delegate methods 
 * interstitialCustomEventDidReceiveTapEvent: and interstitialCustomEventWillLeaveApplication:
 */

@interface VungleInterstitialCustomEvent : MPInterstitialCustomEvent <VGVunglePubDelegate>

@end
