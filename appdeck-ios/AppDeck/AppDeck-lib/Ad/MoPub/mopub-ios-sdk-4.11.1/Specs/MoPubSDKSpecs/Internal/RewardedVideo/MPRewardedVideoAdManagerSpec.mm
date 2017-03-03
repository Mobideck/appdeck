#import "MPRewardedVideoAdManager.h"
#import "MPAdConfiguration.h"
#import "MPRewardedVideoAdManager+MPSpecs.h"
#import "MPAdConfigurationFactory.h"
#import "MPRewardedVideoAdapter.h"
#import "MoPub.h"
#import "MPMediationSettingsProtocol+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPRewardedVideoAdManagerSpec)

describe(@"MPRewardedVideoAdManager", ^{
    __block NSString *adUnitID;
    __block MPRewardedVideoAdManager *adManager;
    __block id<MPRewardedVideoAdManagerDelegate> delegate;
    __block MPAdConfiguration *adConfiguration;
    __block MPAdServerCommunicator *lastCommunicator;
    __block MPRewardedVideoAdapter *adapter;

    beforeEach(^{
        adUnitID = @"HollywoodHulkHogan";
        delegate = nice_fake_for(@protocol(MPRewardedVideoAdManagerDelegate));
        adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
        adapter = nice_fake_for([MPRewardedVideoAdapter class]);
        fakeProvider.fakeMPRewardedVideoAdapter = adapter;
        adManager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:adUnitID delegate:delegate];
        lastCommunicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
    });

    describe(@"Initialization", ^{
        it(@"should set its adUnitID to the adUnitID passed in through its init method", ^{
            adManager.adUnitID should equal(adUnitID);
        });

        it(@"should set its delegate to the delegate passed in through its init method", ^{
            adManager.delegate should equal(delegate);
        });
    });

    describe(@"Retrieving the custom event class", ^{
        it(@"should retrieve the class from its underlying ad configuration", ^{
            // Note that NSMutableArray and NSMutableDictionary will never be the custom event class type. We're only doing this to make it
            // easier to test the functionality.
            adConfiguration.customEventClass = [NSMutableArray class];
            [adManager communicatorDidReceiveAdConfiguration:adConfiguration];

            adManager.customEventClass should equal([NSMutableArray class]);

            adConfiguration.customEventClass = [NSMutableDictionary class];
            adManager.customEventClass should equal([NSMutableDictionary class]);
        });
    });

    describe(@"Loading an ad with a successful configuration", ^{
        beforeEach(^{
            // stub out loadURL to just report configuration downloaded.
            spy_on(lastCommunicator);

            lastCommunicator stub_method(@selector(loadURL:)).and_do(^(NSInvocation *inv) {
                [adManager communicatorDidReceiveAdConfiguration:adConfiguration];
            });

            [adManager loadRewardedVideoAdWithKeywords:nil location:nil customerId:@"customerId"];
        });

        it(@"should be loading", ^{
            adManager.loading should be_truthy;
        });

        it(@"should not be ready", ^{
            adManager.ready should be_falsy;
        });

        it(@"should mark the ad as having not been played", ^{
            adManager.playedAd should be_falsy;
        });

        it(@"should forward the downloaded ad configuration to its adapter", ^{
            adapter should have_received(@selector(getAdWithConfiguration:)).with(adConfiguration);
        });

        describe(@"Retrieving availability of the ad", ^{
            context(@"when the ad has not already played", ^{
                beforeEach(^{
                    spy_on(adManager);
                    adManager stub_method(@selector(playedAd)).and_return(NO);
                });

                it(@"should forward the call to the adapter", ^{
                    [adManager hasAdAvailable];
                    adapter should have_received(@selector(hasAdAvailable));
                });
            });

            context(@"when the ad has already played", ^{
                beforeEach(^{
                    spy_on(adManager);
                    adManager stub_method(@selector(playedAd)).and_return(NO);
                });

                it(@"should forward the call to the adapter", ^{
                    [adManager hasAdAvailable];
                    adapter should have_received(@selector(hasAdAvailable));
                });
            });
        });
    });

    describe(@"Failing to retrieve ad configuration", ^{
        beforeEach(^{
            spy_on(lastCommunicator);

            lastCommunicator stub_method(@selector(loadURL:)).and_do(^(NSInvocation *inv) {
                [adManager communicatorDidFailWithError:nil];
            });

            [adManager loadRewardedVideoAdWithKeywords:nil location:nil customerId:nil];
        });

        it(@"should not be loading", ^{
            adManager.loading should be_falsy;
        });

        it(@"should not be ready", ^{
            adManager.ready should be_falsy;
        });

        it(@"should forward the error to its delegate", ^{
            delegate should have_received(@selector(rewardedVideoDidFailToLoadForAdManager:error:));
        });
    });

    describe(@"Loading an ad without a successful configuration", ^{
        beforeEach(^{
            spy_on(lastCommunicator);

            lastCommunicator stub_method(@selector(loadURL:)).and_do(^(NSInvocation *inv) {
                [adManager communicatorDidReceiveAdConfiguration:adConfiguration];
            });
        });

        context(@"when the ad type is clear", ^{
            beforeEach(^{
                adConfiguration = [MPAdConfigurationFactory defaultRewardedVideoConfiguration];
                adConfiguration.networkType = kAdTypeClear;
                [adManager loadRewardedVideoAdWithKeywords:nil location:nil customerId:@"customerId"];
            });

            it(@"should not forward the downloaded ad configuration to its adapter", ^{
                adapter should_not have_received(@selector(getAdWithConfiguration:)).with(adConfiguration);
            });

            it(@"should tell its delegate the ad failed to load", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToLoadForAdManager:error:));
            });

            it(@"should not be loading", ^{
                adManager.loading should be_falsy;
            });

            it(@"should not be ready", ^{
                adManager.ready should be_falsy;
            });
        });

        context(@"when the ad unit is warming up", ^{
            beforeEach(^{
                NSMutableDictionary *headers = [MPAdConfigurationFactory defaultRewardedVideoHeaders];
                [headers setObject:@"1" forKey:@"X-Warmup"];
                adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
                [adManager loadRewardedVideoAdWithKeywords:nil location:nil customerId:@"customerId"];
            });

            it(@"should not forward the downloaded ad configuration to its adapter", ^{
                adapter should_not have_received(@selector(getAdWithConfiguration:)).with(adConfiguration);
            });

            it(@"should tell its delegate the ad failed to load", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToLoadForAdManager:error:));
            });

            it(@"should not be loading", ^{
                adManager.loading should be_falsy;
            });

            it(@"should not be ready", ^{
                adManager.ready should be_falsy;
            });
        });
    });

    describe(@"handling an ad played by a different manager for the same network", ^{
        beforeEach(^{
            [adManager communicatorDidReceiveAdConfiguration:adConfiguration];
        });

        it(@"should pass the message to its adapter if the manager is ready" , ^{
            adManager.ready = YES;
            [adManager handleAdPlayedForCustomEventNetwork];
            adapter should have_received(@selector(handleAdPlayedForCustomEventNetwork));
        });

        it(@"should not pass the message to its adapter if the manager is not ready" , ^{
            adManager.ready = NO;
            [adManager handleAdPlayedForCustomEventNetwork];
            adapter should_not have_received(@selector(handleAdPlayedForCustomEventNetwork));
        });
    });

    describe(@"presenting an ad", ^{
        beforeEach(^{
            [adManager communicatorDidReceiveAdConfiguration:adConfiguration];
        });

        context(@"when the ad has not already played", ^{
            beforeEach(^{
                spy_on(adManager);
                adManager stub_method(@selector(playedAd)).and_return(NO);

                [adManager presentRewardedVideoAdFromViewController:nil];
            });

            it(@"should forward the call to the adapter", ^{
                adapter should have_received(@selector(presentRewardedVideoFromViewController:));
            });
        });

        context(@"when the ad has already played", ^{
            beforeEach(^{
                spy_on(adManager);
                adManager stub_method(@selector(playedAd)).and_return(YES);

                [adManager presentRewardedVideoAdFromViewController:nil];
            });

            it(@"should not forward the call to the adapter", ^{
                adapter should_not have_received(@selector(presentRewardedVideoFromViewController:));
            });

            it(@"should notify its delegate that it failed to play the video", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToPlayForAdManager:error:));
            });
        });
    });

    describe(@"delegate methods", ^{
        describe(@"rewardedVideoDidLoadForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoDidLoadForAdapter:adapter];
            });

            it(@"should forward the call to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidLoadForAdManager:)).with(adManager);
            });

            it(@"should be marked as ready", ^{
                adManager.ready should be_truthy;
            });

            it(@"should not be marked as loading", ^{
                adManager.loading should be_falsy;
            });
        });

        describe(@"rewardedVideoDidFailToLoadForAdapter:", ^{
            beforeEach(^{
                spy_on(adManager);
                adConfiguration.failoverURL = [NSURL URLWithString:@"http://www.hostamania.com"];
                [adManager communicatorDidReceiveAdConfiguration:adConfiguration];
                [adManager rewardedVideoDidFailToLoadForAdapter:adapter error:nil];
            });

            it(@"should attempt to load the failover URL", ^{
                adManager should have_received(@selector(loadAdWithURL:)).with(adConfiguration.failoverURL);
            });

            it(@"should not be marked as ready", ^{
                adManager.ready should be_falsy;
            });

            // This test is harder to test as loadAdWithURL will be called immediately within the callback which modifies the loading state variable.
            xit(@"should not be marked as loading", ^{
                adManager.loading should be_falsy;
            });
        });

        describe(@"rewardedVideoDidExpireForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoDidExpireForAdapter:adapter];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidExpireForAdManager:)).with(adManager);
            });

            it(@"should not be marked as ready", ^{
                adManager.ready should be_falsy;
            });
        });

        describe(@"rewardedVideoWillAppearForAdapter:", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"d" code:3 userInfo:nil];
                [adManager rewardedVideoDidFailToPlayForAdapter:adapter error:error];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToPlayForAdManager:error:)).with(adManager).and_with(error);
            });
        });

        describe(@"rewardedVideoWillAppearForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoWillAppearForAdapter:adapter];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoWillAppearForAdManager:)).with(adManager);
            });
        });

        describe(@"rewardedVideoDidAppearForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoDidAppearForAdapter:adapter];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidAppearForAdManager:)).with(adManager);
            });
        });

        describe(@"rewardedVideoWillDisappearForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoWillDisappearForAdapter:adapter];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoWillDisappearForAdManager:)).with(adManager);
            });
        });

        describe(@"rewardedVideoDidDisappearForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoDidDisappearForAdapter:adapter];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidDisappearForAdManager:)).with(adManager);
            });

            it(@"should not be marked as ready", ^{
                adManager.ready should be_falsy;
            });

            it(@"should mark the ad as having been played", ^{
                adManager.playedAd should be_truthy;
            });
        });

        describe(@"rewardedVideoDidReceiveTapEventForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoDidReceiveTapEventForAdapter:adapter];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidReceiveTapEventForAdManager:)).with(adManager);
            });
        });

        describe(@"rewardedVideoWillLeaveApplicationForAdapter:", ^{
            beforeEach(^{
                [adManager rewardedVideoWillLeaveApplicationForAdapter:adapter];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoWillLeaveApplicationForAdManager:)).with(adManager);
            });
        });

        describe(@"rewardedVideoShouldRewardUserForAdapter:reward:", ^{
            __block MPRewardedVideoReward *reward;

            beforeEach(^{
                reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@30];
                [adManager rewardedVideoShouldRewardUserForAdapter:adapter reward:reward];
            });

            it(@"should forward the message to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoShouldRewardUserForAdManager:reward:)).with(adManager).and_with(reward);
            });
        });
    });
});

SPEC_END
