#import "MPTimer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPTimerMRCSpec)

describe(@"MPTimer MRC", ^{
    __block MPTimer *timer;
    __block NSTimeInterval interval;

    describe(@"memory concerns", ^{
        it(@"should not retain its target when scheduled", ^{
            NSObject *target = [[[NSObject alloc] init] autorelease];
            NSUInteger initialRetainCount = target.retainCount;

            timer = [MPTimer timerWithTimeInterval:interval target:target selector:@selector(description) repeats:NO];
            [timer scheduleNow];

            target.retainCount should equal(initialRetainCount);
        });
    });
});

SPEC_END
