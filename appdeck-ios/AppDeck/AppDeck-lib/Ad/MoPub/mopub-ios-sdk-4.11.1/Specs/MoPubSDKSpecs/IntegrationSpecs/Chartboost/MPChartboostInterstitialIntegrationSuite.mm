#import "MPAdConfigurationFactory.h"
#import "MPInterstitialAdController.h"
#import "Chartboost+Specs.h"
#import "MPChartboostRouter.h"
#import "MPInstanceProvider+Chartboost.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPChartboostInterstitialIntegrationSuite)

describe(@"Chartboost Integration", ^{
    beforeEach(^{
        [Chartboost clearRequestedLocations];
        [Chartboost setDelegate:[fakeProvider sharedMPChartboostRouter]];
    });

    describe(@"MPChartboostInterstitialIntegrationSuite", ^{
        __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
        __block MPInterstitialAdController *interstitial = nil;
        __block UIViewController *presentingController;
        __block FakeMPAdServerCommunicator *communicator;
        __block MPAdConfiguration *configuration;

        beforeEach(^{
            delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

            interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"chartboost_interstitial"];
            interstitial.delegate = delegate;

            presentingController = [[UIViewController alloc] init];

            // request an Ad
            [interstitial loadAd];

            communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"chartboost_interstitial");

            // receive the configuration -- this will create an adapter which will use our fake interstitial
            configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:@"Boston"];
            [communicator receiveConfiguration:configuration];

            // clear out the communicator so we can make future assertions about it
            [communicator resetLoadedURL];

            setUpInterstitialSharedContext(communicator, delegate, interstitial, @"chartboost_interstitial", nice_fake_for(@protocol(FakeInterstitialAd)), configuration.failoverURL);
        });

        context(@"when Chartboost already has a cached interstitial", ^{
            beforeEach(^{
                [Chartboost setHasInterstitial:@YES forLocation:@"HazIt"];

                delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));
                interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"chartboost_interstitial_cached_test"];
                interstitial.delegate = delegate;

                presentingController = [[UIViewController alloc] init];

                // request an Ad
                [interstitial loadAd];

                communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;

                // receive the configuration -- this will create an adapter which will use our fake interstitial
                configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:@"HazIt"];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should let the delegate know the interstitial is ready", ^{
                delegate should have_received(@selector(interstitialDidLoadAd:));
            });
        });

        context(@"while the ad is loading", ^{
            it(@"should configure Chartboost properly, start the session and start caching the interstitial", ^{
                [Chartboost appId] should equal(@"myAppId");
                [Chartboost appSignature] should equal(@"myAppSignature");
                [Chartboost requestedLocations] should equal(@[@"Boston"]);
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
                [Chartboost simulateLoadingLocation:@"Boston"];
            });

            it(@"should tell the delegate and -ready should return YES", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
                interstitial.ready should equal(YES);
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
            context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });

            context(@"and the user shows the ad", ^{
                beforeEach(^{
                    [Chartboost setHasInterstitial:@YES forLocation:@"Boston"];
                    [delegate reset_sent_messages];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                    [interstitial showFromViewController:presentingController];
                });

                it(@"should track an impression and tell the custom event to show", ^{
                    verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                    [Chartboost currentVisibleLocation] should equal(@"Boston");
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
                });

                context(@"when the user interacts with the ad", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                    });

                    it(@"should track a click and should tell the delegate that it was dismissed", ^{
                        [Chartboost simulateUserTap:@"Boston"];
                        verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:", @"interstitialDidReceiveTapEvent:"]);
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                    });
                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

                context(@"when the ad is dismissed", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [Chartboost simulateUserDismissingLocation:@"Boston"];
                    });

                    it(@"should tell the delegate and should no longer be ready", ^{
                        verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:"]);
                        interstitial.ready should equal(NO);
                    });

                    context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                    context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
                });
            });

            context(@"CHARTBOOST SAD PATH: when the interstitial uncaches *before* it is shown", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [Chartboost setHasInterstitial:@NO forLocation:@"Boston"];
                    [interstitial showFromViewController:presentingController];
                });

                it(@"should not track any impressions", ^{
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                });

                it(@"should not tell Chartboost to show", ^{
                    [Chartboost currentVisibleLocation] should be_nil;
                });

                itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
            });
        });

        context(@"when the ad fails to load", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [Chartboost simulateFailingToLoadLocation:@"Boston"];
            });

            itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
            context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
        });
    });

    describe(@"handling multiple Chartboost requests (and locations)", ^{
        __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
        __block MPInterstitialAdController *nullInterstitial = nil;
        __block MPInterstitialAdController *fooInterstitial = nil;
        __block MPInterstitialAdController *barInterstitial = nil;
        __block MPAdConfiguration *configuration;
        __block FakeMPAdServerCommunicator *nullCommunicator;
        __block FakeMPAdServerCommunicator *fooCommunicator;
        __block FakeMPAdServerCommunicator *barCommunicator;

        context(@"when there are multiple Chartboost requests with mutually exclusive locations (and exactly one with nil location)", ^{
            beforeEach(^{
                delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

                nullInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"the_null_guy"];
                nullInterstitial.delegate = delegate;
                [nullInterstitial loadAd];
                nullCommunicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:nil];
                configuration.failoverURL = [NSURL URLWithString:@"http://null.com"];
                [nullCommunicator receiveConfiguration:configuration];

                fooInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"the_foo_guy"];
                fooInterstitial.delegate = delegate;
                [fooInterstitial loadAd];
                fooCommunicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:@"foo"];
                [fooCommunicator receiveConfiguration:configuration];

                barInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"the_bar_guy"];
                barInterstitial.delegate = delegate;
                [barInterstitial loadAd];

                barCommunicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:@"bar"];
                [barCommunicator receiveConfiguration:configuration];
            });

            it(@"should make three chartboost requests, passing in the correct location", ^{
                [Chartboost requestedLocations] should equal(@[@"Default", @"foo", @"bar"]);
            });

            it(@"should route chartboost notifications to the correct request", ^{
                [Chartboost simulateLoadingLocation:@"foo"];
                delegate should have_received(@selector(interstitialDidLoadAd:)).with(fooInterstitial);
                [delegate reset_sent_messages];

                [Chartboost simulateLoadingLocation:@"Default"];
                delegate should have_received(@selector(interstitialDidLoadAd:)).with(nullInterstitial);
                [delegate reset_sent_messages];

                [Chartboost simulateLoadingLocation:@"bar"];
                delegate should have_received(@selector(interstitialDidLoadAd:)).with(barInterstitial);
                [delegate reset_sent_messages];
            });

            context(@"when a new interstitial is requested with an *existing* location", ^{
                context(@"when the location is nil", ^{
                    it(@"should fail fast for the new interstitial", ^{
                        MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"another_null_guy"];
                        interstitial.delegate = delegate;
                        [interstitial loadAd];
                        FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                        configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:nil];
                        configuration.failoverURL = [NSURL URLWithString:@"http://null.com/null"];
                        [communicator receiveConfiguration:configuration];

                        // Failure means the manager should move onto the failover ad source.
                        communicator.loadedURL should equal(configuration.failoverURL);
                    });
                });

                context(@"when the location is not nil", ^{
                    it(@"should fail fast for the new interstitial", ^{
                        MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"another_bar_guy"];
                        interstitial.delegate = delegate;
                        [interstitial loadAd];
                        FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                        configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:@"bar"];
                        configuration.failoverURL = [NSURL URLWithString:@"http://bar.com/bar"];
                        [communicator receiveConfiguration:configuration];

                        // Failure means the manager should move onto the failover ad source.
                        communicator.loadedURL should equal(configuration.failoverURL);
                    });
                });
            });

            context(@"when an interstitial request fails", ^{
                it(@"should allow a subsequent request to the same location to load", ^{
                    [nullCommunicator resetLoadedURL];
                    [Chartboost simulateFailingToLoadLocation:@"Default"];
                    nullCommunicator.loadedURL should equal([NSURL URLWithString:@"http://null.com"]);

                    MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"another_null_guy"];
                    interstitial.delegate = delegate;
                    [interstitial loadAd];
                    FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                    configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:nil];
                    configuration.failoverURL = [NSURL URLWithString:@"http://null.com/null"];
                    [communicator receiveConfiguration:configuration];
                    [Chartboost simulateLoadingLocation:@"Default"];

                    delegate should have_received(@selector(interstitialDidLoadAd:)).with(interstitial);
                });
            });

            context(@"when an interstitial is dismissed", ^{
                it(@"should allow a subsequent request to the same location to load", ^{
                    [Chartboost simulateLoadingLocation:@"Default"];
                    [Chartboost simulateUserDismissingLocation:@"Default"];
                    delegate should have_received(@selector(interstitialDidDisappear:)).with(nullInterstitial);

                    MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"another_null_guy"];
                    interstitial.delegate = delegate;
                    [interstitial loadAd];
                    FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                    configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:nil];
                    configuration.failoverURL = [NSURL URLWithString:@"http://null.com/null"];
                    [communicator receiveConfiguration:configuration];
                    [Chartboost simulateLoadingLocation:@"Default"];
                    delegate should have_received(@selector(interstitialDidLoadAd:)).with(interstitial);
                });
            });
        });

        context(@"when multiple interstitials request the same location", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:@"foo"];

                delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));
            });

            it(@"should only connect the first interstitial to chartboost and should always fail the other interstitials", ^{
                // make interstitial A (and give it the configuration)
                MPInterstitialAdController *interstitialA = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"A"];
                interstitialA.delegate = delegate;
                [interstitialA loadAd];
                [fakeCoreProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                @autoreleasepool {
                    // make interstiatial B (and give it the configuration
                    MPInterstitialAdController *interstitialB = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"B"];
                    interstitialB.delegate = delegate;
                    [interstitialB loadAd];
                    configuration.failoverURL = [NSURL URLWithString:@"http://b.com/b"];
                    [fakeCoreProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                    // assert that B failed, and that A didn't get any messages
                    fakeCoreProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should equal(@"http://b.com/b");
                    delegate.sent_messages should be_empty;

                    // kill off B (like, really deallocate it)
                    [MPInterstitialAdController removeSharedInterstitialAdController:interstitialB];
                }

                // make interstitial C (and give it the configuration)
                MPInterstitialAdController *interstitialC = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"C"];
                interstitialC.delegate = delegate;
                [interstitialC loadAd];
                configuration.failoverURL = [NSURL URLWithString:@"http://c.com/c"];
                [fakeCoreProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                // assert that C failed <--
                fakeCoreProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should equal(@"http://c.com/c");

                // let chartboost finish loading
                [Chartboost simulateLoadingLocation:@"foo"];

                // assert that A got the message, and B and C did not
                delegate should have_received(@selector(interstitialDidLoadAd:)).with(interstitialA);
                delegate.sent_messages.count should equal(1);
            });
        });

        context(@"when a chartboost interstitial controller is deallocated", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultChartboostInterstitialConfigurationWithLocation:@"foo"];

                delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));
            });

            context(@"before the request arrives", ^{
                beforeEach(^{
                    @autoreleasepool {
                        MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"the_shortlived_guy"];
                        interstitial.delegate = delegate;
                        [interstitial loadAd];
                        FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                        [communicator receiveConfiguration:configuration];
                        [MPInterstitialAdController removeSharedInterstitialAdController:interstitial];
                    }
                });

                context(@"and the request subsequently arrives", ^{
                    it(@"should not blow up or tell any delegate anything", ^{
                        [Chartboost simulateLoadingLocation:@"foo"];
                        delegate.sent_messages should be_empty;
                    });
                });

                context(@"and then the user requests an interstitial with the same location", ^{
                    it(@"should allow the new request to load and follow a happy path", ^{
                        MPInterstitialAdController *another = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"anything"];
                        another.delegate = delegate;
                        [another loadAd];
                        FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                        [communicator receiveConfiguration:configuration];
                        communicator.loadedURL should_not equal(configuration.failoverURL);
                        [Chartboost simulateLoadingLocation:@"foo"];
                        delegate should have_received(@selector(interstitialDidLoadAd:)).with(another);
                    });
                });
            });

            context(@"after the request arrives, but before the ad is shown/dismissed", ^{
                context(@"and then the user requests a new interstitial with the same location", ^{
                    beforeEach(^{
                        @autoreleasepool {
                            MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"the_shortlived_guy"];
                            interstitial.delegate = delegate;
                            [interstitial loadAd];
                            FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                            [communicator receiveConfiguration:configuration];
                            [Chartboost simulateLoadingLocation:@"foo"];
                            [MPInterstitialAdController removeSharedInterstitialAdController:interstitial];
                            [delegate reset_sent_messages]; //need to do this to release the interstitial as the sent_messages retains it
                        }
                    });

                    it(@"should allow the new request to load and follow a happy path", ^{
                        MPInterstitialAdController *another = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"anything"];
                        another.delegate = delegate;
                        [another loadAd];
                        FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                        [communicator receiveConfiguration:configuration];
                        communicator.loadedURL should_not equal(configuration.failoverURL);
                        [Chartboost simulateLoadingLocation:@"foo"];
                        delegate should have_received(@selector(interstitialDidLoadAd:)).with(another);
                    });
                });
            });
        });
    });
});

SPEC_END
