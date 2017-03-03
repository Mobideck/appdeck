#import "MPBannerCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "FakeBannerCustomEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerCustomEventAdapterSpec)

describe(@"MPBannerCustomEventAdapter", ^{
    __block MPBannerCustomEventAdapter *adapter;
    __block id<CedarDouble, MPBannerAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeBannerCustomEvent *event;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerAdapterDelegate));
        adapter = [[MPBannerCustomEventAdapter alloc] initWithDelegate:delegate];
        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
        event = [[FakeBannerCustomEvent alloc] init];
        fakeProvider.fakeBannerCustomEvent = event;
    });

    context(@"when asked to get an ad for a configuration", ^{
        context(@"when the requested custom event class exists", ^{
            beforeEach(^{
                configuration.customEventClassData = @{@"Zoology":@"Is for zoologists"};
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeMake(10,32)];
            });

            it(@"should create a new instance of the class and request the interstitial", ^{
                event.delegate should equal(adapter);
                event.size should equal(CGSizeMake(10,32));
                event.customEventInfo should equal(configuration.customEventClassData);
            });
        });

        context(@"when the requested custom event class does not exist", ^{
            beforeEach(^{
                fakeProvider.fakeBannerCustomEvent = nil;
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"NonExistentCustomEvent"];
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should not create an instance, and should tell its delegate that it failed to load", ^{
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
            });
        });
    });

    context(@"with a valid custom event", ^{
        beforeEach(^{
            [adapter _getAdWithConfiguration:configuration containerSize:CGSizeMake(20, 24)];
        });

        it(@"should make the configuration available", ^{
            adapter.configuration should equal(configuration);
        });

        context(@"when informed of an orientation change", ^{
            it(@"should forward the message to its custom event", ^{
                [adapter rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
                event.orientation should equal(UIInterfaceOrientationLandscapeLeft);
            });
        });

        context(@"when the custom event claims to have loaded", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            context(@"and passes in a non-nil ad", ^{
                it(@"should tell the delegate that the adapter finished loading, and pass on the view", ^{
                    UIView *view = [[UIView alloc] init];
                    [adapter bannerCustomEvent:event didLoadAd:view];
                    delegate should have_received(@selector(adapter:didFinishLoadingAd:)).with(adapter).and_with(view);
                });
            });

            context(@"and passes in a nil ad", ^{
                it(@"should tell the delegate that the adapter *failed* to load", ^{
                    [adapter bannerCustomEvent:event didLoadAd:nil];
                    delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
                });
            });
        });


        context(@"when told that its content has been displayed on-screen", ^{
            context(@"if the custom event has enabled automatic metrics tracking", ^{
                it(@"should track an impression (only once) and forward the message to its custom event", ^{
                    event.enableAutomaticImpressionAndClickTracking = YES;
                    [adapter didDisplayAd];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);
                    event.didDisplay should equal(YES);

                    [adapter didDisplayAd];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
                });
            });

            context(@"if the custom event has disabled automatic metrics tracking", ^{
                it(@"should forward the message to its custom event but *not* track an impression", ^{
                    event.enableAutomaticImpressionAndClickTracking = NO;
                    [adapter didDisplayAd];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                    event.didDisplay should equal(YES);
                });
            });
        });

        context(@"when the custom event is beginning a user action", ^{
            context(@"if the custom event has enabled automatic metrics tracking", ^{
                it(@"should track a click (only once)", ^{
                    event.enableAutomaticImpressionAndClickTracking = YES;
                    [event simulateUserTap];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should contain(configuration);

                    [event simulateUserTap];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                });
            });

            context(@"if the custom event has disabled automatic metrics tracking", ^{
                it(@"should *not* track a click", ^{
                    event.enableAutomaticImpressionAndClickTracking = NO;
                    [event simulateUserTap];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should be_empty;
                });
            });
        });

        describe(@"the adapter timeout", ^{
            context(@"when the custom event successfully loads", ^{
                it(@"should no longer trigger a timeout", ^{
                    [event simulateLoadingAd];
                    [delegate reset_sent_messages];
                    [fakeCoreProvider advanceMPTimers:BANNER_TIMEOUT_INTERVAL];
                    delegate.sent_messages should be_empty;
                });
            });

            context(@"when the custom event fails to load", ^{
                it(@"should invalidate the timer", ^{
                    [event simulateLoadingAd];
                    [delegate reset_sent_messages];
                    [fakeCoreProvider advanceMPTimers:BANNER_TIMEOUT_INTERVAL];
                    delegate.sent_messages should be_empty;
                });
            });
        });

        context(@"when told to unregister", ^{
            it(@"should inform its custom event instance that it is going away", ^{
                [adapter unregisterDelegate];
                event.invalidated should equal(YES);
            });
        });
    });
});

SPEC_END
