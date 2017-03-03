//
//  AdColonyCustomEvent+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "AdColonyCustomEvent.h"

@interface AdColonyCustomEvent (MPSpecs)

// If we enable network init, that means we'll make the original call to -initializeAdColonyCustomEventWithAppId:allZoneIds.
// We swizzle the method so we can capture init variables to check their values. But we want to control when the actual call goes through
// as we can only initialize ad colony once. This allows us to test the AdColonyCustomEvent initialize all in one place.
+ (void)mp_enableAdColonyNetworkInit:(BOOL)allow;
+ (NSString *)mp_appId;
+ (NSArray *)mp_allZoneIds;
+ (NSInteger)mp_adColonyInitCount;
+ (void)mp_resetAdColonyInitCount;

@end
