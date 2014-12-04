//
//  FakeMPAdAlertGestureRecognizer.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdAlertGestureRecognizer.h"
#import "MPInternalUtils.h"

@implementation FakeMPAdAlertGestureRecognizer

- (void)addTarget:(id)target action:(SEL)action
{
    self.fakeTarget = target;
    self.fakeTargetAction = action;

    [super addTarget:target action:action];
}


- (void)simulateGestureRecognized
{
    SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
        [self.fakeTarget performSelector:self.fakeTargetAction withObject:nil]
    );
}

@end
