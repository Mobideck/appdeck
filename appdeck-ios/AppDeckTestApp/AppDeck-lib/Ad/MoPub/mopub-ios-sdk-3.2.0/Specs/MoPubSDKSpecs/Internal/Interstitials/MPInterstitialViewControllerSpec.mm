#import "MPInterstitialViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialViewControllerSpec)

describe(@"MPInterstitialViewController", ^{
    __block MPInterstitialViewController *controller;
    __block UIViewController *presentingController;

    beforeEach(^{
        presentingController = [[UIViewController alloc] init];
        controller = [[MPInterstitialViewController alloc] init];
        [controller.view addSubview:[[UIView alloc] init]];
    });

    describe(@"presenting the view controller", ^{
        beforeEach(^{
            [controller presentInterstitialFromViewController:presentingController];
            [controller viewWillAppear:NO];
            [controller viewDidAppear:NO];
        });

        it(@"should present itself using the passed in view controller", ^{
            presentingController.presentedViewController should equal(controller);
        });

        it(@"should show a close button", ^{
            [[controller.view subviews] lastObject] should equal(controller.closeButton);
        });

        context(@"when presented again", ^{
            it(@"should not try to present itself", ^{
                UIViewController *differentPresentingController = [[UIViewController alloc] init];
                [controller presentInterstitialFromViewController:differentPresentingController];
                differentPresentingController.presentedViewController should be_nil;
            });
        });

        context(@"when the close button is tapped", ^{
            beforeEach(^{
                [controller.closeButton tap];
                [controller viewWillDisappear:NO];
                [controller viewDidDisappear:NO];
            });

            it(@"should dismiss the controller", ^{
                presentingController.presentedViewController should be_nil;
            });

            it(@"should allow new presentations", ^{
                UIViewController *differentPresentingController = [[UIViewController alloc] init];
                [controller presentInterstitialFromViewController:differentPresentingController];
                differentPresentingController.presentedViewController should equal(controller);
            });
        });
    });

#if __IPHONE_OS_VERSION_MAX_ALLOWED < MP_IOS_7_0
    // XXX jren
    // status bar show/hide paradigm is totally changed in ios 7. Now each viewcontroller is asked - (BOOL)prefersStatusBarHidden
    // to determine status bar visibility instead of setting it globally through UIApplication
    describe(@"showing/hiding the status bar", ^{
        context(@"when originally shown", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            });

            it(@"should come back after the interstitial is dismissed", ^{
                [controller presentInterstitialFromViewController:presentingController];
                [UIApplication sharedApplication].isStatusBarHidden should equal(YES);

                [controller.closeButton tap];
                [UIApplication sharedApplication].isStatusBarHidden should equal(NO);
            });
        });

        context(@"when not originally shown", ^{
            beforeEach(^{
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
            });

            it(@"should remain hidden after the interstitial is dismissed", ^{
                [controller presentInterstitialFromViewController:presentingController];
                [UIApplication sharedApplication].isStatusBarHidden should equal(YES);

                [controller.closeButton tap];
                [UIApplication sharedApplication].isStatusBarHidden should equal(YES);
            });
        });
    });
#endif

    describe(@"showing/hiding the close button", ^{
        beforeEach(^{
            [controller presentInterstitialFromViewController:presentingController];
        });

        context(@"when the close button style is always visible", ^{
            beforeEach(^{
                [controller setCloseButtonStyle:MPInterstitialCloseButtonStyleAlwaysVisible];
            });

            it(@"should show the button", ^{
                controller.closeButton.hidden should equal(NO);
            });
        });

        context(@"when the close button style is always hidden", ^{
            beforeEach(^{
                [controller setCloseButtonStyle:MPInterstitialCloseButtonStyleAlwaysHidden];
            });

            it(@"should hide the button", ^{
                controller.closeButton.hidden should equal(YES);
            });
        });

        context(@"when the close button style is ad controlled", ^{
            beforeEach(^{
                [controller setCloseButtonStyle:MPInterstitialCloseButtonStyleAdControlled];
            });

            it(@"should show the button", ^{
                controller.closeButton.hidden should equal(NO);
            });
        });

        context(@"otherwise", ^{
            beforeEach(^{
                [controller setCloseButtonStyle:10000000];
            });

            it(@"should show the button", ^{
                controller.closeButton.hidden should equal(NO);
            });
        });
    });

    describe(@"autorotation", ^{
        it(@"should allow autorotation", ^{
            controller.shouldAutorotate should equal(YES);
        });

        describe(@"-shouldAutorotateToInterfaceOrientation", ^{
            it(@"should only return YES if the requested orientation matches the orientationType", ^{
                controller.orientationType = MPInterstitialOrientationTypePortrait;
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait] should equal(YES);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown] should equal(YES);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft] should equal(NO);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight] should equal(NO);

                controller.orientationType = MPInterstitialOrientationTypeLandscape;
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait] should equal(NO);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown] should equal(NO);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft] should equal(YES);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight] should equal(YES);

                controller.orientationType = MPInterstitialOrientationTypeAll;
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait] should equal(YES);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown] should equal(YES);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft] should equal(YES);
                [controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight] should equal(YES);
            });
        });

        context(@"when the orientationType is set to portrait", ^{
            beforeEach(^{
                controller.orientationType = MPInterstitialOrientationTypePortrait;
            });

            it(@"should do the right thing", ^{
                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationPortrait);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationPortrait);


                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskPortrait);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationPortrait);


                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskLandscape);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationLandscapeLeft);
            });
        });

        context(@"when the orientationType is set to landscape", ^{
            beforeEach(^{
                controller.orientationType = MPInterstitialOrientationTypeLandscape;
            });

            it(@"should do the right thing", ^{
                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskLandscape);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationLandscapeLeft);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationLandscapeLeft);


                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskPortrait);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationPortrait);


                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskLandscape);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationLandscapeLeft);
            });
        });

        context(@"when the orientationType is set to both portrait/landscape", ^{
            beforeEach(^{
                controller.orientationType = MPInterstitialOrientationTypeAll;
            });

            it(@"should do the right thing", ^{
                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskAll);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationPortrait);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationLandscapeLeft);


                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskPortrait);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationPortrait);


                [[UIApplication sharedApplication] setSupportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
                controller.supportedInterfaceOrientations should equal(UIInterfaceOrientationMaskLandscape);

                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                controller.preferredInterfaceOrientationForPresentation should equal(UIInterfaceOrientationLandscapeLeft);
            });
        });
    });
});

SPEC_END
