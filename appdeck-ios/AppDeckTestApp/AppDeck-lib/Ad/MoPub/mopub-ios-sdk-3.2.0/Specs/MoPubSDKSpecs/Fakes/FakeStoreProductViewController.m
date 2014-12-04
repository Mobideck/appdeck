//
//  FakeStoreProductViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeStoreProductViewController.h"

@implementation FakeStoreProductViewController

- (void)loadProductWithParameters:(NSDictionary *)parameters completionBlock:(void (^)(BOOL, NSError *))block
{
    self.storeItemIdentifier = [parameters objectForKey:SKStoreProductParameterITunesItemIdentifier];
    self.completionBlock = block;
}

- (SKStoreProductViewController *)masquerade
{
    return (SKStoreProductViewController *)self;
}

@end
