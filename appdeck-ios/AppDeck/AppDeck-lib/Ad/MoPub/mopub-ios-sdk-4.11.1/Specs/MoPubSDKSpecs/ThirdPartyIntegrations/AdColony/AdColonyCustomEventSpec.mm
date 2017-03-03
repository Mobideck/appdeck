#import "AdColonyCustomEvent+MPSpecs.h"
#import "AdColony+Specs.h"
#import "MoPub.h"
#import "AdColonyGlobalMediationSettings.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AdColonyCustomEventSpec)

describe(@"AdColonyCustomEvent", ^{
    beforeEach(^{
        [AdColonyCustomEvent mp_enableAdColonyNetworkInit:YES];
    });

    afterEach(^{
        [AdColonyCustomEvent mp_enableAdColonyNetworkInit:NO];
    });

    // We can only get to ad colony's init once. So we can really only test one set of values.
    context(@"when initializing Ad Colony", ^{
        __block NSArray *zoneIDs1;
        __block NSArray *zoneIDs2;
        __block NSString *appID1;
        __block NSString *appID2;
        __block AdColonyGlobalMediationSettings *settings;

        beforeEach(^{
            zoneIDs1 = @[@"1"];
            zoneIDs2 = @[@"2"];

            appID1 = @"appID1";
            appID2 = @"appID2";

            settings = [[AdColonyGlobalMediationSettings alloc] init];
            settings.customId = @"jobber";

            [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:@[settings] delegate:nil];
            [AdColonyCustomEvent initializeAdColonyCustomEventWithAppId:appID1 allZoneIds:zoneIDs1 customerId:nil];
        });

        afterEach(^{
            [AdColony mp_clearCustomID];
        });

        it(@"should only call Ad Colony's initialize method once", ^{
            [AdColonyCustomEvent initializeAdColonyCustomEventWithAppId:appID2 allZoneIds:zoneIDs2 customerId:@"customerId"];

            [AdColony mp_getAppId] should equal(appID1);
            [AdColony mp_getZoneIds] should equal(zoneIDs1);
        });

        // This test may not pass if another file initializes ad colony first. Since we only allow ad colony initialization once,
        // the customID can only be set once at that time. So we'll leave this pending.
        xit(@"should have set the customer ID if provided with a global mediation setting", ^{
            [AdColony mp_customID] should equal(settings.customId);
        });
    });
});

SPEC_END
