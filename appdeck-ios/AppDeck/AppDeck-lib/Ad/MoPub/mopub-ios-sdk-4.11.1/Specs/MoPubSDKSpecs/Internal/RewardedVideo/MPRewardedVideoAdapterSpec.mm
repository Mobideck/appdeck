#import "MPRewardedVideoAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "MPRewardedVideoCustomEvent.h"
#import "MPRewardedVideoAdapter+MPSpecs.h"
#import "MPRewardedVideoReward.h"
#import "MPTimer.h"
#import "MPCoreInstanceProvider.h"
#import "MPRewardedVideoConnection.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface SampleIVCustomEvent : MPRewardedVideoCustomEvent

@end

@implementation SampleIVCustomEvent

- (BOOL)hasAdAvailable
{
    return YES;
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)customEventInfo
{

}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{

}

- (void)handleAdPlayedForCustomEventNetwork
{

}

- (void)handleCustomEventInvalidated
{

}
@end

@interface MPRewardedVideoAdapter()

- (NSTimeInterval)backoffTime:(NSUInteger)retryCount;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@end

SPEC_BEGIN(MPRewardedVideoAdapterSpec)

describe(@"MPRewardedVideoAdapter", ^{
    __block id<MPRewardedVideoAdapterDelegate, CedarDouble> delegate;
    __block MPRewardedVideoAdapter *adapter;
    __block SampleIVCustomEvent *sampleCE;
    __block MPAdConfiguration *adConfiguration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPRewardedVideoAdapterDelegate));
        adapter = [[MPRewardedVideoAdapter alloc] initWithDelegate:delegate];
        sampleCE = [[SampleIVCustomEvent alloc] init];
    });

    describe(@"initialization", ^{
        it(@"should set the delegate correctly", ^{
            adapter.delegate should equal(delegate);
        });
    });

    describe(@"retrieving an ad", ^{
        context(@"when initializing with an invalid custom event class", ^{
            beforeEach(^{
                adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
                adConfiguration.customEventClass = NSClassFromString(@"DontExist");
                [adapter getAdWithConfiguration:adConfiguration];
            });

            it(@"should report a failure to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToLoadForAdapter:error:)).with(adapter).and_with(Arguments::anything);
            });
        });

        context(@"when initializing with a valid custom event class", ^{
            beforeEach(^{
                spy_on(sampleCE);

                fakeProvider.fakeMPRewardedVideoCustomEvent = sampleCE;
                adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
                adConfiguration.customEventClass = NSClassFromString(@"SampleIVCustomEvent");
                [adapter getAdWithConfiguration:adConfiguration];
            });

            it(@"should not report a failure to its delegate", ^{
                delegate should_not have_received(@selector(rewardedVideoDidFailToLoadForAdapter:error:)).with(adapter).and_with(Arguments::anything);
            });

            it(@"should request the rewarded video ad from the custom event", ^{
                sampleCE should have_received(@selector(requestRewardedVideoWithCustomEventInfo:));
            });

            it(@"should not timeout before the default timeout interval", ^{
                [fakeCoreProvider advanceMPTimers:29];
                delegate should_not have_received(@selector(rewardedVideoDidFailToLoadForAdapter:error:));
            });

            it(@"should timeout and tell the delegate using the default timeout interval", ^{
                [fakeCoreProvider advanceMPTimers:30];
                delegate should have_received(@selector(rewardedVideoDidFailToLoadForAdapter:error:));
            });

            context(@"when the request finishes before the timeout", ^{
                beforeEach(^{
                    [fakeCoreProvider advanceMPTimers:29];
                    [adapter rewardedVideoDidLoadAdForCustomEvent:sampleCE];
                });

                it(@"should not, later, fire the timeout", ^{
                    [delegate reset_sent_messages];
                    // due to implementation detail of fake MPTimer advanceTime, only 1 'tick' is required here
                    [fakeCoreProvider advanceMPTimers:1];
                    delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
                });
            });

            describe(@"seeing if an ad is available", ^{
                it(@"should forward the message to the custom event", ^{
                    [adapter hasAdAvailable] should equal(sampleCE.hasAdAvailable);
                    sampleCE should have_received(@selector(hasAdAvailable));
                });
            });

            describe(@"presenting an ad", ^{
                it(@"should forward the message to the custom event", ^{
                    [adapter presentRewardedVideoFromViewController:nil];
                    sampleCE should have_received(@selector(presentRewardedVideoFromViewController:)).with(nil);
                });
            });

            describe(@"when notified that an ad played for the same custom event but under a different ad unit ID", ^{
                it(@"should forward the message to the custom event", ^{
                    [adapter handleAdPlayedForCustomEventNetwork];
                    sampleCE should have_received(@selector(handleAdPlayedForCustomEventNetwork));
                });
            });
        });
    });

    describe(@"delegation", ^{
        describe(@"instanceMediationSettingsForClass:", ^{
            beforeEach(^{
                [adapter instanceMediationSettingsForClass:[NSObject class]];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(instanceMediationSettingsForClass:)).with([NSObject class]);
            });
        });

        describe(@"rewardedVideoDidLoadAdForCustomEvent:", ^{
            beforeEach(^{
                [adapter rewardedVideoDidLoadAdForCustomEvent:sampleCE];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidLoadForAdapter:)).with(adapter);
            });

            it(@"should stop the timeout timer", ^{
                adapter.timeoutTimer.isScheduled should be_falsy;
            });

            it(@"should not report the event to the delegate more than once", ^{
                delegate should have_received(@selector(rewardedVideoDidLoadForAdapter:)).with(adapter);
                [delegate reset_sent_messages];
                [adapter rewardedVideoDidLoadAdForCustomEvent:sampleCE];
                delegate should_not have_received(@selector(rewardedVideoDidLoadForAdapter:));
            });
        });

        describe(@"rewardedVideoDidFailToLoadAdForCustomEvent:error:", ^{
            beforeEach(^{
                fakeProvider.fakeMPRewardedVideoCustomEvent = sampleCE;
                adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
                adConfiguration.customEventClass = NSClassFromString(@"SampleIVCustomEvent");
                [adapter getAdWithConfiguration:adConfiguration];

                spy_on(adapter.rewardedVideoCustomEvent);
                [adapter rewardedVideoDidFailToLoadAdForCustomEvent:sampleCE error:nil];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToLoadForAdapter:error:)).with(adapter).and_with(nil);
            });

            it(@"should stop the timeout timer", ^{
                adapter.timeoutTimer.isScheduled should be_falsy;
            });

            it(@"should detach the custom event", ^{
                adapter.rewardedVideoCustomEvent should be_nil;
                sampleCE should have_received(@selector(handleCustomEventInvalidated));
            });
        });

        describe(@"rewardedVideoDidExpireForCustomEvent:", ^{
            beforeEach(^{
                [adapter rewardedVideoDidExpireForCustomEvent:sampleCE];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidExpireForAdapter:)).with(adapter);
            });

            it(@"should only forward the message to its delegate once", ^{
                delegate should have_received(@selector(rewardedVideoDidExpireForAdapter:)).with(adapter);
                [delegate reset_sent_messages];
                [adapter rewardedVideoDidLoadAdForCustomEvent:sampleCE];
                delegate should_not have_received(@selector(rewardedVideoDidExpireForAdapter:));
            });
        });

        describe(@"rewardedVideoDidFailToPlayForAdapter:", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"domain" code:1 userInfo:nil];
                [adapter rewardedVideoDidFailToPlayForCustomEvent:sampleCE error:error];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToPlayForAdapter:error:)).with(adapter).and_with(error);
            });
        });

        describe(@"rewardedVideoWillAppearForCustomEvent:", ^{
            beforeEach(^{
                [adapter rewardedVideoWillAppearForCustomEvent:sampleCE];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoWillAppearForAdapter:)).with(adapter);
            });
        });

        describe(@"rewardedVideoDidAppearForCustomEvent:", ^{
            beforeEach(^{
                spy_on(adapter);
                fakeProvider.fakeMPRewardedVideoCustomEvent = sampleCE;
                adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
                adConfiguration.customEventClass = NSClassFromString(@"SampleIVCustomEvent");
                [adapter getAdWithConfiguration:adConfiguration];
            });

            it(@"should forward the message to its delegate", ^{
                [adapter rewardedVideoDidAppearForCustomEvent:sampleCE];
                delegate should have_received(@selector(rewardedVideoDidAppearForAdapter:)).with(adapter);
            });

            it(@"should track a impression if automatic tracking is enabled", ^{
                [adapter rewardedVideoDidAppearForCustomEvent:sampleCE];
                adapter should have_received(@selector(trackImpression));
            });

            it(@"should not track impressions twice", ^{
                [adapter rewardedVideoDidAppearForCustomEvent:sampleCE];
                adapter should have_received(@selector(trackImpression));

                [((id<CedarDouble>)adapter) reset_sent_messages];
                [adapter rewardedVideoDidAppearForCustomEvent:sampleCE];
                adapter should_not have_received(@selector(trackImpression));
            });

            it(@"should not track impressions if not allowed to automatically", ^{
                spy_on(sampleCE);
                sampleCE stub_method(@selector(enableAutomaticImpressionAndClickTracking)).and_return(NO);
                [adapter rewardedVideoDidAppearForCustomEvent:sampleCE];
                adapter should_not have_received(@selector(trackImpression));
            });
        });

        describe(@"rewardedVideoWillDisappearForCustomEvent:", ^{
            beforeEach(^{
                [adapter rewardedVideoWillDisappearForCustomEvent:sampleCE];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoWillDisappearForAdapter:)).with(adapter);
            });
        });

        describe(@"rewardedVideoDidDisappearForCustomEvent:", ^{
            beforeEach(^{
                [adapter rewardedVideoDidDisappearForCustomEvent:sampleCE];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidDisappearForAdapter:)).with(adapter);
            });
        });

        describe(@"rewardedVideoWillLeaveApplicationForCustomEvent:", ^{
            beforeEach(^{
                [adapter rewardedVideoWillLeaveApplicationForCustomEvent:sampleCE];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoWillLeaveApplicationForAdapter:)).with(adapter);
            });
        });

        describe(@"rewardedVideoDidReceiveTapEventForCustomEvent:", ^{
            beforeEach(^{
                spy_on(adapter);
                fakeProvider.fakeMPRewardedVideoCustomEvent = sampleCE;
                adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
                adConfiguration.customEventClass = NSClassFromString(@"SampleIVCustomEvent");
                [adapter getAdWithConfiguration:adConfiguration];
            });

            it(@"should forward the message to its delegate", ^{
                [adapter rewardedVideoDidReceiveTapEventForCustomEvent:sampleCE];
                delegate should have_received(@selector(rewardedVideoDidReceiveTapEventForAdapter:)).with(adapter);
            });

            it(@"should track a click if automatic tracking is enabled", ^{
                [adapter rewardedVideoDidReceiveTapEventForCustomEvent:sampleCE];
                adapter should have_received(@selector(trackClick));
            });

            it(@"should not track clicks twice", ^{
                [adapter rewardedVideoDidReceiveTapEventForCustomEvent:sampleCE];
                adapter should have_received(@selector(trackClick));

                [((id<CedarDouble>)adapter) reset_sent_messages];
                [adapter rewardedVideoDidReceiveTapEventForCustomEvent:sampleCE];
                adapter should_not have_received(@selector(trackClick));
            });

            it(@"should not track clicks if not allowed to automatically", ^{
                spy_on(sampleCE);
                sampleCE stub_method(@selector(enableAutomaticImpressionAndClickTracking)).and_return(NO);
                [adapter rewardedVideoDidReceiveTapEventForCustomEvent:sampleCE];
                adapter should_not have_received(@selector(trackClick));
            });
        });

        describe(@"rewardedVideoShouldRewardUserForCustomEvent:", ^{
            __block MPRewardedVideoReward *reward;

            context(@"when configuration doesn't have reward", ^{
                beforeEach(^{
                    reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@99];
                });

                it(@"should forward the message to its delegate", ^{
                    [adapter rewardedVideoShouldRewardUserForCustomEvent:sampleCE reward:reward];
                    delegate should have_received(@selector(rewardedVideoShouldRewardUserForAdapter:reward:)).with(adapter).and_with(reward);
                });

                it(@"should not forward the message to its delegate if the reward is nil", ^{
                    [adapter rewardedVideoShouldRewardUserForCustomEvent:sampleCE reward:nil];
                    delegate should_not have_received(@selector(rewardedVideoShouldRewardUserForAdapter:reward:)).with(adapter).and_with(reward);
                });
            });

            context(@"when configuration have reward", ^{
                beforeEach(^{
                    adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithReward];
                    adConfiguration.customEventClass = NSClassFromString(@"DontExist");
                    [adapter getAdWithConfiguration:adConfiguration];
                    reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@99];
                });

                it(@"should not get reward from adNetwork", ^{
                    [adapter rewardedVideoShouldRewardUserForCustomEvent:sampleCE reward:reward];
                    delegate should_not have_received(@selector(rewardedVideoShouldRewardUserForAdapter:reward:)).with(adapter).and_with(reward);
                });

                it(@"should get reward from configuration", ^{
                    [adapter rewardedVideoShouldRewardUserForCustomEvent:sampleCE reward:reward];
                    delegate should have_received(@selector(rewardedVideoShouldRewardUserForAdapter:reward:)).with(adapter).and_with(adConfiguration.rewardedVideoReward);
                });
            });

            context(@"when reward is server to server", ^{
                beforeEach(^{
                    spy_on(adapter.delegate);
                    adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfigurationServerToServer];
                    [adapter getAdWithConfiguration:adConfiguration];
                    reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@99];
                    [adapter rewardedVideoShouldRewardUserForCustomEvent:sampleCE reward:reward];
                });

                context(@"when rewardedVideoShouldRewardUserForCustomEvent is called", ^{
                    it(@"should not call rewardedVideoShouldRewardUserForAdapter", ^{
                        adapter.delegate should_not have_received(@selector(rewardedVideoShouldRewardUserForAdapter:reward:));
                    });
                });
            });

            context(@"when reward is client side", ^{
                beforeEach(^{
                    spy_on(adapter.delegate);
                    adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
                    [adapter getAdWithConfiguration:adConfiguration];
                    reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@99];
                    [adapter rewardedVideoShouldRewardUserForCustomEvent:sampleCE reward:reward];
                });

                it(@"should not call addRewardedVideoConnectionWithUrl", ^{
                    adapter.delegate should have_received(@selector(rewardedVideoShouldRewardUserForAdapter:reward:));
                });

            });
        });
    });
});

SPEC_END
