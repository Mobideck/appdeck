#import "MPActivityViewControllerHelper.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPActivityViewControllerHelperSpec)

xdescribe(@"MPActivityViewControllerHelper", ^{
    __block MPActivityViewControllerHelper *activityViewControllerHelper;
    __block id<MPActivityViewControllerHelperDelegate> delegate;
    __block UIViewController *presentingViewController;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPActivityViewControllerHelperDelegate));
        activityViewControllerHelper = [[MPActivityViewControllerHelper alloc] initWithDelegate:delegate];
        presentingViewController = [[UIViewController alloc] init];
        delegate stub_method("viewControllerForPresentingActivityViewController").and_return(presentingViewController);
    });

    describe(@"Initialization", ^{
        it(@"should initialize the delegate with the passed in value", ^{
            activityViewControllerHelper.delegate should equal(delegate);
        });

        it(@"should not have sent the activityViewControllerWillPresent message to its delegate", ^{
            delegate should_not have_received(@selector(activityViewControllerWillPresent));
        });

        it(@"should not have sent the viewControllerForPresentingActivityViewController message to its delegate", ^{
            delegate should_not have_received(@selector(viewControllerForPresentingActivityViewController));
        });

        it(@"should not have sent the viewControllerForPresentingActivityViewController message to its delegate", ^{
            delegate should_not have_received(@selector(activityViewControllerDidDismiss));
        });
    });

    describe(@"if the delegate does not implement activityControllerWillPresent", ^{
        beforeEach(^{
            activityViewControllerHelper.delegate = fake_for(@protocol(MPActivityViewControllerHelperDelegate));
            activityViewControllerHelper.delegate stub_method("viewControllerForPresentingActivityViewController");
        });

        it(@"calling presentActivityViewWithSubject:body should not crash", ^{
            ^{
                [activityViewControllerHelper presentActivityViewControllerWithSubject:@"Subject" body:@"Body"] should equal(YES);
            } should_not raise_exception;
        });
    });

    describe(@"calling presentActivityViewWithSubject:body", ^{
        beforeEach(^{
            [activityViewControllerHelper presentActivityViewControllerWithSubject:@"Subject" body:@"Body"] should equal(YES);
        });

        it(@"should have sent the activityViewControllerWillPresent message to its delegate", ^{
            delegate should have_received(@selector(activityViewControllerWillPresent));
        });

        it(@"should have sent the viewControllerForPresentingActivityViewController message to its delegate", ^{
            delegate should have_received(@selector(viewControllerForPresentingActivityViewController));
        });

        it(@"should not have sent the activityViewControllerDidDismiss message to its delegate", ^{
            delegate should_not have_received(@selector(activityViewControllerDidDismiss));
        });

        describe(@"then the UIActivityViewController completion handler", ^{
            __block UIActivityViewController *activityController;

            beforeEach(^{
                activityController = (UIActivityViewController*)presentingViewController.presentedViewController;
            });

            it(@"should send the activityViewControllerDidDismiss message to its delegate", ^{
                activityController.completionHandler should_not be_nil;
                activityController.completionHandler(nil, YES);
                delegate should have_received(@selector(activityViewControllerDidDismiss));
            });

            describe(@"if the delegate does not implement activityViewControllerDidDismiss", ^{
                beforeEach(^{
                    activityViewControllerHelper.delegate =
                        fake_for(@protocol(MPActivityViewControllerHelperDelegate));
                    activityViewControllerHelper.delegate
                        stub_method("viewControllerForPresentingActivityViewController");
                });

                it(@"should not crash", ^{
                    ^{ activityController.completionHandler(nil, YES); } should_not raise_exception;
                });
            });
        });
    });
});

SPEC_END
