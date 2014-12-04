//
//  FakeMPURLResolverDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLResolver.h"

@interface FakeMPURLResolverDelegate : NSObject <MPURLResolverDelegate>

@property (nonatomic, assign) NSURL *applicationURL;
@property (nonatomic, assign) NSURL *webViewURL;
@property (nonatomic, assign) NSString *HTMLString;
@property (nonatomic, assign) NSError *error;
@property (nonatomic, assign) NSString *storeKitParameter;
@property (nonatomic, assign) NSURL *storeFallbackURL;

@end
