#import "MRAdViewDisplayController+Specs.h"
#import "FakeMRAdView.h"
#import "FakeMRJavaScriptEventEmitter.h"
#import "MRProperty.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MRAdViewDisplayController ()

@property (nonatomic, assign) MRAdViewState currentState;
@property (nonatomic, retain) MRAdView *twoPartExpansionView;

- (void)expandAnimationDidStop;

@end

SPEC_BEGIN(MRAdViewDisplayControllerSpec)

describe(@"MRAdViewDisplayController", ^{
    __block MRAdViewDisplayController *controller;
    __block FakeMRAdView *fakeMRAdView;
    __block FakeMRJavaScriptEventEmitter *fakeJSEmitter;

    beforeEach(^{
        fakeMRAdView = [[FakeMRAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            allowsExpansion:YES
                                           closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                              placementType:MRAdViewPlacementTypeInline];
        fakeProvider.fakeMRAdView = fakeMRAdView;

        fakeJSEmitter = [[FakeMRJavaScriptEventEmitter alloc] initWithWebView:nil];
        fakeProvider.fakeMRJavaScriptEventEmitter = fakeJSEmitter;

        controller = [[MRAdViewDisplayController alloc] initWithAdView:fakeMRAdView
                                                       allowsExpansion:YES
                                                      closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                        jsEventEmitter:fakeJSEmitter];
    });

    context(@"when initialized with view properties", ^{
        it(@"should let the creative know", ^{
            [controller initializeJavascriptStateWithViewProperties:@[[MRPlacementTypeProperty propertyWithType:MRAdViewPlacementTypeInline],
                                                                      [MRSupportsProperty defaultProperty]]];

            [fakeJSEmitter containsProperty:[MRPlacementTypeProperty propertyWithType:MRAdViewPlacementTypeInline]] should equal(YES);
            [fakeJSEmitter containsProperty:[MRSupportsProperty defaultProperty]] should equal(YES);
            fakeJSEmitter.didFireReadyEvent should equal(YES);
        });
    });

    context(@"when asked to rotate to a new orientation", ^{
        beforeEach(^{
            [controller rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
        });

        it(@"should let the creative know", ^{
            fakeJSEmitter.changedProperties.count should equal(1);
        });
    });

    context(@"when asked to close from the default state", ^{
        it(@"should let the creative know", ^{
            controller.currentState = MRAdViewStateDefault;
            [controller close];

            [fakeJSEmitter containsProperty:[MRStateProperty propertyWithState:MRAdViewStateHidden]] should equal(YES);
        });
    });

    context(@"when asked to close from the expanded state", ^{
        it(@"should let the creative know", ^{
            controller.currentState = MRAdViewStateExpanded;
            [controller close];

            controller.currentState should equal(MRAdViewStateDefault);
            [fakeJSEmitter containsProperty:[MRStateProperty propertyWithState:MRAdViewStateDefault]] should equal(YES);
        });
    });

    describe(@"expansion", ^{
        __block UIWindow *window;

        beforeEach(^{
            window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            [window makeKeyWindow];
        });

        context(@"when asked to expand with a URL", ^{
            beforeEach(^{
                fakeProvider.fakeMRAdView = nil;

                [controller expandToFrame:CGRectMake(0, 0, 320, 480)
                                  withURL:[NSURL URLWithString:@"http://www.mopub.com"]
                           useCustomClose:NO
                                  isModal:YES
                    shouldLockOrientation:YES];
            });

            it(@"should create the two-part expansion view", ^{
                controller.twoPartExpansionView should_not be_nil;
            });

            it(@"should move the two-part expansion view to the key window", ^{
                controller.view.superview should be_nil;
                [controller.twoPartExpansionView.superview class] should equal([UIWindow class]);
            });

            it(@"should let the creative know", ^{
                [controller expandAnimationDidStop];

                controller.currentState should equal(MRAdViewStateExpanded);

                [fakeJSEmitter containsProperty:[MRStateProperty propertyWithState:controller.currentState]] should equal(YES);
            });
        });

        context(@"when asked to expand without a URL", ^{
            beforeEach(^{
                fakeProvider.fakeMRAdView = nil;

                [controller expandToFrame:CGRectMake(0, 0, 320, 480)
                                  withURL:nil
                           useCustomClose:NO
                                  isModal:YES
                    shouldLockOrientation:YES];
            });

            it(@"should not create the two-part expansion view", ^{
                controller.twoPartExpansionView should be_nil;
            });

            it(@"should move the view to the key window", ^{
                [controller.view.superview class] should equal([UIWindow class]);
            });
        });
    });
});

SPEC_END
