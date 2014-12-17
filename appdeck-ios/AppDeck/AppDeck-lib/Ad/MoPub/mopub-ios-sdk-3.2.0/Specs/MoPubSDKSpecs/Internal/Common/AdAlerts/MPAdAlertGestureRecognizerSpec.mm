#import "MPAdAlertGestureRecognizer.h"
#import "UIEvent+MPSpecs.h"

#import "CedarAsync.h"

// import this so we can call touch tracking methods for our tests
#import <UIKit/UIGestureRecognizerSubclass.h>

#define kZigZagTouchStepCount 10
#define kDefaultYValue 125

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol MPAdAlertGestureRecognizerResponder <NSObject>

- (void)handleGestureRecognized;

@end

static void
DoZigRight(MPAdAlertGestureRecognizer *model, UITouch *touch, UIEvent *event, CGFloat thresholdFraction, CGFloat yValue)
{
    int steps = kZigZagTouchStepCount * thresholdFraction;

    for(int i = 0; i < steps; i++)
    {
        [touch setLocationInWindow:CGPointMake(model.minTrackedDistanceForZigZag / kZigZagTouchStepCount * (i + 1), yValue)];
        [touch changeToPhase:UITouchPhaseMoved];

        [model touchesMoved:[NSSet setWithObject:touch] withEvent:event];
    }
}

static void
DoZagLeft(MPAdAlertGestureRecognizer *model, UITouch *touch, UIEvent *event, CGFloat thresholdFraction, CGFloat yValue)
{
    int steps = MAX(0, kZigZagTouchStepCount * (1 - thresholdFraction));

    for(int i = kZigZagTouchStepCount; i >= steps; i--)
    {
        [touch setLocationInWindow:CGPointMake(model.minTrackedDistanceForZigZag / kZigZagTouchStepCount * i, yValue)];
        [touch changeToPhase:UITouchPhaseMoved];

        [model touchesMoved:[NSSet setWithObject:touch] withEvent:event];
    }
}

SPEC_BEGIN(MPAdAlertGestureRecognizerSpec)

describe(@"MPAdAlertGestureRecognizer", ^{
    __block MPAdAlertGestureRecognizer *model;
    __block id<CedarDouble, MPAdAlertGestureRecognizerResponder> gestureResponder;
    __block UIView *view;
    __block UITouch *touch;
    __block UIEvent *event;

    beforeEach(^{
        gestureResponder = nice_fake_for(@protocol(MPAdAlertGestureRecognizerResponder));
        model = [[MPAdAlertGestureRecognizer alloc] initWithTarget:gestureResponder action:@selector(handleGestureRecognized)];

        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
        [view addGestureRecognizer:model];

        model.minTrackedDistanceForZigZag = view.bounds.size.width / 3;

        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [window makeKeyAndVisible];

        [window addSubview:view];
    });

    afterEach(^{
         model = nil;
         view = nil;
    });

    context(@"when the user touches the view with one finger", ^{
        beforeEach(^{
            touch = [[UITouch alloc] initInView:view atPoint:CGPointMake(160, kDefaultYValue)];
            [touch changeToPhase:UITouchPhaseBegan];
            event = [[UIEvent alloc] initWithTouch:touch];

            [model touchesBegan:[NSSet setWithObject:touch] withEvent:event];
        });

        it(@"should be in the zig right state", ^{
            model.currentAlertGestureState should equal(MPAdAlertGestureRecognizerState_ZigRight1);
            model.state should equal(UIGestureRecognizerStatePossible);
        });
    });

    context(@"when the user touches the view with more than one finger", ^{
        beforeEach(^{
            UITouch *touch1 = [[UITouch alloc] initInView:view atPoint:CGPointMake(160, kDefaultYValue)];
            [touch1 changeToPhase:UITouchPhaseBegan];
            event = [[UIEvent alloc] initWithTouch:touch1];

            UITouch *touch2 = [[UITouch alloc] initInView:view atPoint:CGPointMake(160, kDefaultYValue)];
            [touch2 changeToPhase:UITouchPhaseBegan];

            [model touchesBegan:[NSSet setWithObjects:touch1, touch2, nil] withEvent:event];
        });

        it(@"should be in the failed state", ^{
            model.state should equal(UIGestureRecognizerStateFailed);
        });
    });

    context(@"when the user zigs to the right before the threshold", ^{
        beforeEach(^{
            touch = [[UITouch alloc] initInView:view atPoint:CGPointMake(0, kDefaultYValue)];
            [touch changeToPhase:UITouchPhaseBegan];
            event = [[UIEvent alloc] initWithTouch:touch];

            [model touchesBegan:[NSSet setWithObject:touch] withEvent:event];

            // go about halfway to the threshold
            DoZigRight(model, touch, event, 0.5, kDefaultYValue);
        });

        it(@"should mark the threshold as NOT reached", ^{
            model.thresholdReached should equal(NO);
        });

        context(@"when the user zags left", ^{
            beforeEach(^{
                [touch setLocationInWindow:CGPointMake(0, kDefaultYValue)];
                [touch changeToPhase:UITouchPhaseMoved];

                [model touchesMoved:[NSSet setWithObject:touch] withEvent:event];
            });

            it(@"should be in the failed state", ^{
                model.state should equal(UIGestureRecognizerStateFailed);
            });
        });
    });

    context(@"when the user zigs to the right past the threshold", ^{
        beforeEach(^{
            touch = [[UITouch alloc] initInView:view atPoint:CGPointMake(0, kDefaultYValue)];
            [touch changeToPhase:UITouchPhaseBegan];
            event = [[UIEvent alloc] initWithTouch:touch];

            [model touchesBegan:[NSSet setWithObject:touch] withEvent:event];

            // this should take us past the threshold
            DoZigRight(model, touch, event, 1.1, kDefaultYValue);
        });

        it(@"should not have counted any zig zags completed", ^{
            model.curNumZigZags should equal(0);
        });

        it(@"should be in the zig right state", ^{
            model.currentAlertGestureState should equal(MPAdAlertGestureRecognizerState_ZigRight1);
        });

        it(@"should mark the threshold as reached", ^{
            model.thresholdReached should equal(YES);
        });

        context(@"when the user zags to the left before the threshold", ^{
            beforeEach(^{
                [touch setLocationInWindow:CGPointMake(model.minTrackedDistanceForZigZag / kZigZagTouchStepCount * 9, kDefaultYValue)];
                [touch changeToPhase:UITouchPhaseMoved];

                [model touchesMoved:[NSSet setWithObject:touch] withEvent:event];
            });

            it(@"should be in the zag left state", ^{
                model.currentAlertGestureState should equal(MPAdAlertGestureRecognizerState_ZagLeft2);
            });

            it(@"should mark the threshold as NOT reached", ^{
                model.thresholdReached should equal(NO);
            });
        });

        context(@"when the user zags to the left past the threshold", ^{
            beforeEach(^{
                DoZagLeft(model, touch, event, 1.0, kDefaultYValue);
            });

            it(@"should mark the threshold as reached", ^{
                model.thresholdReached should equal(YES);
            });

            it(@"should increment the zig zag completed count", ^{
                model.curNumZigZags should equal(1);
            });
        });
    });

    context(@"when the user zig zags enough times to trigger the gesture", ^{
       it(@"should notify the target that the gesture has been recognized", ^{
           [gestureResponder reset_sent_messages];

           touch = [[UITouch alloc] initInView:view atPoint:CGPointMake(0, kDefaultYValue)];
           [touch changeToPhase:UITouchPhaseBegan];
           event = [[UIEvent alloc] initWithTouch:touch];

           [model touchesBegan:[NSSet setWithObject:touch] withEvent:event];

           // perform enough zigzags
           for(int zigzags = 0; zigzags < model.numZigZagsForRecognition; zigzags++)
           {
               // zig right
               DoZigRight(model, touch, event, 1.1, kDefaultYValue);

               // zag left
               DoZagLeft(model, touch, event, 1.0, kDefaultYValue);

               model.curNumZigZags should equal(zigzags + 1);
           }

           // lift off finger
           touch = [[UITouch alloc] initInView:view atPoint:CGPointMake(0, kDefaultYValue)];
           [touch changeToPhase:UITouchPhaseEnded];
           event = [[UIEvent alloc] initWithTouch:touch];

           [model touchesEnded:[NSSet setWithObject:touch] withEvent:event];

           // once a gesture recognizer recognizes a gesture, the notification to the target is delayed
           in_time(gestureResponder) should have_received(@selector(handleGestureRecognized));
       });
    });

    context(@"when the user tracks too far in the Y-axis from the starting point", ^{
        context(@"when the user tracks too far on the initial zig right", ^{
            beforeEach(^{
                touch = [[UITouch alloc] initInView:view atPoint:CGPointMake(0, kDefaultYValue)];
                [touch changeToPhase:UITouchPhaseBegan];
                event = [[UIEvent alloc] initWithTouch:touch];

                [model touchesBegan:[NSSet setWithObject:touch] withEvent:event];

                // now simulate the touch going too high in the Y-axis
                [touch setLocationInWindow:CGPointMake(10, kDefaultYValue - kMPAdAlertGestureMaxAllowedYAxisMovement - 1)];
                [touch changeToPhase:UITouchPhaseMoved];

                [model touchesMoved:[NSSet setWithObject:touch] withEvent:event];
            });

            it(@"should be in the failed state", ^{
                model.state should equal(UIGestureRecognizerStateFailed);
            });
        });

        context(@"when the user completes the initial zig right", ^{
            beforeEach(^{
                touch = [[UITouch alloc] initInView:view atPoint:CGPointMake(0, kDefaultYValue)];
                [touch changeToPhase:UITouchPhaseBegan];
                event = [[UIEvent alloc] initWithTouch:touch];

                [model touchesBegan:[NSSet setWithObject:touch] withEvent:event];

                // this should take us past the threshold
                DoZigRight(model, touch, event, 1.1, kDefaultYValue);
            });

            it(@"should mark the threshold as reached", ^{
                model.thresholdReached should equal(YES);

                model.state should_not equal(UIGestureRecognizerStateFailed);
            });

            context(@"when the user tracks too far in the Y-axis on the zag left", ^{
                beforeEach(^{
                    // zag left about half way
                    DoZagLeft(model, touch, event, 0.5, kDefaultYValue);

                    // now simulate the touch going too low in the Y-axis
                    [touch setLocationInWindow:CGPointMake(10, kDefaultYValue + kMPAdAlertGestureMaxAllowedYAxisMovement + 1)];
                    [touch changeToPhase:UITouchPhaseMoved];

                    [model touchesMoved:[NSSet setWithObject:touch] withEvent:event];
                });

                it(@"should be in the failed state", ^{
                    model.state should equal(UIGestureRecognizerStateFailed);
                });
            });
        });
    });
});


SPEC_END
