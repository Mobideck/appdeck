//
//  FakeMPGeolocationProvider.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeMPGeolocationProvider.h"

@implementation FakeMPGeolocationProvider

- (CLLocation *)lastKnownLocation
{
    return self.fakeLastKnownLocation;
}

@end
