//
//  MPAdColonyRouter+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPAdColonyRouter+MPSpecs.h"

@implementation MPAdColonyRouter (MPSpecs)

@dynamic events;

- (void)reset
{
    self.events = [NSMutableDictionary dictionary];
}

@end
