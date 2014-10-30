#import "MPAdDestinationDisplayAgent.h"
#import "MPProgressOverlayView.h"
#import "MPAdBrowserController.h"
#import "MPURLResolver.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

typedef void (^URLVerificationBlock)(NSURL *URL);

SPEC_BEGIN(MPAdDestinationDisplayAgentSpec)

describe(@"MPAdDestinationDisplayAgent", ^{
    __block MPAdDestinationDisplayAgent *agent;
    __block id<CedarDouble, MPAdDestinationDisplayAgentDelegate> delegate;
    __block MPURLResolver<CedarDouble> *resolver;
    __block UIWindow *window;
    __block NSURL *URL;
    __block UIViewController *presentingViewController;
    __block URLVerificationBlock verifyThatTheURLWasSentToApplication;
    __block NoArgBlock verifyThatDisplayDestinationIsEnabled;

    beforeEach(^{
        resolver = nice_fake_for([MPURLResolver class]);
        fakeCoreProvider.fakeMPURLResolver = resolver;

        delegate = nice_fake_for(@protocol(MPAdDestinationDisplayAgentDelegate));
        presentingViewController = [[[UIViewController alloc] init] autorelease];
        delegate stub_method("viewControllerForPresentingModalView").and_return(presentingViewController);

        agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];

        window = [[[UIWindow alloc] init] autorelease];
        [window makeKeyAndVisible];

        verifyThatTheURLWasSentToApplication = [^(NSURL *URL){
            window.subviews.lastObject should be_nil;
            delegate should have_received(@selector(displayAgentWillLeaveApplication));
            [[UIApplication sharedApplication] lastOpenedURL] should equal(URL);
        } copy];

        verifyThatDisplayDestinationIsEnabled = [^{
            [delegate reset_sent_messages];
            [agent displayDestinationForURL:[NSURL URLWithString:@"http://www.google.com/"]];
            delegate should have_received(@selector(displayAgentWillPresentModal));
        } copy];
    });

    afterEach(^{
        [window resignKeyWindow];
    });

    describe(@"when told to display the destination for a URL", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
        });

        it(@"should bring up the loading indicator", ^{
            window.subviews.lastObject should be_instance_of([MPProgressOverlayView class]);
        });

        it(@"should tell its delegate that an displayAgentWillPresentModal", ^{
            delegate should have_received(@selector(displayAgentWillPresentModal));
        });

        it(@"should tell the resolver to resolve the URL", ^{
            resolver should have_received(@selector(startResolvingWithURL:delegate:)).with(URL).and_with(agent);
        });

        describe(@"when its told again (immediately)", ^{
            it(@"should ignore the second request", ^{
                [delegate reset_sent_messages];
                [agent displayDestinationForURL:URL];
                delegate should_not have_received(@selector(displayAgentWillPresentModal));
            });
        });
    });

    describe(@"when told to display a webview with an HTML string and a base URL", ^{
        __block MPAdBrowserController *browser;
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
            [agent showWebViewWithHTMLString:@"Hello" baseURL:URL];

            presentingViewController.presentedViewController should be_instance_of([MPAdBrowserController class]);
            browser = (MPAdBrowserController *)presentingViewController.presentedViewController;

            browser.view should_not be_nil;
            [browser viewWillAppear:NO];
            [browser viewDidAppear:NO];
        });

        it(@"should hide the loading indicator", ^{
            window.subviews.lastObject should be_nil;
        });

        it(@"should present a correctly configured webview", ^{
            browser.URL should equal(URL);
            browser.webView.loadedHTMLString should equal(@"Hello");
        });

        context(@"when the browser is closed", ^{
            beforeEach(^{
                [browser.doneButton tap];
            });

            it(@"should tell its delegate that an displayAgentDidDismissModal", ^{
                delegate should have_received(@selector(displayAgentDidDismissModal));
            });

            it(@"should dismiss the browser modal", ^{
                presentingViewController.presentedViewController should be_nil;
            });

            it(@"should allow subsequent displayDestinationForURL: calls", ^{
                verifyThatDisplayDestinationIsEnabled();
            });
        });
    });

    describe(@"when told to ask the application to open the URL", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://maps.google.com/timbuktu"];
            [agent displayDestinationForURL:URL];
            [agent openURLInApplication:URL];
        });

        it(@"should hide the loading indicator, tell the delegate, and send the URL to the shared application", ^{
            verifyThatTheURLWasSentToApplication(URL);
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });
    });

    describe(@"when dealing with telephone URLs", ^{
        __block UIAlertView *currentAlert;

        it(@"should call show on the confirmation controller for tel", ^{
            URL = [NSURL URLWithString:@"tel:5555555555"];
            [UIAlertView currentAlertView] should be_nil;
            [agent openURLInApplication:URL];
            UIAlertView *currentAlert = [UIAlertView currentAlertView];
            currentAlert.numberOfButtons should equal(2);
            currentAlert.title should_not be_nil;
            currentAlert.message should_not be_nil;
        });

        it(@"should call show on the confirmation controller for telPrompt", ^{
            URL = [NSURL URLWithString:@"telPrompt:5555555555"];
            [UIAlertView currentAlertView] should be_nil;
            [agent openURLInApplication:URL];
            UIAlertView *currentAlert = [UIAlertView currentAlertView];
            currentAlert.numberOfButtons should equal(2);
            currentAlert.title should_not be_nil;
            currentAlert.message should_not be_nil;
        });

        it(@"should not call show on non-telephone URLs", ^{
            URL = [NSURL URLWithString:@"teletubby:5555555555"];
            [agent openURLInApplication:URL];
            [UIAlertView currentAlertView] should be_nil;

            URL = [NSURL URLWithString:@"http://www.teletubby.com:55555"];
            [agent openURLInApplication:URL];
            [UIAlertView currentAlertView] should be_nil;

            URL = [NSURL URLWithString:@"twitter://55555"];
            [agent openURLInApplication:URL];
            [UIAlertView currentAlertView] should be_nil;
        });

        context(@"when telephone alert button cancel is tapped", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"tel:5555555555"];
                [agent openURLInApplication:URL];
                currentAlert = [UIAlertView currentAlertView];
                [currentAlert dismissWithCancelButton];
            });

            it(@"should not notify the delegate that the agent will leave application", ^{
                delegate should_not have_received(@selector(displayAgentWillLeaveApplication));
            });

            // We call didDismissModal to match the displayAgentWillPresentModal that is called earlier in the flow.
            it(@"should notify delegate that modal did dismiss", ^{
                delegate should have_received(@selector(displayAgentDidDismissModal));
            });
        });

        context(@"when telephone alert button call is tapped", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"tel:5555555555"];
                [agent openURLInApplication:URL];
                currentAlert = [UIAlertView currentAlertView];
                [currentAlert dismissWithOkButton];
            });

            it(@"should notify the delegate that the agent will leave application", ^{
                delegate should have_received(@selector(displayAgentWillLeaveApplication));
            });

            // We call didDismissModal to match the displayAgentWillPresentModal that is called earlier in the flow.
            it(@"should notify delegate that modal did dismiss", ^{
                delegate should have_received(@selector(displayAgentDidDismissModal));
            });
        });
    });

    describe(@"when told to show a store kit item", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://itunes.apple.com/something/id1234"];
        });

        context(@"when store kit is available", ^{
            __block FakeStoreProductViewController *store;

            beforeEach(^{
                [MPStoreKitProvider setDeviceHasStoreKit:YES];
                [agent displayDestinationForURL:URL];
                [agent showStoreKitProductWithParameter:@"1234" fallbackURL:URL];
                store = [MPStoreKitProvider lastStore];
            });

            it(@"should tell store kit to load the store item and present the view controller", ^{
                store.storeItemIdentifier should equal(@"1234");
                window.subviews.lastObject should be_nil;
                presentingViewController.presentedViewController should equal(store);
            });

            context(@"when the person leaves the store", ^{
                beforeEach(^{
                    [store.delegate productViewControllerDidFinish:store.masquerade];
                });

                it(@"should dismiss the store", ^{
                    presentingViewController.presentedViewController should be_nil;
                });

                it(@"should tell its delegate that an displayAgentDidDismissModal", ^{
                    delegate should have_received(@selector(displayAgentDidDismissModal));
                });

                it(@"should allow subsequent displayDestinationForURL: calls", ^{
                    verifyThatDisplayDestinationIsEnabled();
                });
            });
        });

        context(@"when store kit is not available (iOS < 6)", ^{
            beforeEach(^{
                [MPStoreKitProvider setDeviceHasStoreKit:NO];
                [agent displayDestinationForURL:URL];
                [agent showStoreKitProductWithParameter:@"1234" fallbackURL:URL];
            });

            it(@"should ask the application to load the URL", ^{
                verifyThatTheURLWasSentToApplication(URL);
            });
        });
    });

    describe(@"when the resolution of the URL fails", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"floogbarg://dummy"];
            [agent displayDestinationForURL:URL];
            [agent failedToResolveURLWithError:nil];
        });

        it(@"should hide the loading indicator", ^{
            window.subviews.lastObject should be_nil;
        });

        it(@"should tell the delegate that an displayAgentDidDismissModal", ^{
            delegate should have_received(@selector(displayAgentDidDismissModal));
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });
    });

    describe(@"when the user cancels by closing the loading indicator", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
            [agent overlayCancelButtonPressed];
        });

        it(@"should cancel the resolver", ^{
            resolver should have_received(@selector(cancel));
        });

        it(@"should tell the delegate that an displayAgentDidDismissModal", ^{
            delegate should have_received(@selector(displayAgentDidDismissModal));
        });

        it(@"should hide the overlay", ^{
            window.subviews.lastObject should be_nil;
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });
    });

    describe(@"verifying that the resolver and display agent play nice", ^{
        beforeEach(^{
            fakeCoreProvider.fakeMPURLResolver = nil;
            agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
        });

        it(@"should use the resolver to determine what to do with the URL", ^{
            URL = [NSURL URLWithString:@"http://maps.google.com"];
            [agent displayDestinationForURL:URL];
            [[UIApplication sharedApplication] lastOpenedURL] should equal(URL);
        });
    });

    describe(@"-cancel", ^{
        context(@"when the display agent is in use", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"http://www.google.com"];
                [agent displayDestinationForURL:URL];
                [agent cancel];
            });

            it(@"should cancel the resolver", ^{
                resolver should have_received(@selector(cancel));
            });

            it(@"should tell the delegate that an displayAgentDidDismissModal", ^{
                delegate should have_received(@selector(displayAgentDidDismissModal));
            });

            it(@"should hide the overlay", ^{
                window.subviews.lastObject should be_nil;
            });

            it(@"should allow subsequent displayDestinationForURL: calls", ^{
                verifyThatDisplayDestinationIsEnabled();
            });
        });

        context(@"when the display agent is not in use", ^{
            beforeEach(^{
                [agent cancel];
            });

            it(@"should not tell the delegate that an displayAgentDidDismissModal", ^{
                delegate should_not have_received(@selector(displayAgentDidDismissModal));
            });
        });
    });

    describe(@"-dealloc", ^{
        context(@"while the overlay is showing", ^{
            beforeEach(^{
                
                
                // XXX: When creating a display agent, we typically substitute a Cedar double
                // wherever a URL resolver is needed, but we don't want to do that here. The reason
                // is that doubles retain all arguments on method calls until the end of a test run,
                // preventing those arguments from being deallocated. The display agent invokes
                // the resolver's -setDelegate: method (passing itself) which means that it won't
                // be released during this test. This is the exact behavior we're trying to test,
                // so we need to avoid using a URL resolver double.
                fakeCoreProvider.fakeMPURLResolver = nil;
                
                @autoreleasepool {
                    URL = [NSURL URLWithString:@"http://www.google.com"];
                    agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
                    [agent displayDestinationForURL:URL];
                    window.subviews.lastObject should be_instance_of([MPProgressOverlayView class]);
                }
            });
            
            it(@"should hide the overlay", ^{
                window.subviews.lastObject should be_nil;
            });
        });

        context(@"while the StoreKit controller is showing", ^{
            __block FakeStoreProductViewController *store;

            beforeEach(^{
                @autoreleasepool {
                    URL = [NSURL URLWithString:@"http://itunes.apple.com/something/id1234"];
                    agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
                    [agent displayDestinationForURL:URL];
                    [agent showStoreKitProductWithParameter:@"1234" fallbackURL:URL];
                    store = [MPStoreKitProvider lastStore];
                    presentingViewController.presentedViewController should equal(store);
                }
            });

            it(@"should still allow the controller to be dismissed later", ^{
                [store.delegate productViewControllerDidFinish:store.masquerade];
                presentingViewController.presentedViewController should be_nil;
            });
        });
    });
});

SPEC_END
