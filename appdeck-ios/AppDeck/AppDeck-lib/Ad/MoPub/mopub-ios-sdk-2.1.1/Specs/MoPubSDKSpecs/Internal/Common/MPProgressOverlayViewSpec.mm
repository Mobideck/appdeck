#import "MPProgressOverlayView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPProgressOverlayViewSpec)

describe(@"MPProgressOverlayView", ^{
    __block MPProgressOverlayView *overlay;
    __block id<CedarDouble, MPProgressOverlayViewDelegate> delegate;
    __block UIWindow *window;

    beforeEach(^{
        window = [[[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 568)] autorelease];
        [window makeKeyAndVisible];

        [[UIApplication sharedApplication] setStatusBarHidden:NO];

        delegate = nice_fake_for(@protocol(MPProgressOverlayViewDelegate));

        overlay = [[[MPProgressOverlayView alloc] initWithDelegate:delegate] autorelease];
    });

    describe(@"-show", ^{
        beforeEach(^{
            [overlay show];
        });

        it(@"should tell its delegate that it was presented", ^{
            delegate should have_received(@selector(overlayDidAppear));
        });

        it(@"should add itself to the key window", ^{
            window.subviews.lastObject should be_same_instance_as(overlay);
        });

        it(@"should have an alpha of 1", ^{
            overlay.alpha should equal(1.0);
        });

        describe(@"-hide", ^{
            beforeEach(^{
                [overlay hide];
            });

            it(@"should remove itself from the key window", ^{
                window.subviews.lastObject should be_nil;
            });

            it(@"should have an alpha of 0", ^{
                overlay.alpha should equal(0.0);
            });
        });
    });

    context(@"when shown while application is in a non-portrait interface orientation", ^{
        beforeEach(^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
            [overlay show];
        });

        it(@"should rotate its subviews according to the current interface orientation", ^{
            // Don't use animation, since there's already a fade animation occurring as part of the presentation.
            overlay.closeButton.transform should equal(CGAffineTransformMakeRotation(-M_PI_2));
        });
    });

    describe(@"device orientation changes", ^{
        beforeEach(^{
            [overlay show];
        });

        describe(@"portrait", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(296, 44));
            });
        });

        describe(@"portrait upside down", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(24, 524));
            });
        });

        describe(@"landscape left", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(44, 24));
            });
        });

        describe(@"landscape right", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(276, 544));
            });
        });
    });
});

SPEC_END
