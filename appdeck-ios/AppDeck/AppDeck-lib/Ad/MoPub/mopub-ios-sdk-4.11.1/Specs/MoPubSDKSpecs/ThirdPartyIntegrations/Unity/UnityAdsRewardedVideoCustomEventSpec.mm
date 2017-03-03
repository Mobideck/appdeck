#import "UnityAdsRewardedVideoCustomEvent.h"
#import "MPRewardedVideo.h"
#import "MPUnityRouter.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "UnityAds+Specs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(UnityAdsRewardedVideoCustomEventSpec)

describe(@"UnityAdsRewardedVideoCustomEvent", ^{
    __block UnityAdsRewardedVideoCustomEvent *model;
    __block id<CedarDouble, MPRewardedVideoCustomEventDelegate> delegate;
    __block UnityAds *sharedSDK;
    __block MPUnityRouter *router;

    beforeEach(^{
        model = [[UnityAdsRewardedVideoCustomEvent alloc] init];
        delegate = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
        model.delegate = delegate;

        sharedSDK = [UnityAds sharedInstance];
        router = [MPUnityRouter sharedRouter];
    });

    context(@"when requesting a Unity rewarded video ad", ^{
        beforeEach(^{
            [model requestRewardedVideoWithCustomEventInfo:[NSDictionary dictionaryWithObject:@"CUSTOM_GAME_ID" forKey:@"gameId"]];
            spy_on(sharedSDK);
        });

        it(@"should set itself as the Unity router's delegate", ^{
            [router delegate] should equal(model);
        });

        it(@"should use the app id from the info dictionary", ^{
            [UnityAds mp_getGameId] should equal(@"CUSTOM_GAME_ID");
        });

        it(@"should not set anything as the zoneId if there is no zone Id", ^{
            sharedSDK should_not have_received(@selector(setZone:));
        });

        context(@"when Unity sends us unityAdsFetchCompleted", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [router unityAdsFetchCompleted];
            });

            it(@"should notify the delegate ad did load", ^{
                delegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            });
        });

        context(@"when Unity sends us unityAdsVideoCompleted", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            describe(@"with a reward string", ^{
                beforeEach(^{
                    [router unityAdsVideoCompleted:@"reward" skipped:NO];
                });

                // These messages are not tied to Unity's completion callback, but rather the will/did hide
                // callbacks.
                it(@"should not send disappear messages to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                    delegate should_not have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
                });

                it(@"should send reward message to the delegate", ^{
                    delegate should have_received(@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:));
                });
            });

            describe(@"without a reward string", ^{
                beforeEach(^{
                    [router unityAdsVideoCompleted:nil skipped:NO];
                });

                // These messages are not tied to Unity's completion callback, but rather the will/did hide
                // callbacks.
                it(@"should not send disappear messages to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                    delegate should_not have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
                });

                it(@"should not send reward message to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoAdShouldRewardForAdUnitID:reward:));
                });
            });

            describe(@"with a reward string but a skip", ^{
                beforeEach(^{
                    [router unityAdsVideoCompleted:@"reward" skipped:YES];
                });

                it(@"should not send disappear messages to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                    delegate should_not have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
                });

                it(@"should not send reward message to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoAdShouldRewardForAdUnitID:reward:));
                });
            });
        });

        context(@"when Unity sends us callbacks that the ad is closed", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            it(@"should send disappear messages to the delegate", ^{
                [router unityAdsWillHide];
                delegate should have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                [router unityAdsDidHide];
                delegate should have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
            });
        });

        context(@"when Unity sends us callbacks to show the ad", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            it(@"should send appear messages to the delegate", ^{
                [router unityAdsWillShow];
                delegate should have_received(@selector(rewardedVideoWillAppearForCustomEvent:));
                [router unityAdsDidShow];
                delegate should have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
            });
        });
    });

    context(@"when playing a Unity rewarded video ad", ^{
        __block UIViewController *controller;

        beforeEach(^{
            spy_on(router);
            router stub_method(@selector(isAdAvailableForZoneId:)).and_return(YES);
            controller = [[UIViewController alloc] init];
        });

        context(@"when using instance mediation settings", ^{
            it(@"should pass the userIdentifier to the Unity SDK", ^{
                UnityAdsInstanceMediationSettings *settings = [[UnityAdsInstanceMediationSettings alloc] init];
                settings.userIdentifier = @"user_identifier";
                delegate stub_method(@selector(instanceMediationSettingsForClass:)).and_return(settings);

                [model presentRewardedVideoFromViewController:controller];
                [[UnityAds mp_getShowDictionary] objectForKey:kUnityAdsOptionGamerSIDKey] should equal(@"user_identifier");
            });
        });

        context(@"when not using instance mediation settings", ^{
            it(@"should not pass a userIdentifier to the Unity SDK", ^{
                [model presentRewardedVideoFromViewController:controller];
                [[UnityAds mp_getShowDictionary] objectForKey:kUnityAdsOptionGamerSIDKey] should be_nil;
            });
        });
    });

    context(@"when there are multiple requests to load a Unity rewarded video ad", ^{
        __block UnityAdsRewardedVideoCustomEvent *secondModel;
        __block id<CedarDouble, MPRewardedVideoCustomEventDelegate> secondDelegate;

        beforeEach(^{
            spy_on(sharedSDK);
            secondModel = [[UnityAdsRewardedVideoCustomEvent alloc] init];
            secondDelegate = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
            secondModel.delegate = secondDelegate;

            [model requestRewardedVideoWithCustomEventInfo:@{@"gameId": @"CUSTOM_GAME_ID", @"zoneId" : @"rewardedVideoZone1"}];
            [secondModel requestRewardedVideoWithCustomEventInfo:@{@"gameId": @"CUSTOM_GAME_ID", @"zoneId" : @"rewardedVideoZone2"}];
        });

        it(@"secondModel should be the Unity router's delegate", ^{
            [router delegate] should equal(secondModel);

            [router unityAdsFetchCompleted];
            secondDelegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            delegate should_not have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
        });

        it(@"should set the zoneId on the SDK for the second custom event", ^{
            sharedSDK should have_received(@selector(setZone:)).with(@"rewardedVideoZone2");
        });

        context(@"when the current Unity delegate is invalidated", ^{
            beforeEach(^{
                [secondModel performSelector:@selector(handleCustomEventInvalidated) withObject:nil];
            });

            it(@"should nil out the Unity router's delegate", ^{
                [router delegate] should be_nil;
            });

            context(@"when another custom event requests a Unity ad", ^{
                beforeEach(^{
                    [model requestRewardedVideoWithCustomEventInfo:nil];
                });

                it(@"should be the Unity router's delegate", ^{
                    [router delegate] should equal(model);
                });
            });
        });
    });
});

SPEC_END
