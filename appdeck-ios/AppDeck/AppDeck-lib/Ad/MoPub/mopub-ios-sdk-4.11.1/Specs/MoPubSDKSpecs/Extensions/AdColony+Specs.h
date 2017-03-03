//
//  AdColony+Specs.h
//  MoPubSDK
//
//  Created by Yuan Ren on 10/22/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <AdColony/AdColony.h>

@interface AdColony (Specs)

+ (NSString *)mp_getAppId;
+ (NSArray *)mp_getZoneIds;
+ (void)mp_onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID;
+ (void)mp_setAdColonyDelegate:(id)delegate;
+ (void)mp_setZoneStatus:(NSInteger)status;
+ (void)mp_setZoneRewardAvailability:(BOOL)available;

+ (BOOL)mp_playVideoCalled;
+ (BOOL)mp_playVideoCalledWithPrePopup;
+ (BOOL)mp_playVideoCalledWithPostPopup;
+ (void)mp_resetPlayeVideoCalledProperties;

+ (NSString *)mp_customID;
+ (void)mp_clearCustomID;

@end
