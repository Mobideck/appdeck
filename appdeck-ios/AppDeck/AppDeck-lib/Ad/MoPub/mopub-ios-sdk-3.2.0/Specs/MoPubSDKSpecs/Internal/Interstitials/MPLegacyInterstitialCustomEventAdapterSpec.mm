#import "MPLegacyInterstitialCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol BobTheBuilderProtocol <NSObject>
- (void)buildGuy:(MPInterstitialAdController *)controller;
@end

@protocol VerilyBobTheBuilderProtocol <BobTheBuilderProtocol>
- (void)buildGuy;
@end

SPEC_BEGIN(MPLegacyInterstitialCustomEventAdapterSpec)

describe(@"MPLegacyInterstitialCustomEventAdapter", ^{
    __block MPLegacyInterstitialCustomEventAdapter *adapter;
    __block id<CedarDouble, MPInterstitialAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialAdapterDelegate));
        adapter = [[MPLegacyInterstitialCustomEventAdapter alloc] initWithDelegate:delegate];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
        configuration.customEventClass = nil;
        configuration.customSelectorName = @"buildGuy";
    });

    context(@"when asked to get an ad for a configuration", ^{
        context(@"when the interstitial delegate implements the zero-argument selector", ^{
            __block id<CedarDouble, VerilyBobTheBuilderProtocol> bob;
            beforeEach(^{
                bob = nice_fake_for(@protocol(VerilyBobTheBuilderProtocol));
                delegate stub_method("interstitialDelegate").and_return(bob);
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should perform the selector on the interstitial delegate", ^{
                bob should have_received(@selector(buildGuy));
            });
        });

        context(@"when the interstitial delegate implements the one-argument selector", ^{
            __block id<CedarDouble, BobTheBuilderProtocol> bob;
            beforeEach(^{
                bob = nice_fake_for(@protocol(BobTheBuilderProtocol));
                delegate stub_method("interstitialDelegate").and_return(bob);
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should perform the selector on the interstitial delegate", ^{
                NSObject *controllerProxy = [[NSObject alloc] init];
                delegate stub_method("interstitialAdController").and_return(controllerProxy);

                [adapter _getAdWithConfiguration:configuration];

                bob should have_received(@selector(buildGuy:)).with(controllerProxy);
            });
        });

        context(@"when the interstitial delegate does not implement the selector", ^{
            beforeEach(^{
                NSObject *cake = [[NSObject alloc] init];

                delegate stub_method("interstitialDelegate").and_return(cake);
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should tell the delegate that it failed", ^{
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
            });
        });
    });

    context(@"with a valid ad", ^{
        beforeEach(^{
            id<CedarDouble, VerilyBobTheBuilderProtocol> bob = nice_fake_for(@protocol(VerilyBobTheBuilderProtocol));
            delegate stub_method("interstitialDelegate").and_return(bob);
            [adapter _getAdWithConfiguration:configuration];
        });

        context(@"when told that the legacy custom event did load an ad", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [adapter customEventDidLoadAd];
            });

            it(@"should log an impression (only once)", ^{
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);

                [adapter customEventDidLoadAd];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });

            it(@"should not tell its delegate anything", ^{
                delegate.sent_messages should be_empty;
            });
        });

        context(@"when told that the legacy custom event failed to load", ^{
            beforeEach(^{
                [adapter customEventDidFailToLoadAd];
            });

            it(@"should tell its delegate", ^{
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
            });
        });

        context(@"when told that the legacy custom event ad was clicked", ^{
            it(@"should track a click (only once)", ^{
                [adapter customEventActionWillBegin];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should contain(configuration);

                [adapter customEventActionWillBegin];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
            });
        });
    });

    describe(@"the adapter timeout", ^{
        beforeEach(^{
            id<CedarDouble, VerilyBobTheBuilderProtocol> bob = nice_fake_for(@protocol(VerilyBobTheBuilderProtocol));
            delegate stub_method("interstitialDelegate").and_return(bob);
            [adapter _getAdWithConfiguration:configuration];
        });

        context(@"when the custom event successfully loads", ^{
            it(@"should no longer trigger a timeout", ^{
                [adapter customEventDidLoadAd];
                [delegate reset_sent_messages];
                [fakeCoreProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL];
                delegate.sent_messages should be_empty;
            });
        });

        context(@"when the custom event fails to load", ^{
            it(@"should invalidate the timer", ^{
                [adapter customEventDidFailToLoadAd];
                [delegate reset_sent_messages];
                [fakeCoreProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL];
                delegate.sent_messages should be_empty;
            });
        });
    });
});

SPEC_END
