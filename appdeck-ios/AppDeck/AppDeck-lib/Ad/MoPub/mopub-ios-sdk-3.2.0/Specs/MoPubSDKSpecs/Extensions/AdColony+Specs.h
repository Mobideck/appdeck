//
//  AdColony+Specs.h
//  MoPubSDK
//
//  Created by Yuan Ren on 10/22/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>

@interface AdColony (Specs)

+ (void)mp_swizzleStartMethod;
+ (void)mp_swizzleZoneStatusMethod;

+ (NSString *)mp_getAppId;
+ (NSArray *)mp_getZoneIds;
+ (void)mp_onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID;
+ (void)mp_setAdColonyDelegate:(id)delegate;
+ (void)mp_setZoneStatus:(NSInteger)status;

@end
