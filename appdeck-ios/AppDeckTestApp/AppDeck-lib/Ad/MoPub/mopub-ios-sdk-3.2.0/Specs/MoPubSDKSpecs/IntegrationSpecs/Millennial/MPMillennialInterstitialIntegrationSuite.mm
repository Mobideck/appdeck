#import "MPInterstitialAdController.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPAdServerCommunicator.h"
#import "FakeMMInterstitial.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMillennialInterstitialIntegrationSuite)

describe(@"MPMillennialInterstitialIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> anotherDelegate;

    __block MPInterstitialAdController *interstitial = nil;
    __block MPInterstitialAdController *anotherIntersitital = nil;

    __block UIViewController *presentingController;
    __block FakeMMInterstitial *fakeInterstitial;

    __block FakeMPAdServerCommunicator *communicator;
    __block FakeMPAdServerCommunicator *anotherCommunicator;

    __block MPAdConfiguration *configuration;
    __block MPAdConfiguration *anotherConfiguration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));
        anotherDelegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"MM_interstitial"];
        interstitial.location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                               altitude:11
                                                     horizontalAccuracy:12.3
                                                       verticalAccuracy:10
                                                              timestamp:[NSDate date]];
        interstitial.delegate = delegate;

        presentingController = [[UIViewController alloc] init];

        // request an Ad
        [interstitial loadAd];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"MM_interstitial");

        // prepare the fake and tell the injector about it
        fakeInterstitial = [[FakeMMInterstitial alloc] init];
        fakeProvider.fakeMMInterstitial = fakeInterstitial;

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"MM_interstitial", fakeInterstitial, [NSURL URLWithString:@"http://ads.mopub.com/m/failURL"]);

        anotherIntersitital = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"MM_interstitial2"];
        anotherIntersitital.delegate = anotherDelegate;
        [anotherIntersitital loadAd];
        anotherCommunicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        anotherCommunicator.loadedURL.absoluteString should contain(@"MM_interstitial2");
    });

    sharedExamplesFor(@"an available ad unit", ^(NSDictionary *sharedContext) {
        it(@"should allow the user to request a new interstitial with the same ad unit id", ^{
            [delegate reset_sent_messages];
            MPInterstitialAdController *newInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"MM_interstitial_3"];
            id<MPInterstitialAdControllerDelegate, CedarDouble> newDelegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));
            newInterstitial.delegate = newDelegate;
            [newInterstitial loadAd];

            NSDictionary *headers = @{
                                      kInterstitialAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"M1\"}"
                                      };
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                                          HTMLString:nil];
            [fakeCoreProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];
            fakeCoreProvider.lastFakeMPAdServerCommunicator.loadedURL should be_nil;

            [fakeInterstitial fetchCompletionBlock:@"M1"](YES, 0);

            newDelegate should have_received(@selector(interstitialDidLoadAd:)).with(newInterstitial);
            delegate.sent_messages should be_empty;
        });
    });

    sharedExamplesFor(@"an unavailable ad unit", ^(NSDictionary *sharedContext) {
        it(@"should not allow the user to request a new interstitial with the same ad unit id", ^{
            [fakeInterstitial reset];
            MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"MM_interstitial_4"];
            id<MPInterstitialAdControllerDelegate, CedarDouble> delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));
            interstitial.delegate = delegate;
            [interstitial loadAd];

            NSDictionary *headers = @{
                                      kInterstitialAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"M1\"}"
                                      };
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                                          HTMLString:nil];
            configuration.failoverURL = [NSURL URLWithString:@"http://le/fail"];

            [fakeCoreProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];
            fakeCoreProvider.lastFakeMPAdServerCommunicator.loadedURL should equal(configuration.failoverURL);
            fakeInterstitial.requests[@"M1"] should be_nil;
        });
    });

    context(@"when a configuration with a valid millennial ad unit id is received", ^{
        beforeEach(^{
            [delegate reset_sent_messages];

            NSDictionary *headers = @{
                                      kInterstitialAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"M1\"}"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];

            headers = @{
                        kInterstitialAdTypeHeaderKey: @"millennial_full",
                        kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"M2\"}"
                        };
            anotherConfiguration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];

            [communicator receiveConfiguration:configuration];
            [anotherCommunicator receiveConfiguration:anotherConfiguration];
        });

        it(@"should request the ad", ^{
            MMRequest *m1Request = fakeInterstitial.requests[@"M1"];
            [m1Request location] should equal(interstitial.location);

            fakeInterstitial.requests[@"M2"] should_not be_nil;
        });

        context(@"if the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatPreventsLoading); });
        context(@"if the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatTimesOut); });
        itShouldBehaveLike(@"an unavailable ad unit");

        context(@"when the ad arrives", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [anotherDelegate reset_sent_messages];

                [fakeInterstitial fetchCompletionBlock:@"M1"](YES, nil);
                delegate should have_received(@selector(interstitialDidLoadAd:)).with(interstitial);
                anotherDelegate.sent_messages should be_empty;

                [fakeInterstitial fetchCompletionBlock:@"M2"](YES, nil);
                anotherDelegate should have_received(@selector(interstitialDidLoadAd:)).with(anotherIntersitital);
            });

            it(@"should tell the delegate that it has loaded an ad, and it should be ready", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
                interstitial.ready should equal(YES);

                verify_fake_received_selectors(anotherDelegate, @[@"interstitialDidLoadAd:"]);
                anotherIntersitital.ready should equal(YES);
            });

            context(@"if the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
            context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
            itShouldBehaveLike(@"an unavailable ad unit");

            context(@"when the user tries to show the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [anotherDelegate reset_sent_messages];
                    [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];
                    [fakeInterstitial setAvailabilityOfApid:@"M1" to:YES];
                    [fakeInterstitial setAvailabilityOfApid:@"M2" to:YES];

                    [interstitial showFromViewController:presentingController];
                });

                it(@"should instruct Millennial to show the ad", ^{
                    fakeInterstitial.viewControllers[@"M1"] should equal(presentingController);
                    fakeInterstitial.viewControllers[@"M2"] should be_nil;
                });

                sharedExamplesFor(@"a Millennial ad that prevents showing", ^(NSDictionary *sharedContext) {
                    it(@"should not show the interstitial", ^{
                        [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];
                        [fakeInterstitial reset];
                        [interstitial showFromViewController:presentingController];
                        fakeInterstitial.viewControllers[@"M1"] should be_nil;
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                    });
                });

                context(@"if the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
                context(@"if the user tries to show again", ^{ itShouldBehaveLike(@"a Millennial ad that prevents showing"); });
                itShouldBehaveLike(@"an unavailable ad unit");

                context(@"when the ad displays succesfully", ^{
                    beforeEach(^{
                        [fakeInterstitial simulateSuccesfulPresentation:@"M1"];
                    });

                    it(@"should tell the delegate that the ad will and did appear, and it should track an impression", ^{
                        verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
                        interstitial.ready should equal(YES);

                        [fakeInterstitial simulateSuccesfulPresentation:@"M1"];
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);

                        anotherDelegate.sent_messages should be_empty;
                    });

                    context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
                    context(@"if the user tries to show again", ^{ itShouldBehaveLike(@"a Millennial ad that prevents showing"); });
                    itShouldBehaveLike(@"an unavailable ad unit");

                    context(@"and the user taps on the ad", ^{
                        it(@"should track a click (just once)", ^{
                            [fakeInterstitial simulateInterstitialTap];
                            fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should equal(@[configuration]);

                            [fakeInterstitial simulateInterstitialTap];
                            fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should equal(@[configuration]);
                        });
                    });

                    context(@"and the user dismisses the ad", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [fakeInterstitial simulateDismissingAd:@"M1"];
                        });

                        it(@"should tell the delegate, and not be ready", ^{
                            verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:", @"interstitialDidExpire:"]);
                            interstitial.ready should equal(NO);

                            anotherDelegate.sent_messages should be_empty;
                        });

                        context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                        context(@"if the user tries to show again", ^{ itShouldBehaveLike(@"a Millennial ad that prevents showing"); });

                        itShouldBehaveLike(@"an available ad unit");
                    });
                });

                context(@"and fails to display", ^{
                    beforeEach(^{
                        [fakeInterstitial simulateFailedPresentation:@"M1"];
                    });

                    it(@"should expire the ad, not track an impression, and should not be ready", ^{
                        verify_fake_received_selectors(delegate, @[@"interstitialDidExpire:"]);
                        interstitial.ready should equal(NO);
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;

                        anotherDelegate.sent_messages should be_empty;
                    });

                    context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                    context(@"if the user tries to show again", ^{ itShouldBehaveLike(@"a Millennial ad that prevents showing"); });

                    itShouldBehaveLike(@"an available ad unit");
                });
            });

            context(@"when the user tries to show the ad but the ad *somehow* became unready", ^{
                beforeEach(^{
                    [fakeInterstitial setAvailabilityOfApid:@"M1" to:NO]; //mwahaha
                });

                it(@"should think it's still ready! (sad...)", ^{
                    interstitial.ready should equal(YES);
                });

                itShouldBehaveLike(@"an unavailable ad unit");

                context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
                context(@"and the user tries to show the ad", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [interstitial showFromViewController:presentingController];
                    });

                    it(@"should not show the ad, should tell the delegate the ad has expired, should not be ready and should not track an impression", ^{
                        fakeInterstitial.viewControllers should be_empty;
                        verify_fake_received_selectors(delegate, @[@"interstitialDidExpire:"]);
                        interstitial.ready should equal(NO);
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                    });

                    itShouldBehaveLike(@"an available ad unit");

                    context(@"and the user tries to load the ad", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                    context(@"if the user tries to show again", ^{ itShouldBehaveLike(@"a Millennial ad that prevents showing"); });
                });
            });
        });

        context(@"when the ad fails to arrive", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [anotherDelegate reset_sent_messages];

                [fakeInterstitial fetchCompletionBlock:@"M1"](NO, nil);
                [fakeInterstitial fetchCompletionBlock:@"M2"](NO, nil);
                anotherCommunicator.loadedURL should equal(anotherConfiguration.failoverURL);
            });

            itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
            context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
            itShouldBehaveLike(@"an available ad unit");
        });
    });

    context(@"when the user attempts to load two interstitials with the same ad unit (at the same time)", ^{
        __block MMRequest *request;

        beforeEach(^{
            NSDictionary *headers = @{
                                      kInterstitialAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"M1\"}"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];
            configuration.failoverURL = [NSURL URLWithString:@"http://failover/1"];

            headers = @{
                        kInterstitialAdTypeHeaderKey: @"millennial_full",
                        kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"M1\"}"
                        };
            anotherConfiguration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                              HTMLString:nil];
            anotherConfiguration.failoverURL = [NSURL URLWithString:@"http://failover/2"];

            [communicator receiveConfiguration:configuration];
            request = fakeInterstitial.requests[@"M1"];
            [anotherCommunicator receiveConfiguration:anotherConfiguration];
        });

        it(@"should request the interstitial just once", ^{
            fakeInterstitial.requests[@"M1"] should be_same_instance_as(request);
            request.location should equal(interstitial.location);
            communicator.loadedURL should be_nil;

            [fakeInterstitial fetchCompletionBlock:@"M1"](YES, 0);
            delegate should have_received(@selector(interstitialDidLoadAd:));
            anotherDelegate should_not have_received(@selector(interstitialDidLoadAd:));
        });

        it(@"should fast fail the second request", ^{
            anotherCommunicator.loadedURL should equal(anotherConfiguration.failoverURL);
        });
    });

    context(@"when the Millennial apid is not valid", ^{
        beforeEach(^{
            [delegate reset_sent_messages];

            NSDictionary *headers = @{
                                      kInterstitialAdTypeHeaderKey: @"millennial_full"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];

            [communicator receiveConfiguration:configuration];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
    });
});

SPEC_END
