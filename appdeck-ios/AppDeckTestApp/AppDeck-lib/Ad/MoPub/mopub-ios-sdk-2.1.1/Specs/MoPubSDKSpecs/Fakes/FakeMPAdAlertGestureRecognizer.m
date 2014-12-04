//
//  FakeMPAdAlertGestureRecognizer.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdAlertGestureRecognizer.h"

@implementation FakeMPAdAlertGestureRecognizer

- (void)addTarget:(id)target action:(SEL)action
{
    self.fakeTarget = target;
    self.fakeTargetAction = action;
    
    [super addTarget:target action:action];
}

- (void)dealloc
{
    self.fakeTarget = nil;
    
    [super dealloc];
}

- (void)simulateGestureRecognized
{
    [self.fakeTarget performSelector:self.fakeTargetAction];
}

@end
