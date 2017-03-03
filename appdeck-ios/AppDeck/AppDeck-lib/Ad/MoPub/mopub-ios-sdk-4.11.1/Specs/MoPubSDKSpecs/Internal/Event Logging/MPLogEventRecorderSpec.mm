#import "MPLogEventRecorder.h"
#import "MPLogEvent.h"
#import "MPLogEventCommunicator.h"
#import "MPLogEventRecorderSpecHelper.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPLogEventRecorder (Specs)

@property (nonatomic) NSMutableArray *events;
@property (nonatomic) MPLogEventCommunicator *communicator;

- (void)sendEvents;
- (BOOL)overQueueLimit;
- (BOOL)sample;
- (BOOL)sampleWithLogEvent:(MPLogEvent *)event;
- (BOOL)shouldSampleForRate:(CGFloat)sampleRate diceRoll:(NSUInteger)diceRoll;

@end

static inline void waitForBackgroundThreadToFinish() {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}

SPEC_BEGIN(MPLogEventRecorderSpec)

// TODO: Event recorder tests are flaky so we're not running them for now.
xdescribe(@"MPLogEventRecorder", ^{
    __block MPLogEvent *event;
    __block MPLogEventRecorder *eventRecorder;

    beforeEach(^{
        eventRecorder = [[MPLogEventRecorder alloc] init];
        event = [[MPLogEvent alloc] init];

        spy_on(eventRecorder);
    });

    describe(@"request id based caching", ^{
        it(@"sampling decision should remain constant when the request id does not change", ^{
            event.requestId = @"5555";
            BOOL initialSamplingResult = [eventRecorder sampleWithLogEvent:event];
            for (int i = 0; i < 100; i++) {
                [eventRecorder sampleWithLogEvent:event] should equal(initialSamplingResult);
            }
        });

        it(@"sampling decision should vary when the request id changes", ^{
            NSInteger numFalseValues = 0;
            NSInteger numTrueValues = 0;
            for (int i = 0; i < 500; i++) {
                event.requestId = [NSString stringWithFormat:@"%d", i];
                [eventRecorder sampleWithLogEvent:event] ? numFalseValues++ : numTrueValues++;
            }
            numFalseValues should_not equal(0);
            numTrueValues should_not equal(0);
        });

        it(@"sampling decision should vary when there is no request id", ^{
            NSInteger numFalseValues = 0;
            NSInteger numTrueValues = 0;
            event.requestId = nil;
            for (int i = 0; i < 500; i++) {
                [eventRecorder sampleWithLogEvent:event] ? numFalseValues++ : numTrueValues++;
            }
            numFalseValues should_not equal(0);
            numTrueValues should_not equal(0);
        });
    });

    describe(@"when applying sample logic to an event with a sample rate of 0.1", ^{
        it(@"should fail if the dice roll is above 10", ^{
            [eventRecorder shouldSampleForRate:0.1 diceRoll:99] should be_falsy;
        });

        it(@"should fail if the dice roll is 10", ^{
            [eventRecorder shouldSampleForRate:0.1 diceRoll:10] should be_falsy;
        });

        it(@"should succeed if the dice roll is 9", ^{
            [eventRecorder shouldSampleForRate:0.1 diceRoll:9] should be_truthy;
        });

        it(@"should succeed if the dice roll is below 9", ^{
            [eventRecorder shouldSampleForRate:0.1 diceRoll:0] should be_truthy;
        });

        it(@"should fail if the dice roll is negative", ^{
            [eventRecorder shouldSampleForRate:0.1 diceRoll:-1] should be_falsy;
        });
    });

    describe(@"adding events to the event queue via -addEvent", ^{
        afterEach(^{
            [eventRecorder.events removeAllObjects];
        });

        it(@"should not try to add a nil object to the event queue", ^{
            [eventRecorder addEvent:nil];
            [eventRecorder.events count] should equal(0);
        });

        it(@"shouldn't add the event to the event queue if sampling fails", ^{
            eventRecorder stub_method(@selector(sample)).and_return(NO);
            [eventRecorder addEvent:event];
            waitForBackgroundThreadToFinish();
            [eventRecorder.events count] should equal(0);
        });

        it(@"shouldn't add the event to the event queue if the queue is already too big", ^{
            eventRecorder stub_method(@selector(overQueueLimit)).and_return(YES);
            [eventRecorder addEvent:event];
            waitForBackgroundThreadToFinish();
            [eventRecorder.events count] should equal(0);
        });

        context(@"when the event can be added to the event queue", ^{
            beforeEach(^{
                eventRecorder stub_method(@selector(sample)).and_return(YES);
                eventRecorder stub_method(@selector(overQueueLimit)).and_return(NO);
                eventRecorder stub_method(@selector(sendEvents));
            });

            it(@"should add the event to the event queue if it can", ^{
                [eventRecorder addEvent:event];
                waitForBackgroundThreadToFinish();
                [eventRecorder.events count] should equal(1);
            });
        });
    });

    describe(@"sending events with -sendEvents", ^{
        beforeEach(^{
            eventRecorder.communicator = fake_for(MPLogEventCommunicator.class);
            eventRecorder.communicator stub_method(@selector(sendEvents:));
        });

        context(@"when the communicator shouldn't be sent events", ^{
            it(@"should not send events when the communicator is over it's connection limit", ^{
                eventRecorder.communicator stub_method(@selector(isOverLimit)).and_return(YES);

                [eventRecorder.events addObject:[[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest]];
                [eventRecorder sendEvents];
                waitForBackgroundThreadToFinish();

                eventRecorder.communicator should_not have_received(@selector(sendEvents:));
            });
            it(@"should not schedule a new connection if there aren't any events in the queue", ^{
                eventRecorder.communicator stub_method(@selector(isOverLimit)).and_return(NO);

                [eventRecorder.events removeAllObjects];
                [eventRecorder sendEvents];
                waitForBackgroundThreadToFinish();

                eventRecorder.communicator should_not have_received(@selector(sendEvents:));
            });
        });


        context(@"when there are more events in the queue than the max that can be sent in one connection", ^{
            beforeEach(^{
                eventRecorder.communicator stub_method(@selector(isOverLimit)).and_return(NO);

                for (int i = 0; i < 151; i++) {
                    [eventRecorder.events addObject:[[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest]];
                }
                [eventRecorder sendEvents];
                waitForBackgroundThreadToFinish();
            });

            it(@"should not send more than EVENT_SEND_THRESHOLD events", ^{
                NSArray *messages = [(id<CedarDouble>) eventRecorder.communicator sent_messages];

                // the communicator should have received isOverLimit first and sendEvents second
                [messages count] should equal(2);

                NSInvocation *sendEventsInvocation = messages[1];
                __unsafe_unretained NSArray *events;
                [sendEventsInvocation getArgument:&events atIndex:2];

                [events count] should equal(25);
            });

            it(@"should remove the sent events from the queue and reset the queue with the unsent events", ^{
                [eventRecorder.events count] should equal(126);
            });

        });


        context(@"when there are are fewer events in the queue than the max that can be sent in one connection", ^{
            beforeEach(^{
                eventRecorder.communicator stub_method(@selector(isOverLimit)).and_return(NO);

                for (int i = 0; i < 10; i++) {
                    [eventRecorder.events addObject:[[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest]];
                }
                [eventRecorder sendEvents];
                waitForBackgroundThreadToFinish();
            });

            it(@"should send all of the events in the queue", ^{
                NSArray *messages = [(id<CedarDouble>) eventRecorder.communicator sent_messages];

                // the communicator should have received isOverLimit first and sendEvents second
                [messages count] should equal(2);

                NSInvocation *sendEventsInvocation = messages[1];
                __unsafe_unretained NSArray *events;
                [sendEventsInvocation getArgument:&events atIndex:2];

                [events count] should equal(10);
            });

            it(@"should empty the event queue", ^{
                [eventRecorder.events count] should equal(0);
            });
        });
    });
});

SPEC_END
