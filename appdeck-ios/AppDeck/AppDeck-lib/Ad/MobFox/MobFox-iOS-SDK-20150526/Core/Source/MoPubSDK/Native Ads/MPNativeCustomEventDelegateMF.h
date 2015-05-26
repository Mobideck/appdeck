//
//  MPNativeCustomEventDelegate.h
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPNativeAdMF;
@class MPNativeCustomEventMF;

/**
 * Instances of your custom subclass of `MPNativeCustomEvent` will have an `MPNativeCustomEventDelegate` delegate.
 * You use this delegate to communicate ad events back to the MoPub SDK.
 */
@protocol MPNativeCustomEventDelegateMF <NSObject>

/**
 * This method is called when the ad and all required ad assets are loaded.
 *
 * @param event You should pass `self` to allow the MoPub SDK to associate this event with the correct
 * instance of your custom event.
 * @param adObject An MPNativeAd object, representing the ad that was retrieved.
 */
- (void)nativeCustomEvent:(MPNativeCustomEventMF *)event didLoadAd:(MPNativeAdMF *)adObject;

/**
 * This method is called when the ad or any required ad assets fail to load.
 *
 * @param event You should pass `self` to allow the MoPub SDK to associate this event with the correct
 * instance of your custom event.
 * @param error (*optional*) You may pass an error describing the failure.
 */
- (void)nativeCustomEvent:(MPNativeCustomEventMF *)event didFailToLoadAdWithError:(NSError *)error;

@end
