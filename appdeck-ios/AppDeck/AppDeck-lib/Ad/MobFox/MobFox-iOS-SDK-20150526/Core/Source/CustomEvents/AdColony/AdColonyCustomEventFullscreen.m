//
//  AdColonyCustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 23.06.2014.
//
//

#import "AdColonyCustomEventFullscreen.h"

@implementation AdColonyCustomEventFullscreen
static NSString* loadedZoneId;
static BOOL initialized;

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    NSArray *tmp=[optionalParameters componentsSeparatedByString:@";"];
    Class SDKClass = NSClassFromString(@"AdColony");
    if(!SDKClass || [tmp count] < 2 || [tmp count] > 3) {
        [self notifyAdFailed];
        return;
    }

    if(!initialized) {
        NSString* appID;
        NSString* zoneIDs;
        if([tmp count] == 2) {
            appID=[tmp objectAtIndex:0];
            zoneIDs=[tmp objectAtIndex:1];
        } else {
            appID=[tmp objectAtIndex:1];
            zoneIDs=[tmp objectAtIndex:2];
        }
        
        NSArray *zoneIDsArray = [zoneIDs componentsSeparatedByString:@","];
        [SDKClass configureWithAppID:appID
                             zoneIDs:zoneIDsArray
                            delegate:self
                             logging:NO];
        initialized = YES;
    }
    
    else if(loadedZoneId) {
        [self notifyAdLoaded];
    } else {
        [self notifyAdFailed];
    }
}

- (void) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString*) zoneID {
    if(available) {
        loadedZoneId = zoneID;
        [self notifyAdLoaded];
    } else {
        loadedZoneId = nil;
        [self notifyAdFailed];
    }
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    Class SDKClass = NSClassFromString(@"AdColony");
    if(SDKClass && loadedZoneId) {
        [SDKClass playVideoAdForZone:loadedZoneId withDelegate:self];
    }
}

- (void) onAdColonyAdStartedInZone:( NSString * )zoneID {
    [self notifyAdWillAppear];
}


- (void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    if(!shown) {
        [self notifyAdFailed];
    } else {
        [self notifyAdWillClose];
    }
}


@end
