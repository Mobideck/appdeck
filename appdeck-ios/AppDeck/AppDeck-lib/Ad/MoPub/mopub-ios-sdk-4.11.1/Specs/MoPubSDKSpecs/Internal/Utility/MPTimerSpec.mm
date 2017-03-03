#import "MPTimer.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol Anything <NSObject>

- (void)doAnything;

@end

void runFor(NSTimeInterval seconds)
{
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

SPEC_BEGIN(MPTimerSpec)

describe(@"MPTimer", ^{
    __block id<CedarDouble, Anything> fakeTarget;
    __block MPTimer *timer;
    __block NSTimeInterval interval;
    __block NSTimeInterval threshold;

    beforeEach(^{
        timer = nil;
        interval = 0.05;
        threshold = 0.01;
        fakeTarget = nice_fake_for(@protocol(Anything));

        // XXX: Seems like we need this, otherwise the backlog of things on the run loop causes
        // our tests to fail intermittently.
        runFor(threshold);
    });

    afterEach(^{
        [timer invalidate];
    });

    context(@"creating an unscheduled timer", ^{
        beforeEach(^{
            timer = [MPTimer timerWithTimeInterval:interval
                                            target:fakeTarget
                                          selector:@selector(doAnything)
                                           repeats:NO];
        });

        it(@"should be configured properly", ^{
            [timer isValid] should equal(YES);
            [timer isScheduled] should equal(NO);
            [timer initialTimeInterval] should equal(interval);

            runFor(interval + threshold);
            fakeTarget should_not have_received(@selector(doAnything));
        });

        context(@"when scheduled", ^{
            beforeEach(^{
                [timer scheduleNow];
            });

            it(@"should fire (only once) when the time interval has elapsed", ^{
                runFor(interval - threshold);
                fakeTarget should_not have_received(@selector(doAnything));

                runFor(2 * threshold);
                fakeTarget should have_received(@selector(doAnything));

                [fakeTarget reset_sent_messages];

                runFor(interval + threshold);
                fakeTarget should_not have_received(@selector(doAnything));

                [timer isValid] should equal(NO);
                [timer isScheduled] should equal(NO);
            });

            context(@"when invalidated", ^{
                beforeEach(^{
                    [timer invalidate];
                });

                it(@"should not fire when the time interval has elapsed", ^{
                    [timer isValid] should equal(NO);
                    [timer isScheduled] should equal(NO);

                    runFor(interval + threshold);
                    fakeTarget should_not have_received(@selector(doAnything));
                });
            });

            context(@"when paused", ^{
                __block NSTimeInterval timeBeforePause;

                beforeEach(^{
                    timeBeforePause = interval / 2.0;
                    runFor(timeBeforePause);
                    [timer pause];
                });

                it(@"should not fire when the time interval has elapsed", ^{
                    runFor((interval - timeBeforePause) + threshold);
                    fakeTarget should_not have_received(@selector(doAnything));

                    [timer isValid] should equal(YES);
                    [timer isScheduled] should equal(YES);
                });

                context(@"when resumed", ^{
                    beforeEach(^{
                        [timer resume];
                    });

                    it(@"should fire at the right time", ^{
                        runFor(interval / 2.0);
                        fakeTarget should_not have_received(@selector(doAnything));

                        runFor(2 * interval);
                        fakeTarget should have_received(@selector(doAnything));

                        [timer isValid] should equal(NO);
                        [timer isScheduled] should equal(NO);
                    });
                });
            });
        });
    });

    context(@"when scheduling a repeating timer", ^{
        it(@"should fire repeatedly", ^{
            timer = [MPTimer timerWithTimeInterval:interval
                                            target:fakeTarget
                                          selector:@selector(doAnything)
                                           repeats:YES];
            [timer scheduleNow];
            runFor(interval + threshold);
            fakeTarget should have_received(@selector(doAnything));
            [fakeTarget reset_sent_messages];

            runFor(interval + threshold);
            fakeTarget should have_received(@selector(doAnything));

            [timer isValid] should equal(YES);
            [timer isScheduled] should equal(YES);
        });
    });
});

SPEC_END
