//
//  CLLocationManager+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "CLLocationManager+MPSpecs.h"

@implementation CLLocationManager (MPSpecs)

static BOOL gLocationServicesEnabled = YES;
static CLAuthorizationStatus gAuthorizationStatus = kCLAuthorizationStatusAuthorized;

+ (BOOL)locationServicesEnabled
{
    return gLocationServicesEnabled;
}

+ (void)setLocationServicesEnabled:(BOOL)enabled
{
    gLocationServicesEnabled = enabled;
}

+ (CLAuthorizationStatus)authorizationStatus
{
    return gAuthorizationStatus;
}

+ (void)setAuthorizationStatus:(CLAuthorizationStatus)status
{
    gAuthorizationStatus = status;
}

@end
