#import "MPInterstitialCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "FakeInterstitialCustomEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialCustomEventAdapterSpec)

describe(@"MPInterstitialCustomEventAdapter", ^{
    __block MPInterstitialCustomEventAdapter *adapter;
    __block id<CedarDouble, MPInterstitialAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeInterstitialCustomEvent *event;

    beforeEach(^{
        event = [[FakeInterstitialCustomEvent alloc] init];
        fakeProvider.fakeInterstitialCustomEvent = event;

        delegate = nice_fake_for(@protocol(MPInterstitialAdapterDelegate));
        adapter = [[MPInterstitialCustomEventAdapter alloc] initWithDelegate:delegate];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];
    });

    context(@"when asked to get an ad for a configuration", ^{
        context(@"when the requested custom event class exists", ^{
            beforeEach(^{
                configuration.customEventClassData = @{@"Zoology":@"Is for zoologists"};
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should create a new instance of the class and request the interstitial", ^{
                event.delegate should equal(adapter);
                event.customEventInfo should equal(configuration.customEventClassData);
            });
        });

        context(@"when the requested custom event class does not exist", ^{
            beforeEach(^{
                fakeProvider.fakeInterstitialCustomEvent = nil;
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"NonExistentCustomEvent"];
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should not create an instance, and should tell its delegate that it failed to load", ^{
                event.delegate should be_nil;
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
            });
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *controller;

        beforeEach(^{
            [adapter _getAdWithConfiguration:configuration];
            controller = [[UIViewController alloc] init];
            [adapter showInterstitialFromViewController:controller];
        });

        it(@"should ask the custom event class", ^{
            event.presentingViewController should equal(controller);
        });
    });

    context(@"when told that the interstitial has appeared", ^{
        beforeEach(^{
            [adapter _getAdWithConfiguration:configuration];

            UIViewController *controller = [[UIViewController alloc] init];

            [adapter showInterstitialFromViewController:controller];
        });

        context(@"if the custom event has enabled automatic metrics tracking", ^{
            it(@"should track an impression (only once) and forward the message to its custom event", ^{
                event.enableAutomaticImpressionAndClickTracking = YES;
                [event simulateInterstitialFinishedAppearing];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);

                [event simulateInterstitialFinishedAppearing];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });
        });

        context(@"if the custom event has disabled automatic metrics tracking", ^{
            it(@"should forward the message to its custom event but *not* track an impression", ^{
                event.enableAutomaticImpressionAndClickTracking = NO;
                [event simulateInterstitialFinishedAppearing];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
            });
        });
    });

    context(@"when the custom event is beginning a user action", ^{
        beforeEach(^{
            [adapter _getAdWithConfiguration:configuration];
        });

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
        beforeEach(^{
            [adapter _getAdWithConfiguration:configuration];
        });

        context(@"when the custom event successfully loads", ^{
            it(@"should no longer trigger a timeout", ^{
                [event simulateLoadingAd];
                [delegate reset_sent_messages];
                [fakeCoreProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL];
                delegate.sent_messages should be_empty;
            });
        });

        context(@"when the custom event fails to load", ^{
            it(@"should invalidate the timer", ^{
                [event simulateLoadingAd];
                [delegate reset_sent_messages];
                [fakeCoreProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL];
                delegate.sent_messages should be_empty;
            });
        });
    });
});

SPEC_END
