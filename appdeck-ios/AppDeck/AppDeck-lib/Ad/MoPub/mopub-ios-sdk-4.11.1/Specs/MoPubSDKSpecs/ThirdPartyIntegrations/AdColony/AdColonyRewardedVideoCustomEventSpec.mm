#import "AdColonyRewardedVideoCustomEvent.h"
#import "AdColonyInstanceMediationSettings.h"
#import "AdColony+Specs.h"
#import "AdColonyCustomEvent+MPSpecs.h"
#import "MPAdColonyRouter+MPSpecs.h"
#import <Cedar/Cedar.h>

@interface AdColonyRewardedVideoCustomEvent () <AdColonyAdDelegate, MPAdColonyRouterDelegate>

@property (nonatomic, readonly) NSString *zoneId;

@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AdColonyRewardedVideoCustomEventSpec)

describe(@"AdColonyRewardedVideoCustomEvent", ^{
    __block AdColonyRewardedVideoCustomEvent *customEvent;
    __block id<MPRewardedVideoCustomEventDelegate, CedarDouble> delegate;
    __block NSString *appId;
    __block NSArray *allZoneIds;
    __block NSString *customEventZoneId;
    __block NSDictionary *customEventInfo;

    beforeEach(^{
        appId = @"AnAppID";
        customEventZoneId = @"CUSTOM_ZONE_ID";
        allZoneIds = @[@"CUSTOM_ZONE_ID", @"APE_ZONE", @"CAT_ZONE"];

        customEventInfo = @{
                            @"appId" : appId,
                            @"zoneId" : customEventZoneId,
                            @"allZoneIds" : allZoneIds,
                            };

        customEvent = [[AdColonyRewardedVideoCustomEvent alloc] init];
        delegate = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
        customEvent.delegate = delegate;
    });

    afterEach(^{
        // Don't want remnants of previous tests to sit around in the router. So we clear out all the events.
        [[MPAdColonyRouter sharedRouter] reset];

        // Just default to off no matter what after the test complets.
        [AdColony mp_setZoneRewardAvailability:NO];
    });

    context(@"when requesting an AdColony rewarded video ad with valid custom event information", ^{
        beforeEach(^{
            [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
        });

        afterEach(^{
            [AdColonyCustomEvent mp_resetAdColonyInitCount];
        });

        it(@"should use the app ID from the custom event info dictionary", ^{
            [AdColonyCustomEvent mp_appId] should equal(appId);
        });

        it(@"should use the zone IDs from the custom event info dictionary", ^{
            [[AdColonyCustomEvent mp_allZoneIds] objectAtIndex:0] should equal(allZoneIds[0]);
            [[AdColonyCustomEvent mp_allZoneIds] objectAtIndex:1] should equal(allZoneIds[1]);
        });

        it(@"should set the custom event's ad unit's zone id to the one in the custom event info dictionary", ^{
            customEvent.zoneId should equal(customEventZoneId);
        });

        it(@"should attempt to initialize Ad Colony", ^{
            [AdColonyCustomEvent mp_adColonyInitCount] should equal(1);
        });

        it(@"should be the router's event for its zone ID", ^{
            [MPAdColonyRouter sharedRouter].events[customEventZoneId] should equal(customEvent);
        });

        context(@"when an ad is already ready", ^{
            beforeEach(^{
                [AdColony mp_setZoneRewardAvailability:YES];
                [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
            });

            it(@"should immediately tell the delegate an ad has loaded", ^{
                delegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:)).with(customEvent);
            });
        });

        context(@"when an ad is not already ready", ^{
            beforeEach(^{
                [AdColony mp_setZoneRewardAvailability:NO];
                [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
            });

            it(@"should immediately tell the delegate an ad has loaded", ^{
                delegate should_not have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            });
        });
    });

    context(@"when requesting multiple ad colony ads", ^{
        __block AdColonyRewardedVideoCustomEvent *customEvent1;
        __block id<MPRewardedVideoCustomEventDelegate, CedarDouble> delegate1;
        __block AdColonyRewardedVideoCustomEvent *customEvent2;
        __block id<MPRewardedVideoCustomEventDelegate, CedarDouble> delegate2;
        __block NSString *customEventZoneId1;
        __block NSString *customEventZoneId2;
        __block NSDictionary *customEventInfo1;
        __block NSDictionary *customEventInfo2;

        beforeEach(^{
            customEventZoneId1 = @"CUSTOM_ZONE_IV_ID1";
            customEventZoneId2 = @"CUSTOM_ZONE_IV_ID2";

            customEventInfo1 = @{
                                @"appId" : appId,
                                @"zoneId" : customEventZoneId1,
                                @"allZoneIds" : allZoneIds,
                                };

            customEventInfo2 = @{
                                 @"appId" : appId,
                                 @"zoneId" : customEventZoneId2,
                                 @"allZoneIds" : allZoneIds,
                                 };

            customEvent1 = [[AdColonyRewardedVideoCustomEvent alloc] init];
            customEvent2 = [[AdColonyRewardedVideoCustomEvent alloc] init];
            delegate1 = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
            delegate2 = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
            customEvent1.delegate = delegate1;
            customEvent2.delegate = delegate2;

            [AdColony mp_setZoneRewardAvailability:NO];
            [customEvent1 requestRewardedVideoWithCustomEventInfo:customEventInfo1];
            [customEvent2 requestRewardedVideoWithCustomEventInfo:customEventInfo2];
        });

        it(@"should notify the correct custom event delegates when Ad Colony events happen", ^{
            // Make sure the first custom even sees the availability message while the second custom event doesn't.
            delegate1 should_not have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            delegate2 should_not have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));

            [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:YES inZone:customEventZoneId1];

            delegate1 should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:)).with(customEvent1);
            delegate2 should_not have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));

            // Now make sure the 2nd custom event observes the expire event while the first doesn't.
            [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:YES inZone:customEventZoneId2];
            [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:NO inZone:customEventZoneId2];

            delegate1 should_not have_received(@selector(rewardedVideoDidExpireForCustomEvent:));
            delegate2 should have_received(@selector(rewardedVideoDidExpireForCustomEvent:)).with(customEvent2);
        });
    });

    context(@"when presenting a rewarded video ad", ^{
        beforeEach(^{
            [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
        });

        context(@"when an ad is not available to play", ^{
            beforeEach(^{
                UIViewController *vc = [[UIViewController alloc] init];
                [AdColony mp_setZoneRewardAvailability:NO];
                [customEvent presentRewardedVideoFromViewController:vc];
            });

            it(@"should report a failure to play to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToPlayForCustomEvent:error:));
            });

            it(@"should not attempt to play the video", ^{
                [AdColony mp_playVideoCalled] should be_falsy;
            });
        });

        context(@"when an ad is available to play", ^{
            beforeEach(^{
                [AdColony mp_setZoneRewardAvailability:YES];
                [customEvent presentRewardedVideoFromViewController:nil];
            });

            afterEach(^{
                [AdColony mp_resetPlayeVideoCalledProperties];
            });

            it(@"should report that the ad will appear to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoWillAppearForCustomEvent:));
            });

            it(@"should attempt to play the video", ^{
                [AdColony mp_playVideoCalled] should be_truthy;
            });

            it(@"should not use pre/post popup if instance mediation settings are not provided", ^{
                [AdColony mp_playVideoCalledWithPostPopup] should be_falsy;
                [AdColony mp_playVideoCalledWithPrePopup] should be_falsy;
            });

            context(@"when instance mediation settings are supplied by the application", ^{
                context(@"when post popup is YES and pre popup is NO", ^{
                    beforeEach(^{
                        AdColonyInstanceMediationSettings *settings = [[AdColonyInstanceMediationSettings alloc] init];
                        settings.showPostPopup = YES;
                        settings.showPrePopup = NO;
                        delegate stub_method(@selector(instanceMediationSettingsForClass:)).and_return(settings);
                        [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
                        [customEvent presentRewardedVideoFromViewController:nil];
                    });

                    it(@"should use the mediation settings for popups", ^{
                        [AdColony mp_playVideoCalledWithPostPopup] should be_truthy;
                        [AdColony mp_playVideoCalledWithPrePopup] should be_falsy;
                    });
                });

                context(@"when post popup is NO and pre popup is YES", ^{
                    beforeEach(^{
                        AdColonyInstanceMediationSettings *settings = [[AdColonyInstanceMediationSettings alloc] init];
                        settings.showPostPopup = NO;
                        settings.showPrePopup = YES;
                        delegate stub_method(@selector(instanceMediationSettingsForClass:)).and_return(settings);
                        [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
                        [customEvent presentRewardedVideoFromViewController:nil];
                    });

                    it(@"should use the mediation settings for popups", ^{
                        [AdColony mp_playVideoCalledWithPostPopup] should be_falsy;
                        [AdColony mp_playVideoCalledWithPrePopup] should be_truthy;
                    });
                });
            });
        });

        context(@"when the ad is no longer needed by the rewarded video system", ^{
            beforeEach(^{
                [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
            });

            it(@"should no longer be an event in the ad colony router", ^{
                [MPAdColonyRouter sharedRouter].events[customEventZoneId] should equal(customEvent);
                [customEvent handleCustomEventInvalidated];
                [MPAdColonyRouter sharedRouter].events[customEventZoneId] should be_nil;
            });
        });

        describe(@"AdColonyAdDelegate", ^{
            it(@"should tell its delegate the rewarded video appeared when the ad starts playing", ^{
                delegate should_not have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
                [customEvent onAdColonyAdStartedInZone:customEventZoneId];
                delegate should have_received(@selector(rewardedVideoDidAppearForCustomEvent:)).with(customEvent);
            });

            it(@"should tells its delegate the rewarded video will disappear and did disappear when the ad finishes playing", ^{
                delegate should_not have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                delegate should_not have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
                [customEvent onAdColonyAdAttemptFinished:YES inZone:customEventZoneId];
                delegate should have_received(@selector(rewardedVideoWillDisappearForCustomEvent:)).with(customEvent);
                delegate should have_received(@selector(rewardedVideoDidDisappearForCustomEvent:)).with(customEvent);
            });
        });

        context(@"MPAdColonyRouterDelegate", ^{
            it(@"should tell its delegate the ad loaded when the zone loads", ^{
                [customEvent zoneDidLoad];
                delegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:)).with(customEvent);
            });

            it(@"should tell its delegate the ad expired when the zone expires", ^{
                [customEvent zoneDidExpire];
                delegate should have_received(@selector(rewardedVideoDidExpireForCustomEvent:)).with(customEvent);
            });

            it(@"should forward reward calls to its delegate", ^{
                MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:@"dogeCoin" amount:@(98)];
                [customEvent shouldRewardUserWithReward:reward];

                delegate should have_received(@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:)).with(customEvent).and_with(reward);
            });
        });
    });
});

SPEC_END
