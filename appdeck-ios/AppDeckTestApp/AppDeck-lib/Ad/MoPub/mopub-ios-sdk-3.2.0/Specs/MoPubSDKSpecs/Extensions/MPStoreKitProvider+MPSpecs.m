//
//  MPStoreKitProvider+MPSpecs.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPStoreKitProvider+MPSpecs.h"

static BOOL deviceHasStoreKit;
static FakeStoreProductViewController *lastStore;

@implementation MPStoreKitProvider (MPSpecs)

+ (void)beforeEach
{
    [self setDeviceHasStoreKit:YES];
    lastStore = nil;
}

+ (void)setDeviceHasStoreKit:(BOOL)hasStoreKit
{
    deviceHasStoreKit = hasStoreKit;
}

+ (BOOL)deviceHasStoreKit
{
    return deviceHasStoreKit;
}

+ (FakeStoreProductViewController *)lastStore
{
    return lastStore;
}

+ (SKStoreProductViewController *)buildController
{
    lastStore = [[FakeStoreProductViewController alloc] init];
    return [lastStore masquerade];
}

@end
