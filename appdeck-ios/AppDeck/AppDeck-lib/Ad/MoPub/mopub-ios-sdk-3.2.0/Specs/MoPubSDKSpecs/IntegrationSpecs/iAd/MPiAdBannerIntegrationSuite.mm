#import "MPAdView.h"
#import "FakeMPAdServerCommunicator.h"
#import "MPAdConfigurationFactory.h"
#import "FakeADBannerView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(iAdBannerIntegrationSuite)

describe(@"iAdBannerIntegrationSuite", ^{
    __block MPAdView *banner;
    __block id<CedarDouble, MPAdViewDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;
    __block FakeADBannerView *fakeADBannerView;

    beforeEach(^{
        fakeADBannerView = [[FakeADBannerView alloc] initWithFrame:CGRectMake(0,0,30,50)];
        fakeProvider.fakeADBannerView = fakeADBannerView.masquerade;

        delegate = nice_fake_for(@protocol(MPAdViewDelegate));
        banner = [[MPAdView alloc] initWithAdUnitId:@"iAd" size:MOPUB_BANNER_SIZE];
        banner.delegate = delegate;
        [banner loadAd];

        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:@"iAd"];
        configuration.refreshInterval = 20;
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        [communicator receiveConfiguration:configuration];
    });

    it(@"should show nothing, track no impression, and tell no one", ^{
        banner.subviews should be_empty;
        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
        delegate.sent_messages should be_empty;
    });

    context(@"when the iAd fails", ^{
        beforeEach(^{
            [fakeADBannerView simulateFailingToLoad];
        });

        it(@"should do the failover dance", ^{
            communicator.loadedURL should equal(configuration.failoverURL);
        });

        context(@"if it then succeeds", ^{
            beforeEach(^{
                [fakeADBannerView simulateLoadingAd];
            });

            it(@"should show nothing, track no impression, and tell no one", ^{
                banner.subviews should be_empty;
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                delegate.sent_messages should be_empty;
            });
        });
    });

    context(@"when the iAd succeeds", ^{
        __block FakeMPTimer *refreshTimer;

        beforeEach(^{
            [fakeADBannerView simulateLoadingAd];
            refreshTimer = [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
        });

        it(@"should show the ad, track an impression, tell the delegate, and start the refresh timer", ^{
            banner.subviews.lastObject should equal(fakeADBannerView);
            fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);
            fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            delegate should have_received(@selector(adViewDidLoadAd:)).with(banner);
            refreshTimer.isScheduled should equal(YES);
        });

        context(@"when informed of an orientation change", ^{
            it(@"should use the proper content size identifier for that orientation", ^{
                [banner rotateToOrientation:UIInterfaceOrientationPortrait];
                fakeADBannerView.currentContentSizeIdentifier should equal(ADBannerContentSizeIdentifierPortrait);

                [banner rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
                fakeADBannerView.currentContentSizeIdentifier should equal(ADBannerContentSizeIdentifierLandscape);

                [banner rotateToOrientation:UIInterfaceOrientationPortraitUpsideDown];
                fakeADBannerView.currentContentSizeIdentifier should equal(ADBannerContentSizeIdentifierPortrait);

                [banner rotateToOrientation:UIInterfaceOrientationLandscapeRight];
                fakeADBannerView.currentContentSizeIdentifier should equal(ADBannerContentSizeIdentifierLandscape);
            });
        });

        context(@"when the user interacts with the ad", ^{
            beforeEach(^{
                [fakeADBannerView simulateUserInteraction];
            });

            it(@"should track a click and tell the delegate (just once)", ^{
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should contain(configuration);
                delegate should have_received(@selector(willPresentModalViewForAd:)).with(banner);

                [fakeADBannerView simulateUserInteraction];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
            });

            context(@"when the user then dismisses the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeADBannerView simulateUserDismissingAd];
                });

                it(@"should tell the delegate", ^{
                    delegate should have_received(@selector(didDismissModalViewForAd:)).with(banner);
                });

                context(@"and a new iAd appears that the user then taps", ^{
                    beforeEach(^{
                        [fakeADBannerView simulateLoadingAd];
                        [fakeADBannerView simulateUserInteraction];
                    });

                    it(@"should track the new click", ^{
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(2);
                    });
                });
            });
        });

        context(@"when the user interacts with the ad, which results in leaving the application", ^{
            it(@"should track a click and tell the delegate", ^{
                [delegate reset_sent_messages];
                [fakeADBannerView simulateUserLeavingApplication];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should contain(configuration);
                verify_fake_received_selectors(delegate, @[@"willLeaveApplicationFromAd:"]);
            });
        });

        context(@"the iAd singleton view hits its next refresh point", ^{
            context(@"and succeeds", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];
                    [fakeADBannerView simulateLoadingAd];
                });

                it(@"should still be visible, track an impression, and *not* tell the delegate, and not restart the refresh timer", ^{
                    banner.subviews.lastObject should equal(fakeADBannerView);
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);
                    delegate should_not have_received(@selector(adViewDidLoadAd:));
                    refreshTimer.isValid should equal(YES);
                });
            });

            context(@"and fails", ^{
                beforeEach(^{
                    [communicator resetLoadedURL];
                    [delegate reset_sent_messages];
                    [fakeADBannerView simulateFailingToLoad];
                });

                it(@"should remove the ad view, start loading a new ad, and tell the delegate that it failed", ^{
                    banner.subviews should be_empty;
                    communicator.loadedURL.absoluteString should contain(@"iAd");
                    delegate should have_received(@selector(adViewDidFailToLoadAd:)).with(banner);
                });

                context(@"and subsequently succeeds", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];
                        [fakeADBannerView simulateLoadingAd];
                    });

                    it(@"should show nothing, track no impression, and tell no one", ^{
                        banner.subviews should be_empty;
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                        delegate.sent_messages should be_empty;
                    });
                });
            });
        });

        context(@"(regression test) when the refresh timer fires while the user is playing with the ad", ^{
            beforeEach(^{
                [fakeADBannerView simulateUserInteraction];
                [fakeCoreProvider advanceMPTimers:configuration.refreshInterval];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should not blow up", ^{
                [fakeADBannerView simulateUserDismissingAd]; //was mutating a set while enumerating it
            });
        });

        // iAD queues up its failure/success messages while presenting a modal
        // when the modal is finally dismissed, these failure messages come through *before* the
        // modal dismissal message comes through
        // we need to make sure future requests succeed

        context(@"(regression test) when iAd indicates failure immediately upon dismissing its modal content", ^{
            beforeEach(^{
                [fakeADBannerView simulateUserInteraction];
                [fakeCoreProvider advanceMPTimers:configuration.refreshInterval];
                [communicator receiveConfiguration:configuration];
                [delegate reset_sent_messages];
                [fakeADBannerView simulateFailingToLoad];
                [fakeADBannerView simulateUserDismissingAd];
            });

            it(@"should tell the delegate the user action did finish", ^{
                delegate should have_received(@selector(didDismissModalViewForAd:)).with(banner);
            });

            it(@"should be able to load a new ad", ^{
                [banner loadAd];
                [communicator receiveConfiguration:configuration];
                [fakeADBannerView simulateLoadingAd];
                banner.subviews.lastObject should equal(fakeADBannerView);
            });
        });

        context(@"when our refresh timer fires", ^{
            __block MPAdConfiguration *anotherConfiguration;

            beforeEach(^{
                [delegate reset_sent_messages];
                [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];
                anotherConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:@"iAd"];
                anotherConfiguration.failoverURL = [NSURL URLWithString:@"http://failover2"];

                [fakeCoreProvider advanceMPTimers:configuration.refreshInterval];
            });

            context(@"and then the iAd configuration arrives", ^{
                beforeEach(^{
                    [communicator receiveConfiguration:anotherConfiguration];
                });

                it(@"should immediately be visible, *not* track an impression, and tell the delegate, and start the refresh timer", ^{
                    banner.subviews.lastObject should equal(fakeADBannerView);
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                    delegate should have_received(@selector(adViewDidLoadAd:)).with(banner);
                    [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)].isValid should equal(YES);
                });
            });

            context(@"the iAd singleton view hits its next refresh point before the next iAd configuration arrives", ^{
                context(@"and succeeds", ^{
                    beforeEach(^{
                        [fakeADBannerView simulateLoadingAd];
                    });

                    it(@"should track an impression, *not* tell the delegate, not start the refresh timer, and leave the communicator alone", ^{
                        banner.subviews.lastObject should equal(fakeADBannerView);
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);
                        delegate should_not have_received(@selector(adViewDidLoadAd:));
                        [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)].isValid should equal(NO);
                    });

                    context(@"and then the iAd configuration arrives", ^{
                        beforeEach(^{
                            [communicator receiveConfiguration:anotherConfiguration];
                        });

                        it(@"should immediately be visible, should *not* track an impression, should tell the delegate, and should start the timer again", ^{
                            banner.subviews.lastObject should equal(fakeADBannerView);
                            fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should_not contain(anotherConfiguration);
                            delegate should have_received(@selector(adViewDidLoadAd:)).with(banner);
                            [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)].isValid should equal(YES);
                        });
                    });
                });

                context(@"and fails", ^{
                    __block NSURL *originalURL;
                    beforeEach(^{
                        originalURL = communicator.loadedURL;
                        [fakeADBannerView simulateFailingToLoad];
                    });

                    it(@"should remove the ad view, and tell the delegate that it failed", ^{
                        banner.subviews should be_empty;
                        delegate should have_received(@selector(adViewDidFailToLoadAd:)).with(banner);
                        communicator.loadedURL should be_same_instance_as(originalURL);
                    });

                    context(@"and then the iAd configuration arrives", ^{
                        beforeEach(^{
                            [communicator receiveConfiguration:anotherConfiguration];
                        });

                        context(@"and subsequently succeeds", ^{
                            beforeEach(^{
                                [delegate reset_sent_messages];
                                [fakeADBannerView simulateLoadingAd];
                                refreshTimer = [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                            });


                            it(@"should show the ad, track an impression, tell the delegate, and start the refresh timer", ^{
                                banner.subviews.lastObject should equal(fakeADBannerView);
                                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(anotherConfiguration);
                                delegate should have_received(@selector(adViewDidLoadAd:)).with(banner);
                                refreshTimer.isScheduled should equal(YES);
                            });
                        });

                        context(@"and subsequently fails", ^{
                            beforeEach(^{
                                [delegate reset_sent_messages];
                                [fakeADBannerView simulateFailingToLoad];
                            });

                            it(@"should start the failover dance (instead of loading a new ad)", ^{
                                communicator.loadedURL should equal(anotherConfiguration.failoverURL);
                            });
                        });
                    });

                    context(@"and subsequently succeeds", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];
                            [fakeADBannerView simulateLoadingAd];
                        });

                        context(@"and then the iAd configuration arrives", ^{
                            beforeEach(^{
                                [communicator receiveConfiguration:anotherConfiguration];
                            });

                            it(@"should immediately be visible, should track an impression, should tell the delegate, and should start the timer again", ^{
                                banner.subviews.lastObject should equal(fakeADBannerView);
                                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(anotherConfiguration);
                                delegate should have_received(@selector(adViewDidLoadAd:)).with(banner);
                                [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)].isValid should equal(YES);
                            });
                        });
                    });
                });
            });
        });
    });
});

SPEC_END
