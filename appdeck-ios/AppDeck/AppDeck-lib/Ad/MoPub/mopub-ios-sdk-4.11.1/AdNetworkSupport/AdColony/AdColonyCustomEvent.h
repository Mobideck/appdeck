//
//  AdColonyCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

/*
 * Certified with version 2.4.12 of the AdColony SDK.
 *
 */

#import "AdColonyInterstitialCustomEvent.h"
#import "AdColonyRewardedVideoCustomEvent.h"
#import "AdColonyInstanceMediationSettings.h"
#import "AdColonyGlobalMediationSettings.h"

/*
 * `AdColonyCustomEvent` is a network level class. Custom events should initialize Ad Colony through
 * this class.
 */
@interface AdColonyCustomEvent : NSObject

/*
 * Initialize Ad Colony for the given zone IDs and app ID.
 *
 * Multiple calls to this method will result in initialiazing Ad Colony only once.
 *
 * @param appId The application's Ad Colony App ID.
 * @param allZoneIds All the possible zone IDs the application may use across all ad formats.
 * @param customerId The user's id for the app.
 */
+ (void)initializeAdColonyCustomEventWithAppId:(NSString *)appId allZoneIds:(NSArray *)allZoneIds customerId:(NSString *)customerId;

@end
