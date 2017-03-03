//
//  FakeCLLocationManager.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface FakeCLLocationManager : CLLocationManager

- (void)setLocation:(CLLocation *)location;

@property (nonatomic) CLLocation *fakeLocation;
@property (nonatomic) BOOL isUpdatingLocation;

@end
