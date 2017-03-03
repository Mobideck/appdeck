//
//  FakeMPGeolocationProvider.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPGeolocationProvider.h"

@interface FakeMPGeolocationProvider : MPGeolocationProvider

@property (nonatomic, strong) CLLocation *fakeLastKnownLocation;

@end
