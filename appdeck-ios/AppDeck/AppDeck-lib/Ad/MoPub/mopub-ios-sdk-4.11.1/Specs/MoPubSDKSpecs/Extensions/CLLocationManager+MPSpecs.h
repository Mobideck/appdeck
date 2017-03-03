//
//  CLLocationManager+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLLocationManager (MPSpecs)

+ (void)setLocationServicesEnabled:(BOOL)enabled;
+ (void)setAuthorizationStatus:(CLAuthorizationStatus)status;

@end
