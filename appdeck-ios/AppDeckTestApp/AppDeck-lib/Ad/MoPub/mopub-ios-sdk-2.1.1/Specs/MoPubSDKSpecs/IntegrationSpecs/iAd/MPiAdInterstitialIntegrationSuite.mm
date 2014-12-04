#import "MPInterstitialAdController.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPAdServerCommunicator.h"
#import "FakeADInterstitialAd.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPiAdInterstitialIntegrationSuite)

describe(@"MPiAdInterstitialIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeADInterstitialAd *fakeADInterstitialAd;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"iAd_interstitial"];
        interstitial.delegate = delegate;

        presentingController = [[[UIViewController alloc] init] autorelease];

        // request an Ad
        [interstitial loadAd];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"iAd_interstitial");

        // prepare the fake and tell the injector about it
        fakeADInterstitialAd = [[[FakeADInterstitialAd alloc] init] autorelease];
        fakeProvider.fakeADInterstitialAd = fakeADInterstitialAd.masquerade;

        // receive the configuration -- this will create an adapter which will use our fake interstitial
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"iAd_full"];
        [communicator receiveConfiguration:configuration];

        // clear out the communicator so we can make future assertions about it
        [communicator resetLoadedURL];

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"iAd_interstitial", fakeADInterstitialAd, configuration.failoverURL);
    });

    context(@"while the ad is loading", ^{
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
            [fakeADInterstitialAd simulateLoadingAd];
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
            });

            it(@"should track an impression and tell iAd to show", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                fakeADInterstitialAd.presentingViewController should equal(presentingController);
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });

            context(@"when the user interacts with the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                });

                it(@"should track only one click, no matter how many interactions there are, and shouldn't tell the delegate anything", ^{
                    [fakeADInterstitialAd simulateUserInteraction];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                    [fakeADInterstitialAd simulateUserInteraction];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);

                    delegate.sent_messages should be_empty;
                });
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

            context(@"and the user tries to show (again)", ^{
                __block UIViewController *newPresentingController;

                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];

                    newPresentingController = [[[UIViewController alloc] init] autorelease];
                    [interstitial showFromViewController:newPresentingController];
                });

                it(@"should tell iAd to show and send the delegate messages again", ^{
                    // XXX: The "ideal" behavior here is to ignore any -show messages after the first one, until the
                    // underlying ad is dismissed. However, given the risk that some third-party or custom event
                    // network could give us a silent failure when presenting (and therefore never dismiss), it might
                    // be best just to allow multiple calls to go through.

                    fakeADInterstitialAd.presentingViewController should equal(newPresentingController);
                    verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                });
            });

            context(@"when the ad is dismissed", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeADInterstitialAd simulateUserDismissingAd];
                });

                it(@"should tell the delegate and should no longer be ready", ^{
                    delegate should have_received(@selector(interstitialWillDisappear:));
                    delegate should have_received(@selector(interstitialDidDisappear:));
                    interstitial.ready should equal(NO);
                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
            });
        });

        context(@"iAD SAD PATH: when the ad unloads *before* it is shown", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [fakeADInterstitialAd simulateUnloadingAd];
            });

            it(@"should tell the delegate that the ad expired and should no longer be ready", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialDidExpire:"]);
                interstitial.ready should equal(NO);
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
            context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [fakeADInterstitialAd simulateFailingToLoad];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
    });
});

SPEC_END
