//
//  FakeMPLogEventRecorder.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "FakeMPLogEventRecorder.h"

@implementation FakeMPLogEventRecorder

@dynamic events;

- (void)addEvent:(MPLogEvent *)event
{
    [self.events addObject:event];
}

@end
