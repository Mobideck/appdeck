#import "MPProgressOverlayView.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPProgressOverlayViewSpec)

describe(@"MPProgressOverlayView", ^{
    __block MPProgressOverlayView *overlay;
    __block id<CedarDouble, MPProgressOverlayViewDelegate> delegate;
    __block UIWindow *window;

    beforeEach(^{
        window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        [window makeKeyAndVisible];

        [[UIApplication sharedApplication] setStatusBarHidden:NO];

        delegate = nice_fake_for(@protocol(MPProgressOverlayViewDelegate));

        overlay = [[MPProgressOverlayView alloc] initWithDelegate:delegate];
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

        xit(@"should schedule itself to show the close button if the overlay stays on screen too long", ^{

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

            it(@"should hide the close button", ^{
                overlay.closeButton.hidden = YES;
                overlay.closeButton.alpha = 0.0f;
            });

            xit(@"should cancel the selector that was scheduled in -show that would show the close button", ^{

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
            CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
            overlay.closeButton.transform.a should be_close_to(transform.a);
            overlay.closeButton.transform.b should be_close_to(transform.b);
            overlay.closeButton.transform.c should be_close_to(transform.c);
            overlay.closeButton.transform.d should be_close_to(transform.d);
            overlay.closeButton.transform.tx should be_close_to(transform.tx);
            overlay.closeButton.transform.ty should be_close_to(transform.ty);

        });
    });

    // We need to make these independent of the size of the button.
    xdescribe(@"device orientation changes", ^{
        beforeEach(^{
            [overlay show];
        });

        describe(@"portrait", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(290, 50));
            });
        });

        describe(@"portrait upside down", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(30, 518));
            });
        });

        describe(@"landscape left", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(50, 30));
            });
        });

        describe(@"landscape right", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                [overlay layoutSubviews];
            });

            it(@"should position the close button properly", ^{
                overlay.closeButton.center should equal(CGPointMake(270, 538));
            });
        });
    });
});

SPEC_END
