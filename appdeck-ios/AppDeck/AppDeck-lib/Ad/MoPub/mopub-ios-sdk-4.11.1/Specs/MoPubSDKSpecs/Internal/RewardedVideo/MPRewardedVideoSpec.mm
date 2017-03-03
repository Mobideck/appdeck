#import "MPRewardedVideo.h"
#import "MoPub.h"
#import "MPMediationSettingsProtocol.h"
#import "MPRewardedVideo+MPSpecs.h"
#import "MPRewardedVideoAdManager.h"
#import "FakeMPCoreInstanceProvider.h"
#import "MPInternalUtils.h"
#import "MPMediationSettingsProtocol+MPSpecs.h"
#import "MPRewardedVideoAdManager+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPRewardedVideoSpec)

describe(@"RewardedVideo", ^{
    __block id<MPRewardedVideoDelegate, CedarDouble> delegate;
    __block TestMediationSetting1 *mediationSetting1;
    __block TestMediationSetting2 *mediationSetting2;
    __block NSArray *mediationSettings;
    __block NSMutableDictionary *adManagers;
    __block MPRewardedVideoAdManager<CedarDouble> *fakeAdManager;
    __block NSString *adUnitID;

    beforeEach(^{
        adUnitID = @"JimRoss";
        delegate = nice_fake_for(@protocol(MPRewardedVideoDelegate));
        mediationSetting1 = [[TestMediationSetting1 alloc] init];
        mediationSetting2 = [[TestMediationSetting2 alloc] init];

        mediationSettings = @[mediationSetting1, mediationSetting2];

        fakeAdManager = nice_fake_for([MPRewardedVideoAdManager class]);
        fakeProvider.fakeMPRewardedVideoAdManager = fakeAdManager;
        [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:mediationSettings delegate:delegate];
        adManagers = [MPRewardedVideo sharedInstance].rewardedVideoAdManagers;
    });

    afterEach(^{
        // Kind of hacky, but just clear out the ad managers after each test so we can start with a fresh (while retaining the delegate)
        // rewarded video system for each test.
        [adManagers removeAllObjects];
    });

    context(@"when initializing rewarded video", ^{
        it(@"should set rewarded video's delegate to the delegate it was initialized with", ^{
            [MPRewardedVideo sharedInstance].delegate should equal(delegate);
        });

        context(@"when attempting to initialize rewarded video again", ^{
            it(@"should not change the delegate", ^{
                __block id<MPRewardedVideoDelegate, CedarDouble> delegate2;
                delegate2 = nice_fake_for(@protocol(MPRewardedVideoDelegate));

                [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:mediationSettings delegate:delegate2];
                [MPRewardedVideo sharedInstance].delegate should_not equal(delegate2);
                [MPRewardedVideo sharedInstance].delegate should equal(delegate);
            });
        });
    });

    context(@"mediation settings", ^{
        it(@"should be able to retrieve global mediation settings from the MoPub object", ^{
            [[MoPub sharedInstance] globalMediationSettingsForClass:[TestMediationSetting1 class]] should equal(mediationSetting1);
            [[MoPub sharedInstance] globalMediationSettingsForClass:[TestMediationSetting2 class]] should equal(mediationSetting2);
        });

        it(@"should return nil when no mediation settings class matches the class passed in", ^{
            [[MoPub sharedInstance] globalMediationSettingsForClass:[TestMediationSetting3 class]] should be_nil;
        });
    });

    context(@"when loading a rewarded ad", ^{
        context(@"when loading with a nil ad unit id", ^{
            beforeEach(^{
                [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:nil withMediationSettings:nil];
            });

            it(@"should tell the delegate it couldn't load an ad", ^{
                delegate should have_received(@selector(rewardedVideoAdDidFailToLoadForAdUnitID:error:));
            });

            it(@"should not forward the call the the underlying ad manager", ^{
                fakeAdManager should_not have_received(@selector(loadRewardedVideoAd));
            });
        });

        context(@"when loading with an empty ad unit id", ^{
            beforeEach(^{
                [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:@"" withMediationSettings:nil];
            });

            it(@"should tell the delegate it couldn't load an ad", ^{
                delegate should have_received(@selector(rewardedVideoAdDidFailToLoadForAdUnitID:error:));
            });

            it(@"should not forward the call the the underlying ad manager", ^{
                fakeAdManager should_not have_received(@selector(loadRewardedVideoAd));
            });
        });

        it(@"should create an ad manager for the given ad unit ID if a manager doesn't already exist", ^{
            fakeProvider.fakeMPRewardedVideoAdManager = nil;

            adManagers[adUnitID] should be_nil;
            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:nil];
            adManagers[adUnitID] should_not be_nil;
        });

        it(@"should not create another ad manager for the given ad unit ID if the manager already exists", ^{
            fakeProvider.fakeMPRewardedVideoAdManager = nil;

            // Create a manager for the given ad unit ID and capture the manager in a variable to test whether it changed or not
            // after a second load call.
            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:nil];
            MPRewardedVideoAdManager *manager = adManagers[adUnitID];

            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:nil];
            manager should equal(adManagers[adUnitID]);
        });

        it(@"should forward the load call to the underlying ad manager", ^{
            fakeAdManager should_not have_received(@selector(loadRewardedVideoAd));

            // Make sure consecutive load calls are forwarded to the ad manager.
            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:nil];
            fakeAdManager should have_received(@selector(loadRewardedVideoAdWithKeywords:location:customerId:));
            [fakeAdManager reset_sent_messages];

            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:nil];
            fakeAdManager should have_received(@selector(loadRewardedVideoAdWithKeywords:location:customerId:));
        });

        describe(@"loading with mediation settings", ^{
            __block TestMediationSetting1 *setting1;
            __block TestMediationSetting2 *setting2;
            __block MPRewardedVideoAdManager *adManager;

            beforeEach(^{
                fakeProvider.fakeMPRewardedVideoAdManager = nil;
                // Just passing basic types for mediation settings makes testing easier.
                setting1 = [[TestMediationSetting1 alloc] init];
                setting2 = [[TestMediationSetting2 alloc] init];

                [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:@[setting1, setting2]];
                adManager = adManagers[adUnitID];
            });

            it(@"should retrieve the correct mediation settings", ^{
                [adManager instanceMediationSettingsForClass:[TestMediationSetting1 class]] should equal(setting1);
                [adManager instanceMediationSettingsForClass:[TestMediationSetting2 class]] should equal(setting2);
            });

            it(@"should return nil when no mediation settings exist for the query", ^{
                // Give mediation settings for TestMediationSetting3 to a different ad unit ID
                TestMediationSetting3 *setting3 = [[TestMediationSetting3 alloc] init];
                [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:@"diffAdUnitID" withMediationSettings:@[setting3]];
                [adManager instanceMediationSettingsForClass:[TestMediationSetting3 class]] should be_nil;
            });
        });
    });

    context(@"when checking for ad availability", ^{
        it(@"should forward the hasAdAvailable message to underlying ad manager", ^{
            MPRewardedVideoAdManager<CedarDouble> *fakeAdManager = nice_fake_for([MPRewardedVideoAdManager class]);
            fakeProvider.fakeMPRewardedVideoAdManager = fakeAdManager;

            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:nil];
            [MPRewardedVideo hasAdAvailableForAdUnitID:adUnitID] should be_falsy;

            fakeAdManager stub_method(@selector(hasAdAvailable)).and_return(YES);
            [MPRewardedVideo hasAdAvailableForAdUnitID:adUnitID] should be_truthy;

            fakeAdManager should have_received(@selector(hasAdAvailable));
        });
    });

    context(@"when presenting a rewarded video ad", ^{
        __block UIViewController *viewController;

        beforeEach(^{
            viewController = nice_fake_for([UIViewController class]);
            [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:adUnitID withMediationSettings:nil];
        });

        context(@"when trying to present with a nil view controller", ^{
            it(@"should not forward the presentation call to the underlying ad manager", ^{
                [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitID fromViewController:nil];
                fakeAdManager should_not have_received(@selector(presentRewardedVideoAdFromViewController:));
            });
        });

        context(@"when trying to present with a valid view controller", ^{
            it(@"should forward the presentation message to the ad manager", ^{
                [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitID fromViewController:viewController];
                fakeAdManager should have_received(@selector(presentRewardedVideoAdFromViewController:)).with(viewController);
            });
        });
    });

    context(@"MPRewardedVideoAdManagerDelegate", ^{
        // Shared example constants.
        NSString *const kMPRewardedVideoDelegateMethod = @"MPRewardedVideoDelegateMethod";
        NSString *const kRewardedVideoDelegateMethodNameKey = @"ivDelegateMethod";
        NSString *const kAdManagerDelegateMethodNameKey = @"adManagerDelegateMethod";
        NSString *const kAdManagerKey = @"ivAdManager";

        sharedExamplesFor(kMPRewardedVideoDelegateMethod, ^(NSDictionary *sharedContext) {
            // The selector that the delegate of MPRewardedVideo may implement.
            __block SEL ivDelegateMethod;
            __block MPRewardedVideoAdManager *adManager;
            __block SEL adManagerDelegateMethod;

            beforeEach(^{
                ivDelegateMethod = NSSelectorFromString(sharedContext[kRewardedVideoDelegateMethodNameKey]);
                adManagerDelegateMethod = NSSelectorFromString(sharedContext[kAdManagerDelegateMethodNameKey]);
                adManager = sharedContext[kAdManagerKey];
            });

            it(@"should forward the method to the rewarded video's delegate if the delegate responds to the method", ^{
                delegate stub_method(ivDelegateMethod).and_do(^(NSInvocation *inv) { });

                // Perform the ad manager's delegate method on rewarded video
                SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([[MPRewardedVideo sharedInstance] performSelector:adManagerDelegateMethod withObject:adManager]);

                delegate should have_received(ivDelegateMethod).with(fakeAdManager.adUnitID);
            });

            it(@"should not throw an exception (from trying to forward the delegate call to its (rewarded video) delegate)", ^{
                ^{
                    // Hacky solution to get around the fact that we set the delegate on initialization and do not allow changing it afterward.
                    // We'll go ahead and set the delegate to an object that doesn't respond to any of the selectors here and then set it back to the original delegate.
                    [MPRewardedVideo sharedInstance].delegate = (id<MPRewardedVideoDelegate>)[[NSObject alloc] init];

                    SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([[MPRewardedVideo sharedInstance] performSelector:adManagerDelegateMethod withObject:adManager]);

                    [MPRewardedVideo sharedInstance].delegate = delegate;
                } should_not raise_exception;
            });
        });

        context(@"rewardedVideoDidLoadForAdManager:", ^{
            beforeEach(^{
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerKey] = fakeAdManager;
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerDelegateMethodNameKey] = @"rewardedVideoDidLoadForAdManager:";
                [CDRSpecHelper specHelper].sharedExampleContext[kRewardedVideoDelegateMethodNameKey] = @"rewardedVideoAdDidLoadForAdUnitID:";
            });

            itShouldBehaveLike(kMPRewardedVideoDelegateMethod);
        });

        context(@"rewardedVideoDidExpireForAdManager:", ^{
            beforeEach(^{
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerKey] = fakeAdManager;
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerDelegateMethodNameKey] = @"rewardedVideoDidExpireForAdManager:";
                [CDRSpecHelper specHelper].sharedExampleContext[kRewardedVideoDelegateMethodNameKey] = @"rewardedVideoAdDidExpireForAdUnitID:";
            });

            itShouldBehaveLike(kMPRewardedVideoDelegateMethod);
        });

        context(@"rewardedVideoWillAppearForAdManager", ^{
            beforeEach(^{
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerKey] = fakeAdManager;
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerDelegateMethodNameKey] = @"rewardedVideoWillAppearForAdManager:";
                [CDRSpecHelper specHelper].sharedExampleContext[kRewardedVideoDelegateMethodNameKey] = @"rewardedVideoAdWillAppearForAdUnitID:";
            });

            itShouldBehaveLike(kMPRewardedVideoDelegateMethod);
        });

        context(@"rewardedVideoWillDisappearForAdManager", ^{
            beforeEach(^{
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerKey] = fakeAdManager;
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerDelegateMethodNameKey] = @"rewardedVideoWillDisappearForAdManager:";
                [CDRSpecHelper specHelper].sharedExampleContext[kRewardedVideoDelegateMethodNameKey] = @"rewardedVideoAdWillDisappearForAdUnitID:";
            });

            itShouldBehaveLike(kMPRewardedVideoDelegateMethod);
        });

        context(@"rewardedVideoDidDisappearForAdManager", ^{
            beforeEach(^{
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerKey] = fakeAdManager;
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerDelegateMethodNameKey] = @"rewardedVideoDidDisappearForAdManager:";
                [CDRSpecHelper specHelper].sharedExampleContext[kRewardedVideoDelegateMethodNameKey] = @"rewardedVideoAdDidDisappearForAdUnitID:";
            });

            itShouldBehaveLike(kMPRewardedVideoDelegateMethod);

            context(@"notifying ad managers that an ad played for their network", ^{
                __block NSString *adUnitID1, *adUnitID2, *playedAdUnitID;
                __block MPRewardedVideoAdManager *adManager1, *adManager2, *playedAdManager;

                // These tests use NSString and NSNumber for custom event class types for simplicity.
                // They should really be something like AdColonyRewardedVideoCustomEvent.
                beforeEach(^{
                    adUnitID1 = @"YES!YES!";
                    adUnitID2 = @"NO!NO!";
                    playedAdUnitID = @"Rawr";
                    adManager1 = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:adUnitID1 delegate:[MPRewardedVideo sharedInstance]];
                    adManager2 = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:adUnitID1 delegate:[MPRewardedVideo sharedInstance]];
                    playedAdManager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:playedAdUnitID delegate:[MPRewardedVideo sharedInstance]];

                    spy_on(adManager1);
                    spy_on(adManager2);
                    spy_on(playedAdManager);

                    adManagers[adUnitID1] = adManager1;
                    adManagers[adUnitID2] = adManager2;
                    adManagers[playedAdUnitID] = playedAdManager;
                });

                context(@"when multiple ad networks are tied to the played network", ^{
                    beforeEach(^{
                        adManager1 stub_method(@selector(customEventClass)).and_return([NSString class]);
                        adManager2 stub_method(@selector(customEventClass)).and_return([NSString class]);
                        playedAdManager stub_method(@selector(customEventClass)).and_return([NSString class]);
                    });

                    it(@"should notify all managers (except the one that played an ad) that an ad was played for their networks", ^{
                        [[MPRewardedVideo sharedInstance] rewardedVideoDidDisappearForAdManager:playedAdManager];

                        playedAdManager should_not have_received(@selector(handleAdPlayedForCustomEventNetwork));
                        adManager1 should have_received(@selector(handleAdPlayedForCustomEventNetwork));
                        adManager2 should have_received(@selector(handleAdPlayedForCustomEventNetwork));
                    });
                });

                context(@"when some ad networks are tied to the played network", ^{
                    beforeEach(^{
                        adManager1 stub_method(@selector(customEventClass)).and_return([NSNumber class]);
                        adManager2 stub_method(@selector(customEventClass)).and_return([NSString class]);
                        playedAdManager stub_method(@selector(customEventClass)).and_return([NSString class]);
                    });

                    it(@"should notify only the manager that are tied to the same network", ^{
                        [[MPRewardedVideo sharedInstance] rewardedVideoDidDisappearForAdManager:playedAdManager];

                        playedAdManager should_not have_received(@selector(handleAdPlayedForCustomEventNetwork));
                        adManager1 should_not have_received(@selector(handleAdPlayedForCustomEventNetwork));
                        adManager2 should have_received(@selector(handleAdPlayedForCustomEventNetwork));
                    });
                });
            });
        });

        context(@"rewardedVideoDidReceiveTapEventForAdManager", ^{
            beforeEach(^{
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerKey] = fakeAdManager;
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerDelegateMethodNameKey] = @"rewardedVideoDidReceiveTapEventForAdManager:";
                [CDRSpecHelper specHelper].sharedExampleContext[kRewardedVideoDelegateMethodNameKey] = @"rewardedVideoAdDidReceiveTapEventForAdUnitID:";
            });

            itShouldBehaveLike(kMPRewardedVideoDelegateMethod);
        });

        context(@"rewardedVideoWillLeaveApplicationForAdManager", ^{
            beforeEach(^{
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerKey] = fakeAdManager;
                [CDRSpecHelper specHelper].sharedExampleContext[kAdManagerDelegateMethodNameKey] = @"rewardedVideoWillLeaveApplicationForAdManager:";
                [CDRSpecHelper specHelper].sharedExampleContext[kRewardedVideoDelegateMethodNameKey] = @"rewardedVideoAdWillLeaveApplicationForAdUnitID:";
            });

            itShouldBehaveLike(kMPRewardedVideoDelegateMethod);
        });

        context(@"rewardedVideoShouldRewardUserForAdManager:reward:", ^{
            __block MPRewardedVideoReward *reward;
            __block NSString *currencyType;
            __block NSNumber *amount;

            beforeEach(^{
                amount = @9;
                currencyType = @"doge coin";
                reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyType amount:amount];
            });

            it(@"should forward the call to the rewarded video delegate if the delegate responds to the method", ^{
                [[MPRewardedVideo sharedInstance] rewardedVideoShouldRewardUserForAdManager:fakeAdManager reward:reward];
                delegate should have_received(@selector(rewardedVideoAdShouldRewardForAdUnitID:reward:)).with(fakeAdManager.adUnitID).and_with(reward);
            });

            it(@"should not raise an exception in the event that the delegate doesn't respond to the method", ^{
                ^{
                    // Hacky solution to get around the fact that we set the delegate on initialization and do not allow changing it afterward.
                    // We'll go ahead and set the delegate to an object that doesn't respond to any of the selectors here and then set it back to the original delegate.
                    [MPRewardedVideo sharedInstance].delegate = (id<MPRewardedVideoDelegate>)[[NSObject alloc] init];
                    [[MPRewardedVideo sharedInstance] rewardedVideoShouldRewardUserForAdManager:fakeAdManager reward:reward];
                    [MPRewardedVideo sharedInstance].delegate = delegate;
                } should_not raise_exception;
            });
        });

        context(@"rewardedVideoDidFailToLoadForAdManager:error:", ^{
            it(@"should forward the call to the rewarded video delegate if the delegate responds to the method", ^{
                NSError *error = [NSError errorWithDomain:@"a" code:0 userInfo:nil];
                [[MPRewardedVideo sharedInstance] rewardedVideoDidFailToLoadForAdManager:fakeAdManager error:error];
                delegate should have_received(@selector(rewardedVideoAdDidFailToLoadForAdUnitID:error:)).with(fakeAdManager.adUnitID).and_with(error);
            });

            it(@"should not raise an exception in the event that the delegate doesn't respond to the method", ^{
                ^{
                    // Hacky solution to get around the fact that we set the delegate on initialization and do not allow changing it afterward.
                    // We'll go ahead and set the delegate to an object that doesn't respond to any of the selectors here and then set it back to the original delegate.
                    [MPRewardedVideo sharedInstance].delegate = (id<MPRewardedVideoDelegate>)[[NSObject alloc] init];
                    [[MPRewardedVideo sharedInstance] rewardedVideoDidFailToLoadForAdManager:fakeAdManager error:nil];
                    [MPRewardedVideo sharedInstance].delegate = delegate;
                } should_not raise_exception;
            });
        });

        context(@"rewardedVideoDidFailToPlayForAdManager:error:", ^{
            it(@"should forward the call to its delegate if the delegate responds to the method", ^{
                NSError *error = [NSError errorWithDomain:@"a" code:0 userInfo:nil];
                [[MPRewardedVideo sharedInstance] rewardedVideoDidFailToPlayForAdManager:fakeAdManager error:error];
                delegate should have_received(@selector(rewardedVideoAdDidFailToPlayForAdUnitID:error:)).with(fakeAdManager.adUnitID).and_with(error);
            });

            it(@"should not raise an exception in the event the delegate doesn't respond to the method", ^{
                ^{
                    // Hacky solution to get around the fact that we set the delegate on initialization and do not allow changing it afterward.
                    // We'll go ahead and set the delegate to an object that doesn't respond to any of the selectors here and then set it back to the original delegate.
                    [MPRewardedVideo sharedInstance].delegate = (id<MPRewardedVideoDelegate>)[[NSObject alloc] init];
                    [[MPRewardedVideo sharedInstance] rewardedVideoDidFailToPlayForAdManager:fakeAdManager error:nil];
                    [MPRewardedVideo sharedInstance].delegate = delegate;
                } should_not raise_exception;
            });
        });
    });
});

SPEC_END
