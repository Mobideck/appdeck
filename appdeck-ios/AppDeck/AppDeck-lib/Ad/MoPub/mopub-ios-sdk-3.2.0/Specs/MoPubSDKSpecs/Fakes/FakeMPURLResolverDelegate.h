//
//  FakeMPURLResolverDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLResolver.h"

@interface FakeMPURLResolverDelegate : NSObject <MPURLResolverDelegate>

@property (nonatomic, strong) NSURL *applicationURL;
@property (nonatomic, strong) NSURL *webViewURL;
@property (nonatomic, copy) NSString *HTMLString;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSString *storeKitParameter;
@property (nonatomic, strong) NSURL *storeFallbackURL;

@end
