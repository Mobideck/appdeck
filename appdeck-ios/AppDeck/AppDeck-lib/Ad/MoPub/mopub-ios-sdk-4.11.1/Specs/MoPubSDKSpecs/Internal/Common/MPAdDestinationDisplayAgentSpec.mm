#import "MPAdDestinationDisplayAgent.h"
#import "MPProgressOverlayView.h"
#import "MPAdBrowserController.h"
#import "MPURLResolver.h"
#import "CedarAsync.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

typedef void (^URLVerificationBlock)(NSURL *URL);

@interface MPAdDestinationDisplayAgent ()

@property (nonatomic, strong) MPURLResolver *resolver;
@property (nonatomic, strong) MPActivityViewControllerHelper *activityViewControllerHelper;

@end

SPEC_BEGIN(MPAdDestinationDisplayAgentSpec)

xdescribe(@"MPAdDestinationDisplayAgent", ^{
    __block MPAdDestinationDisplayAgent *agent;
    __block id<CedarDouble, MPAdDestinationDisplayAgentDelegate> delegate;
    __block FakeMPURLResolver *fakeResolver;
    __block UIWindow *window;
    __block NSURL *URL;
    __block UIViewController *presentingViewController;
    __block URLVerificationBlock verifyThatTheURLWasSentToApplication;
    __block NoArgBlock verifyThatDisplayDestinationIsEnabled;
    __block FakeMPAnalyticsTracker *sharedFakeMPAnalyticsTracker;

    beforeEach(^{
        fakeResolver = [[FakeMPURLResolver alloc] init];
        fakeCoreProvider.fakeMPURLResolver = fakeResolver;

        delegate = nice_fake_for(@protocol(MPAdDestinationDisplayAgentDelegate));
        presentingViewController = [[UIViewController alloc] init];
        delegate stub_method("viewControllerForPresentingModalView").and_return(presentingViewController);

        agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];

        window = [[UIWindow alloc] init];
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
        sharedFakeMPAnalyticsTracker = [[FakeMPCoreInstanceProvider sharedProvider] sharedFakeMPAnalyticsTracker];
        [sharedFakeMPAnalyticsTracker reset];
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

        it(@"should tell its delegate that a displayAgentWillPresentModal", ^{
            delegate should have_received(@selector(displayAgentWillPresentModal));
        });

        it(@"should tell the resolver to resolve the URL", ^{
            fakeResolver.URL should equal(URL);
            fakeResolver.started should equal(YES);
        });

        describe(@"when its told again (immediately)", ^{
            it(@"should ignore the second request", ^{
                [delegate reset_sent_messages];

                fakeCoreProvider.fakeMPURLResolver = [[FakeMPURLResolver alloc] init];
                [agent displayDestinationForURL:URL];

                fakeCoreProvider.fakeMPURLResolver.URL should equal(nil);
                fakeCoreProvider.fakeMPURLResolver.started should equal(NO);
                delegate should_not have_received(@selector(displayAgentWillPresentModal));
            });
        });
    });

    describe(@"when told to display a webview with an HTML string and a base URL", ^{
        __block MPAdBrowserController *browser;
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
            [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL HTTPResponseString:@"Hello" webViewBaseURL:URL]];

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
            //browser.webView.loadedHTMLString should equal(@"Hello");
        });

        context(@"when the browser is closed", ^{
            beforeEach(^{
                [browser.doneButton tap];
            });

            it(@"should tell its delegate that a displayAgentDidDismissModal", ^{
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

    describe(@"when told to ask another application to open the URL", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://maps.google.com/timbuktu"];
            [agent displayDestinationForURL:URL];
            [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
        });

        it(@"should hide the loading indicator, tell the delegate, and send the URL to the shared application", ^{
            verifyThatTheURLWasSentToApplication(URL);
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });

        it(@"should tell the delegate that a displayAgentDidDismissModal", ^{
            delegate should have_received(@selector(displayAgentDidDismissModal));
        });
    });

    describe(@"when dealing with telephone URLs", ^{
        __block UIAlertView *currentAlert;

        it(@"should call show on the confirmation controller for tel", ^{
            URL = [NSURL URLWithString:@"tel:5555555555"];
            [UIAlertView currentAlertView] should be_nil;
            [agent displayDestinationForURL:URL];
            [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
            UIAlertView *currentAlert = [UIAlertView currentAlertView];
            currentAlert.numberOfButtons should equal(2);
            currentAlert.title should_not be_nil;
            currentAlert.message should_not be_nil;
        });

        it(@"should call show on the confirmation controller for telPrompt", ^{
            URL = [NSURL URLWithString:@"telPrompt:5555555555"];
            [UIAlertView currentAlertView] should be_nil;
            [agent displayDestinationForURL:URL];
            [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
            UIAlertView *currentAlert = [UIAlertView currentAlertView];
            currentAlert.numberOfButtons should equal(2);
            currentAlert.title should_not be_nil;
            currentAlert.message should_not be_nil;
        });

        it(@"should not call show on non-telephone URLs", ^{
            URL = [NSURL URLWithString:@"teletubby:5555555555"];
            [agent displayDestinationForURL:URL];
            [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
            [UIAlertView currentAlertView] should be_nil;

            URL = [NSURL URLWithString:@"http://www.teletubby.com:55555"];
            [agent displayDestinationForURL:URL];
            [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
            [UIAlertView currentAlertView] should be_nil;

            URL = [NSURL URLWithString:@"twitter://55555"];
            [agent displayDestinationForURL:URL];
            [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
            [UIAlertView currentAlertView] should be_nil;
        });

        context(@"when telephone alert button cancel is tapped", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"tel:5555555555"];
                [agent displayDestinationForURL:URL];
                [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
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
                [agent displayDestinationForURL:URL];
                [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL deeplinkURL:URL]];
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
                [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL iTunesItemIdentifier:@"1234" iTunesStoreFallbackURL:URL]];
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

                it(@"should tell its delegate that a displayAgentDidDismissModal", ^{
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
                [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL iTunesItemIdentifier:@"1234" iTunesStoreFallbackURL:URL]];
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
            [fakeResolver resolveWithError:[NSErrorFactory genericError]];
        });

        it(@"should hide the loading indicator", ^{
            window.subviews.lastObject should be_nil;
        });

        it(@"should tell the delegate that a displayAgentDidDismissModal", ^{
            delegate should have_received(@selector(displayAgentDidDismissModal));
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });
    });

    describe(@"when the given URL is a request for an 'enhanced' deeplink", ^{
        __block NSString *URLString;

        context(@"when an installed app is able to open the primary deeplink URL", ^{
            beforeEach(^{
                // These examples use maps:// since that scheme is supported in the simulator.
                URLString = @"deeplink+://navigate?primaryUrl=maps%3A%2F%2F&primaryTrackingUrl=http%3A%2F%2Fwww.mopub.com&primaryTrackingUrl=http%3A%2F%2Fwww.twitter.com";
                NSURL *deeplinkPlusURL = [NSURL URLWithString:URLString];
                [agent displayDestinationForURL:deeplinkPlusURL];

                // Sanity check: tracking URLs should not have fired by this point.
                sharedFakeMPAnalyticsTracker.trackingRequestURLs should be_empty;

                MPEnhancedDeeplinkRequest *request = [[MPEnhancedDeeplinkRequest alloc] initWithURL:deeplinkPlusURL];
                [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:deeplinkPlusURL enhancedDeeplinkRequest:request]];
            });

            it(@"should open that URL", ^{
                [[UIApplication sharedApplication] lastOpenedURL] should equal([NSURL URLWithString:@"maps://"]);
            });

            it(@"should fire any primary tracking URLs on the deeplink request", ^{
                [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(2);
                ((NSURL *)[sharedFakeMPAnalyticsTracker.trackingRequestURLs objectAtIndex:0]).absoluteString should equal(@"http://www.mopub.com");
                ((NSURL *)[sharedFakeMPAnalyticsTracker.trackingRequestURLs objectAtIndex:1]).absoluteString should equal(@"http://www.twitter.com");
            });

            it(@"should tell the delegate that a displayAgentDidDismissModal", ^{
                delegate should have_received(@selector(displayAgentDidDismissModal));
            });
        });

        context(@"when there is no installed app that can open the primary deeplink URL", ^{
            beforeEach(^{
                URLString = @"deeplink+://navigate?primaryUrl=noway%3A%2F%2Fnope";
            });

            context(@"if there is no fallback URL", ^{
                __block NSURL *deeplinkPlusURL;

                beforeEach(^{
                    deeplinkPlusURL = [NSURL URLWithString:URLString];
                    [agent displayDestinationForURL:deeplinkPlusURL];

                    MPEnhancedDeeplinkRequest *request = [[MPEnhancedDeeplinkRequest alloc] initWithURL:deeplinkPlusURL];
                    [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:deeplinkPlusURL enhancedDeeplinkRequest:request]];
                });

                it(@"should retry the original deeplink+:// URL as a regular deeplink", ^{
                    [[UIApplication sharedApplication] lastOpenedURL] should equal(deeplinkPlusURL);
                });
            });

            context(@"if there is a fallback URL", ^{
                context(@"and it is valid", ^{
                    beforeEach(^{
                        URLString = [URLString stringByAppendingString:@"&fallbackUrl=http%3A%2F%2Fwww.example.com&fallbackTrackingUrl=http%3A%2F%2Fwww.mopub.com&fallbackTrackingUrl=http%3A%2F%2Fwww.twitter.com"];
                        NSURL *deeplinkPlusURL = [NSURL URLWithString:URLString];
                        [agent displayDestinationForURL:deeplinkPlusURL];

                        // Sanity check: tracking URLs should not have fired by this point.
                        sharedFakeMPAnalyticsTracker.trackingRequestURLs should be_empty;

                        MPEnhancedDeeplinkRequest *request = [[MPEnhancedDeeplinkRequest alloc] initWithURL:deeplinkPlusURL];
                        [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:deeplinkPlusURL enhancedDeeplinkRequest:request]];

                        fakeResolver.URL.absoluteString should equal(@"http://www.example.com");
                        [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:fakeResolver.URL HTTPResponseString:@"Hi" webViewBaseURL:nil]];
                    });

                    it(@"should resolve the URL as it normally would", ^{
                        // In this example, the fallback URL should be opened in a browser.
                        presentingViewController.presentedViewController should be_instance_of([MPAdBrowserController class]);
                    });

                    it(@"should fire any fallback tracking URLs on the deeplink request", ^{
                        [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(2);
                        ((NSURL *)[sharedFakeMPAnalyticsTracker.trackingRequestURLs objectAtIndex:0]).absoluteString should equal(@"http://www.mopub.com");
                        ((NSURL *)[sharedFakeMPAnalyticsTracker.trackingRequestURLs objectAtIndex:1]).absoluteString should equal(@"http://www.twitter.com");
                    });
                });

                context(@"and it is another deeplink+:// URL", ^{
                    beforeEach(^{
                        URLString = [URLString stringByAppendingString:@"&fallbackUrl=deeplink%2B%3A%2F%2Fnavigate%3FprimaryUrl%3Dmaps%253A%252F%252F&fallbackTrackingUrl=http%3A%2F%2Fwww.mopub.com&fallbackTrackingUrl=http%3A%2F%2Fwww.twitter.com"];
                        NSURL *deeplinkPlusURL = [NSURL URLWithString:URLString];
                        [agent displayDestinationForURL:deeplinkPlusURL];

                        MPEnhancedDeeplinkRequest *request = [[MPEnhancedDeeplinkRequest alloc] initWithURL:deeplinkPlusURL];
                        [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:deeplinkPlusURL enhancedDeeplinkRequest:request]];

                        fakeResolver.URL.absoluteString should equal(@"deeplink+://navigate?primaryUrl=maps%3A%2F%2F");
                        MPEnhancedDeeplinkRequest *nestedRequest = [[MPEnhancedDeeplinkRequest alloc] initWithURL:fakeResolver.URL];
                        [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:fakeResolver.URL enhancedDeeplinkRequest:nestedRequest]];
                    });

                    it(@"should hide the loading indicator", ^{
                        window.subviews.lastObject should be_nil;
                    });

                    it(@"should tell the delegate that a displayAgentDidDismissModal", ^{
                        delegate should have_received(@selector(displayAgentDidDismissModal));
                    });

                    it(@"should not fire any fallback tracking URLs", ^{
                        [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(0);
                    });
                });

                context(@"and it is an invalid URL", ^{
                    beforeEach(^{
                        URLString = [URLString stringByAppendingString:@"&fallbackUrl=not-valid&fallbackTrackingUrl=http%3A%2F%2Fwww.mopub.com&fallbackTrackingUrl=http%3A%2F%2Fwww.twitter.com"];
                        NSURL *deeplinkPlusURL = [NSURL URLWithString:URLString];
                        [agent displayDestinationForURL:deeplinkPlusURL];

                        MPEnhancedDeeplinkRequest *request = [[MPEnhancedDeeplinkRequest alloc] initWithURL:deeplinkPlusURL];
                        [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:deeplinkPlusURL enhancedDeeplinkRequest:request]];

                        fakeResolver.URL.absoluteString should equal(@"not-valid");
                        [fakeResolver resolveWithError:[NSErrorFactory genericError]];
                    });

                    it(@"should hide the loading indicator", ^{
                        window.subviews.lastObject should be_nil;
                    });

                    it(@"should tell the delegate that a displayAgentDidDismissModal", ^{
                        delegate should have_received(@selector(displayAgentDidDismissModal));
                    });

                    it(@"should not fire any fallback tracking URLs", ^{
                        [sharedFakeMPAnalyticsTracker.trackingRequestURLs count] should equal(0);
                    });
                });
            });
        });
    });

    describe(@"when openShareURL is called", ^{
        beforeEach(^{
            spy_on(agent.activityViewControllerHelper);
        });

        context(@"when the host is 'tweet'", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"mopubshare://tweet?screen_name=xyzzy&tweet_id=0"];
                [agent displayDestinationForURL:URL];
                [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL shareURL:URL]];
            });

            it(@"should tell activityViewControllerHelper to present activity view controller:", ^{
                agent.activityViewControllerHelper should have_received(@selector(presentActivityViewControllerWithTweetShareURL:)).with(URL);
            });

            it(@"should hide the loading indicator", ^{
                window.subviews.lastObject should be_nil;
            });
        });

        context(@"when the host is unrecognized", ^{
            it(@"should NOT tell the activityViewControllerHelper to present activity view controller", ^{
                NSURL *URL = [NSURL URLWithString:@"mopubshare://blah"];
                [agent displayDestinationForURL:URL];
                [fakeResolver resolveWithError:[NSErrorFactory genericError]];
                agent.activityViewControllerHelper should_not have_received(@selector(presentActivityViewControllerWithTweetShareURL:));
            });
        });
    });

    describe(@"when the user cancels by closing the loading indicator", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
            [agent overlayCancelButtonPressed];
        });

        it(@"should cancel the resolver", ^{
            fakeResolver.cancelled should equal(YES);
        });

        it(@"should tell the delegate that a displayAgentDidDismissModal", ^{
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
                fakeResolver.cancelled should equal(YES);
            });

            it(@"should tell the delegate that a displayAgentDidDismissModal", ^{
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

            it(@"should not tell the delegate that a displayAgentDidDismissModal", ^{
                delegate should_not have_received(@selector(displayAgentDidDismissModal));
            });
        });
    });

    describe(@"-dealloc", ^{
        context(@"while the overlay is showing", ^{
            beforeEach(^{
                @autoreleasepool {
                    URL = [NSURL URLWithString:@"http://www.google.com"];
                    agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
                    [agent displayDestinationForURL:URL];
                    window.subviews.lastObject should be_instance_of([MPProgressOverlayView class]);
                }

                agent = nil;
            });

            it(@"should hide the overlay", ^{
                in_time(window.subviews.lastObject) should be_nil;
            });
        });

        context(@"while the StoreKit controller is showing", ^{
            __block FakeStoreProductViewController *store;

            beforeEach(^{
                URL = [NSURL URLWithString:@"http://itunes.apple.com/something/id1234"];
                agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
                [agent displayDestinationForURL:URL];
                [fakeResolver resolveWithActionInfo:[MPURLActionInfo infoWithURL:URL iTunesItemIdentifier:@"1234" iTunesStoreFallbackURL:URL]];
                store = [MPStoreKitProvider lastStore];
                presentingViewController.presentedViewController should equal(store);
            });

            it(@"should still allow the controller to be dismissed later", ^{
                [store.delegate productViewControllerDidFinish:store.masquerade];
                in_time(presentingViewController.presentedViewController) should be_nil;
            });
        });
    });

    describe(@"-adConfiguration delegate method", ^{
        __block id<CedarDouble, MPAdDestinationDisplayAgentDelegate> delegate;

        beforeEach(^{
            delegate = nice_fake_for(@protocol(MPAdDestinationDisplayAgentDelegate));
            agent.delegate = delegate;
        });

        context(@"when the delegate doesn't respond to the -adConfiguration selector", ^{
            beforeEach(^{
                delegate reject_method(@selector(adConfiguration));
            });

            it(@"should return nil", ^{
                agent.adConfiguration should be_nil;
            });
        });

        context(@"when the delegate returns a nil adConfiguration", ^{
            beforeEach(^{
                delegate stub_method(@selector(adConfiguration)).and_return(nil);
            });

            it(@"should return nil", ^{
                agent.adConfiguration should be_nil;
            });
        });

        context(@"when the delegate returns a non-nil adConfiguration", ^{
            __block MPAdConfiguration *delegateAdConfiguration;
            beforeEach(^{
                delegateAdConfiguration = [[MPAdConfiguration alloc] init];
                delegate stub_method(@selector(adConfiguration)).and_return(delegateAdConfiguration);
            });

            it(@"should return the delegate's ad configuration", ^{
                agent.adConfiguration should equal(delegateAdConfiguration);
            });
        });
    });
});

SPEC_END
