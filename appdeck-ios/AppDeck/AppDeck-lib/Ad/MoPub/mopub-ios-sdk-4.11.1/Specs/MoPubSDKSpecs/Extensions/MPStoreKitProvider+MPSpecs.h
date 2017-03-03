//
//  MPStoreKitProvider+MPSpecs.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPStoreKitProvider.h"
#import "FakeStoreProductViewController.h"

@interface MPStoreKitProvider (MPSpecs)

+ (void)setDeviceHasStoreKit:(BOOL)hasStoreKit;
+ (FakeStoreProductViewController *)lastStore;

@end
