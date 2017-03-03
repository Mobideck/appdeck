#import "AdColonyInterstitialCustomEvent.h"
#import "AdColony+Specs.h"
#import "MPInstanceProvider+AdColony.h"
#import "AdColonyCustomEvent+MPSpecs.h"
#import <Cedar/Cedar.h>

@class MPAdColonyRouter;

@interface AdColonyInterstitialCustomEvent ()

@property (nonatomic, readonly) NSString *zoneId;

- (void)invalidate;

@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AdColonyInterstitialCustomEventSpec)

describe(@"AdColonyInterstitialCustomEvent", ^{
    __block AdColonyInterstitialCustomEvent *model;
    __block id<MPInterstitialCustomEventDelegate, CedarDouble> delegate;

    beforeEach(^{
        [AdColony mp_setZoneStatus:-1];

        model = [[AdColonyInterstitialCustomEvent alloc] init];
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        model.delegate = delegate;

        // update delegate because AdColony is only initialized ONCE, and our fake instance provider is created
        // for every test
        [AdColony mp_setAdColonyDelegate:[[MPInstanceProvider sharedProvider] sharedMPAdColonyRouter]];
    });

    context(@"when requesting an AdColony video ad", ^{
        beforeEach(^{
            [model requestInterstitialWithCustomEventInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"CUSTOM_ZONE_ID", @"zoneId",
                                                           [NSArray arrayWithObjects:@"ZONE_1", @"ZONE_2", nil], @"allZoneIds",
                                                           nil]];
        });

        it(@"should use the default app id", ^{
            [AdColonyCustomEvent mp_appId] should equal(@"YOUR_ADCOLONY_APPID");
        });

        it(@"should initialize the zone ids", ^{
            [[AdColonyCustomEvent mp_allZoneIds] objectAtIndex:0] should equal(@"ZONE_1");
            [[AdColonyCustomEvent mp_allZoneIds] objectAtIndex:1] should equal(@"ZONE_2");
        });

        it(@"should set this ad unit's zone id", ^{
            model.zoneId should equal(@"CUSTOM_ZONE_ID");
        });
    });

    context(@"when requesting an AdColony video ad without a zoneId", ^{
        beforeEach(^{
            [model requestInterstitialWithCustomEventInfo:nil];
        });

        it(@"should use the default zoneId", ^{
            model.zoneId should equal(@"YOUR_ADCOLONY_DEFAULT_ZONEID");
        });
    });

    it(@"should figure how to configure AdColony multiple times so we can re-test initialization", PENDING);

    context(@"when a video is initially unavailable", ^{
        beforeEach(^{
            [model requestInterstitialWithCustomEventInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"CUSTOM_ZONE_ID", @"zoneId",
                                                           nil]];
            [AdColony mp_onAdColonyAdAvailabilityChange:NO inZone:@"CUSTOM_ZONE_ID"];
        });

        it(@"should not notify the delegate", ^{
            delegate.sent_messages.count should equal(0);
        });
    });

    context(@"when a video becomes available", ^{
        beforeEach(^{
            [model requestInterstitialWithCustomEventInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"CUSTOM_ZONE_ID", @"zoneId",
                                                           nil]];
            [AdColony mp_onAdColonyAdAvailabilityChange:YES inZone:@"CUSTOM_ZONE_ID"];
        });

        it(@"should notify the delegate that a video is available", ^{
            delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));
        });

        context(@"when the video then expires", ^{
            beforeEach(^{
                [AdColony mp_onAdColonyAdAvailabilityChange:NO inZone:@"CUSTOM_ZONE_ID"];
            });

            it(@"should notify the delegate that the video has expired", ^{
                delegate should have_received(@selector(interstitialCustomEventDidExpire:));
            });

            context(@"when the ad tries to display after expiration", ^{
                beforeEach(^{
                    [model showInterstitialFromRootViewController:nil];
                });

                it(@"should notify the delegate of the error", ^{
                    delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:));
                });
            });
        });
    });

    context(@"when multiple custom events/zones request ads at the same time", ^{
        __block AdColonyInterstitialCustomEvent *model2;
        __block id<MPInterstitialCustomEventDelegate, CedarDouble> delegate2;

        beforeEach(^{
            model2 = [[AdColonyInterstitialCustomEvent alloc] init];
            delegate2 = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
            model2.delegate = delegate2;

            [model requestInterstitialWithCustomEventInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"CUSTOM_ZONE_ID", @"zoneId",
                                                           nil]];
            [model2 requestInterstitialWithCustomEventInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"CUSTOM_ZONE_ID_2", @"zoneId",
                                                           nil]];
        });

        context(@"when the second zone becomes available", ^{
            beforeEach(^{
                [AdColony mp_onAdColonyAdAvailabilityChange:YES inZone:@"CUSTOM_ZONE_ID_2"];
            });

            it(@"should notify the correct delegate", ^{
                delegate2 should have_received(@selector(interstitialCustomEvent:didLoadAd:));
                delegate should_not have_received(@selector(interstitialCustomEvent:didLoadAd:));
            });
        });

        context(@"when both zones become available", ^{
            beforeEach(^{
                [AdColony mp_onAdColonyAdAvailabilityChange:YES inZone:@"CUSTOM_ZONE_ID_2"];
                [AdColony mp_onAdColonyAdAvailabilityChange:YES inZone:@"CUSTOM_ZONE_ID"];
            });

            it(@"should notify the correct delegates", ^{
                delegate2 should have_received(@selector(interstitialCustomEvent:didLoadAd:));
                delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));
            });
        });

        context(@"when both zones become available and the second zone expires", ^{
            beforeEach(^{
                [AdColony mp_onAdColonyAdAvailabilityChange:YES inZone:@"CUSTOM_ZONE_ID_2"];
                [AdColony mp_onAdColonyAdAvailabilityChange:YES inZone:@"CUSTOM_ZONE_ID"];
                [AdColony mp_onAdColonyAdAvailabilityChange:NO inZone:@"CUSTOM_ZONE_ID_2"];
            });

            it(@"should notify the correct delegates", ^{
                delegate2 should have_received(@selector(interstitialCustomEvent:didLoadAd:));
                delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));

                delegate2 should have_received(@selector(interstitialCustomEventDidExpire:));
                delegate should_not have_received(@selector(interstitialCustomEventDidExpire:));
            });
        });
    });

    context(@"when a zone is immediately available", ^{
        beforeEach(^{
            [AdColony mp_setZoneStatus:ADCOLONY_ZONE_STATUS_ACTIVE];
            [model requestInterstitialWithCustomEventInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           @"CUSTOM_ZONE_ID", @"zoneId",
                                                           nil]];
        });

        it(@"should immediately let the delegate know a video is ready", ^{
            delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));
        });
    });
});

SPEC_END
