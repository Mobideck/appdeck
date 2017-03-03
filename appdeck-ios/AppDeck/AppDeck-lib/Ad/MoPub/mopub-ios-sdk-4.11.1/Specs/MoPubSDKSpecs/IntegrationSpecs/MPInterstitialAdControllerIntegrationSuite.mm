#import "MPInterstitialAdController.h"
#import "FakeInterstitialCustomEvent.h"
#import "MPAdConfigurationFactory.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialAdControllerIntegrationSuite)

describe(@"MPInterstitialAdControllerIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeInterstitialCustomEvent *fakeInterstitialCustomEvent;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"custom_event_interstitial"];
        interstitial.delegate = delegate;

        presentingController = [[UIViewController alloc] init];

        [interstitial loadAd];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"custom_event_interstitial");

        fakeInterstitialCustomEvent = [[FakeInterstitialCustomEvent alloc] init];
        fakeProvider.fakeInterstitialCustomEvent = fakeInterstitialCustomEvent;

        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];
        configuration.customEventClassData = @{@"hello": @"world"};
        [communicator receiveConfiguration:configuration];

        // clear out the communicator so we can make future assertions about it
        [communicator resetLoadedURL];

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"custom_event_interstitial", fakeInterstitialCustomEvent, configuration.failoverURL);
    });

    context(@"while the ad is loading", ^{
        it(@"should tell the custom event to load, passing in the correct custom event info", ^{
            fakeInterstitialCustomEvent.customEventInfo should equal(configuration.customEventClassData);
        });

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
            [fakeInterstitialCustomEvent simulateLoadingAd];
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
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                [interstitial showFromViewController:presentingController];
                verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:"]);
                [fakeInterstitialCustomEvent simulateInterstitialFinishedAppearing];
                verify_fake_received_selectors(delegate, @[@"interstitialDidAppear:"]);
            });

            it(@"should track an impression and tell the custom event to show", ^{
                fakeInterstitialCustomEvent.presentingViewController should equal(presentingController);
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });

            context(@"when the user interacts with the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                });

                it(@"should track only one click, no matter how many interactions there are, and should tell the delegate for each click", ^{
                    [fakeInterstitialCustomEvent simulateUserTap];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                    [fakeInterstitialCustomEvent simulateUserTap];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);

                    delegate.sent_messages.count should equal(2);
                });
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

            context(@"and the user tries to show (again)", ^{
                __block UIViewController *newPresentingController;

                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];

                    newPresentingController = [[UIViewController alloc] init];
                    [interstitial showFromViewController:newPresentingController];
                    [fakeInterstitialCustomEvent simulateInterstitialFinishedAppearing];
                });

                it(@"should tell the custom event to show and send the delegate messages again", ^{
                    // XXX: The "ideal" behavior here is to ignore any -show messages after the first one, until the
                    // underlying ad is dismissed. However, given the risk that some third-party or custom event
                    // network could give us a silent failure when presenting (and therefore never dismiss), it might
                    // be best just to allow multiple calls to go through.

                    fakeInterstitialCustomEvent.presentingViewController should equal(newPresentingController);
                    verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                });
            });

            context(@"when the ad is dismissed", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeInterstitialCustomEvent simulateUserDismissingAd];
                    verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:"]);
                    [fakeInterstitialCustomEvent simulateInterstitialFinishedDisappearing];
                    verify_fake_received_selectors(delegate, @[@"interstitialDidDisappear:"]);
                });

                it(@"should tell the delegate and should no longer be ready", ^{
                    interstitial.ready should equal(NO);
                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
            });
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [fakeInterstitialCustomEvent simulateFailingToLoad];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
    });
});

SPEC_END
