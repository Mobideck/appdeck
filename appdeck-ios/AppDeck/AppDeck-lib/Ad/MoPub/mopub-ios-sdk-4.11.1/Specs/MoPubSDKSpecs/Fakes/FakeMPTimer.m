//
//  FakeMPTimer.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPTimer.h"
#import "MPInternalUtils.h"

@implementation FakeMPTimer

+ (FakeMPTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                                target:(id)target
                              selector:(SEL)aSelector
                               repeats:(BOOL)repeats
{
    FakeMPTimer *timer = [[FakeMPTimer alloc] init];
    timer.timeInterval = seconds;
    timer.timeToNextTrigger = seconds;
    timer.target = target;
    timer.selector = aSelector;
    timer.repeats = repeats;
    timer.isValid = YES;
    timer.isScheduled = NO;
    timer.isPaused = NO;
    return timer;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<MPTimer %p: TimeInterval:%.1f, TimeToNextTrigger: %.1f, Target:%@, Selector:%@>", self, self.timeInterval, self.timeToNextTrigger, self.target, NSStringFromSelector(self.selector)];
}

- (BOOL)scheduleNow
{
    self.isScheduled = YES;
    return YES;
}

- (BOOL)pause
{
    self.isPaused = YES;
    return YES;
}

- (BOOL)resume
{
    self.isPaused = NO;
    return YES;
}

- (void)invalidate
{
    self.isValid = NO;
    self.isScheduled = NO;
    self.target = nil;
    self.selector = nil;
}

- (void)advanceTime:(NSTimeInterval)timeInterval
{
    if (self.isValid && self.isScheduled && !self.isPaused) {
        self.timeToNextTrigger -= timeInterval;
        if (self.timeToNextTrigger <= 0) {
            [self trigger];
            if (self.repeats) {
                self.timeToNextTrigger = self.initialTimeInterval + self.timeToNextTrigger;
            }
        }
    }
}

- (void)trigger
{
    if (self.isValid && self.isScheduled && !self.isPaused) {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [self.target performSelector:self.selector withObject:nil]
        );
        if (!self.repeats) {
            [self invalidate];
        }
    }
}

@end
