#import "MPInterstitialAdController.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPWebView.h"
#import "FakeMPAdAlertManager.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(MPHTMLInterstitialIntegrationSuite)

describe(@"MPHTMLInterstitialIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeMPWebView *webview;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;
    __block FakeMPAdAlertManager *fakeAdAlertManager;

    beforeEach(^{
        FakeMPAdAlertGestureRecognizer *fakeGestureRecognizer = [[FakeMPAdAlertGestureRecognizer alloc] init];
        fakeCoreProvider.fakeAdAlertGestureRecognizer = fakeGestureRecognizer;

        fakeAdAlertManager = [[FakeMPAdAlertManager alloc] init];
        fakeCoreProvider.fakeAdAlertManager = fakeAdAlertManager;

        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"html_interstitial"];
        interstitial.location = [[CLLocation alloc] initWithLatitude:1337 longitude:1337];
        interstitial.delegate = delegate;

        presentingController = [[UIViewController alloc] init];

        // request an Ad
        [interstitial loadAd];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"html_interstitial");

        // prepare the fake and tell the injector about it
        webview = [[FakeMPWebView alloc] init];
        fakeProvider.fakeMPWebView = webview;

        // receive the configuration -- this will create an adapter which will use our fake interstitial
        configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
        [communicator receiveConfiguration:configuration];

        // clear out the communicator so we can make future assertions about it
        [communicator resetLoadedURL];

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"html_interstitial", webview, configuration.failoverURL);
    });

    context(@"while the ad is loading", ^{
//        it(@"should pass the configuration's HTML data to the webview", ^{
//            webview.loadedHTMLString should equal(configuration.adResponseHTMLString);
//        });

        it(@"should not tell the delegate anything, nor should it be ready", ^{
            delegate.sent_messages should be_empty;
            interstitial.ready should equal(NO);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatPreventsLoading); });
        context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatTimesOut); });
    });

    context(@"when the ad successfully loads", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [webview simulateLoadingAd];
        });

        it(@"should tell the delegate and -ready should return YES", ^{
            verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
            interstitial.ready should equal(YES);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });

        context(@"and the user shows the ad", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [interstitial showFromViewController:presentingController];
                UIViewController *presentedVC = presentingController.presentedViewController;
                [presentedVC viewWillAppear:MP_ANIMATED];
                [presentedVC viewDidAppear:MP_ANIMATED];
            });

            it(@"should track an impression (only once)", ^{
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);

                [presentingController dismissModalViewControllerAnimated:NO];
                [interstitial showFromViewController:presentingController];
                UIViewController *presentedVC = presentingController.presentedViewController;
                [presentedVC viewWillAppear:MP_ANIMATED];
                [presentedVC viewDidAppear:MP_ANIMATED];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });

            it(@"should tell the webview that it has been shown", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                //[webview didAppear] should equal(YES);
                webview.presentingViewController should equal(presentingController);
            });

            describe(@"MPAdAlertManager", ^{
                context(@"when the user alerts on the ad", ^{
                    beforeEach(^{
                        [fakeAdAlertManager simulateGestureRecognized];
                    });

                    it(@"should have the correct ad unit id", ^{
                        fakeAdAlertManager.adUnitId should equal(interstitial.adUnitId);
                    });

                    it(@"should have the correct location", ^{
                        fakeAdAlertManager.location.coordinate.latitude should equal(interstitial.location.coordinate.latitude);
                        fakeAdAlertManager.location.coordinate.longitude should equal(interstitial.location.coordinate.longitude);
                    });

                    it(@"should have the correct ad configuration", ^{
                        fakeAdAlertManager.adConfiguration should equal(configuration);
                    });
                });
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

            context(@"when a modal viewcontroller is presented over the ad and then dismissed", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    UIViewController *newModalVC = [[UIViewController alloc] init];
                    UIViewController *interstitialVC = presentingController.presentedViewController;
                    [interstitialVC presentViewController:newModalVC animated:MP_ANIMATED completion:nil];
                    [interstitialVC viewWillDisappear:MP_ANIMATED];
                    [interstitialVC viewDidDisappear:MP_ANIMATED];
                    [interstitialVC dismissViewControllerAnimated:MP_ANIMATED completion:nil];
                    [interstitialVC viewWillAppear:MP_ANIMATED];
                    [interstitialVC viewDidAppear:MP_ANIMATED];
                });

                it(@"should not track an extra impression", ^{
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
                });

                it(@"should not send any messages to the delegate", ^{
                    [delegate sent_messages] should be_empty;
                });
            });

            context(@"when the ad is dismissed", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [webview simulateUserDismissingAd];
                });

                it(@"should tell the delegate and should no longer be ready", ^{
                    verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:"]);
                    interstitial.ready should equal(NO);
                });

//                it(@"should no longer handle any webview requests", ^{
//                    [delegate reset_sent_messages];
//
//                    NSURL *URL = [NSURL URLWithString:@"http://www.mopub.com"];
//                    [webview sendClickRequest:[NSURLRequest requestWithURL:URL]];
//                    [delegate sent_messages] should be_empty;
//                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
            });
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [webview simulateFailingToLoad];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
    });
});

SPEC_END
