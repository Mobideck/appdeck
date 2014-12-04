#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
#import "FakeGADBannerView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol FakeLegacyBannerCustomEvent <MPAdViewDelegate>
- (void)legacyMethod:(MPAdView *)banner;
@end

SPEC_BEGIN(MPLegacyCustomEventBannerIntegrationSuite)

describe(@"MPLegacyCustomEventBannerIntegrationSuite", ^{
    __block id<FakeLegacyBannerCustomEvent, CedarDouble> delegate;
    __block MPAdView *banner;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    __block FakeGADBannerView *admob;
    __block MPAdConfiguration *admobConfiguration;


    beforeEach(^{
        delegate = nice_fake_for(@protocol(FakeLegacyBannerCustomEvent));

        admob = [[FakeGADBannerView alloc] initWithFrame:CGRectMake(0,0,20,30)];
        fakeProvider.fakeGADBannerView = admob.masquerade;

        NSDictionary *admobHeaders = @{kAdTypeHeaderKey: @"admob_native",
                                  kNativeSDKParametersHeaderKey:@"{\"adUnitID\":\"g00g1e\",\"adWidth\":728,\"adHeight\":90}"};
        admobConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:admobHeaders
                                                                                  HTMLString:nil];


        NSDictionary *headers = @{
                                  kCustomSelectorHeaderKey: @"legacyMethod",
                                  kAdTypeHeaderKey: @"custom"
                                  };
        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:headers HTMLString:nil];
        configuration.refreshInterval = 30;

        banner = [[MPAdView alloc] initWithAdUnitId:@"legacy_custom_event_banner" size:CGSizeMake(50, 50)];
        banner.delegate = delegate;
        [banner loadAd];

        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"legacy_custom_event_banner");

        [communicator receiveConfiguration:admobConfiguration];
    });

    context(@"when a non-legacy custom event is loading", ^{
        context(@"and the developer calls any of the legacy custom event methods", ^{
            it(@"should ignore the call", ^{
                [communicator resetLoadedURL];
                [delegate reset_sent_messages];
                [banner customEventDidLoadAd];
                [banner customEventDidFailToLoadAd];
                [banner customEventActionWillBegin];
                [banner customEventActionDidEnd];

                communicator.loadedURL should be_nil;
                delegate.sent_messages should be_empty;
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should be_empty;
            });
        });
    });

    context(@"when a non-legacy custom event on screen", ^{
        beforeEach(^{
            [admob simulateLoadingAd];
        });

        context(@"and the developer calls any of the legacy custom event methods", ^{
            it(@"should ignore the call", ^{
                [communicator resetLoadedURL];
                [delegate reset_sent_messages];
                [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];

                [banner customEventDidLoadAd];
                [banner customEventDidFailToLoadAd];
                [banner customEventActionWillBegin];
                [banner customEventActionDidEnd];

                communicator.loadedURL should be_nil;
                delegate.sent_messages should be_empty;
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should be_empty;
            });
        });

        context(@"when loading a legacy custom event", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [banner loadAd];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should call the custom selector on the ad view delegate", ^{
                verify_fake_received_selectors(delegate, @[@"legacyMethod:"]);
            });

            it(@"should prevent subsequent loads", ^{
                [communicator resetLoadedURL];
                [banner loadAd];
                communicator.loadedURL should be_nil;
            });

            context(@"when the developer calls -customEventDidLoadAd", ^{
                __block UIView *customEventView;
                beforeEach(^{
                    customEventView = [[UIView alloc] init];
                    [delegate reset_sent_messages];
                    [banner setAdContentView:customEventView];
                    [banner customEventDidLoadAd];
                });

                it(@"should not have a timeout timer", ^{
                    [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(timeout)] should be_nil;
                });

                it(@"should allow subsequent loads", ^{
                    [communicator resetLoadedURL];
                    [banner loadAd];
                    communicator.loadedURL.absoluteString should contain(@"legacy_custom_event_banner");
                });

                it(@"should track an impression", ^{
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);
                });

                it(@"should schedule a refresh timer", ^{
                    [communicator resetLoadedURL];
                    [fakeCoreProvider advanceMPTimers:30];
                    communicator.loadedURL.absoluteString should contain(@"legacy_custom_event_banner");
                });

                it(@"should not tell the delegate", ^{
                    delegate.sent_messages should be_empty;
                });

                it(@"should ignore any callbacks from the previous onscreen adapter", ^{
                    [admob simulateUserTap];
                    delegate.sent_messages should be_empty;
                });

                context(@"when the developer calls -customEventActionWillBegin", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [banner customEventActionWillBegin];

                        //imagine, now, that a background ad loads
                        [fakeCoreProvider advanceMPTimers:30];
                        [communicator receiveConfiguration:admobConfiguration];
                        [admob simulateLoadingAd];
                    });

                    it(@"should track a click", ^{
                        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should contain(configuration);
                    });

                    it(@"should tell the delegate", ^{
                        delegate should have_received(@selector(willPresentModalViewForAd:)).with(banner);
                    });

                    it(@"should prevent the background ad from presenting", ^{
                        delegate should_not have_received(@selector(adViewDidLoadAd:)).with(banner);
                        banner.subviews.lastObject should equal(customEventView);
                    });

                    context(@"when the developer calls -customEventActionDidEnd", ^{
                        beforeEach(^{
                            [banner customEventActionDidEnd];
                        });

                        it(@"should tell the delegate", ^{
                            delegate should have_received(@selector(didDismissModalViewForAd:)).with(banner);
                        });

                        it(@"should allow the background ad (or future ads) to be presented", ^{
                            delegate should have_received(@selector(adViewDidLoadAd:)).with(banner);
                            banner.subviews.lastObject should equal(admob);
                        });
                    });
                });
            });

            context(@"when the developer calls -customEventDidFailToLoadAd", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [communicator resetLoadedURL];
                    [banner customEventDidFailToLoadAd];
                });

                it(@"should fail over", ^{
                    communicator.loadedURL should equal(configuration.failoverURL);
                });
            });
        });
    });
});

SPEC_END
