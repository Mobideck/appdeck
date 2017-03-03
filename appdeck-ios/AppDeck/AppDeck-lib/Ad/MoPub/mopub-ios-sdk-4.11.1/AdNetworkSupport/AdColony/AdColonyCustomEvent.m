//
//  AdColonyCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AdColonyCustomEvent.h"
#import "AdColonyGlobalMediationSettings.h"
#import "MPAdColonyRouter.h"
#import "MoPub.h"
#import "MPRewardedVideo.h"

@implementation AdColonyCustomEvent

+ (void)initializeAdColonyCustomEventWithAppId:(NSString *)appId allZoneIds:(NSArray *)allZoneIds customerId:(NSString *)customerId
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        AdColonyGlobalMediationSettings *settings = [[MoPub sharedInstance] globalMediationSettingsForClass:[AdColonyGlobalMediationSettings class]];

        // Set the AdColony customID to enable server-mode for AdColony V4VC if the application has provided a customID.

        if (customerId.length > 0) {
            [AdColony setCustomID:customerId];
        } else if (settings && [settings.customId length]) {
            [AdColony setCustomID:settings.customId];
        }

        [AdColony configureWithAppID:appId
                             zoneIDs:allZoneIds
                            delegate:[MPAdColonyRouter sharedRouter]
                             logging:NO];
    });
}

@end
