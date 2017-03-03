//
//  FakeCLLocationManager.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeCLLocationManager.h"

@implementation FakeCLLocationManager

- (CLLocation *)location
{
    return self.fakeLocation;
}

- (void)setLocation:(CLLocation *)location
{
    self.fakeLocation = location;
}

- (void)startUpdatingLocation
{
    self.isUpdatingLocation = YES;
}

- (void)stopUpdatingLocation
{
    self.isUpdatingLocation = NO;
}

@end
