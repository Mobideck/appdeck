#import "MPAdColonyRouter+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdColonyRouterSpec)

describe(@"MPAdColonyRouter", ^{
    __block NSString *zoneID;
    __block id<MPAdColonyRouterDelegate> event;

    beforeEach(^{
        zoneID = @"KofiKingston";
        event = nice_fake_for(@protocol(MPAdColonyRouterDelegate));
    });

    afterEach(^{
        // Don't want remnants of previous tests to sit around in the router. So we clear out all the events.
        [[MPAdColonyRouter sharedRouter] reset];
    });

    context(@"when adding an event", ^{
        beforeEach(^{
            [[MPAdColonyRouter sharedRouter] setCustomEvent:event forZoneId:zoneID];
        });

        it(@"should be able to retrieve the added event given the same zone ID", ^{
            [MPAdColonyRouter sharedRouter].events[zoneID] should equal(event);
        });

        context(@"when removing an event", ^{
            it(@"should no longer be an event for the zone ID", ^{
                [[MPAdColonyRouter sharedRouter] removeCustomEvent:event forZoneId:zoneID];
                [MPAdColonyRouter sharedRouter].events[zoneID] should be_nil;
            });

            context(@"when trying to remove an object that isn't the object associated with the zone ID", ^{
                it(@"should not remove the custom event", ^{
                    id<MPAdColonyRouterDelegate, CedarDouble> newObject = nice_fake_for(@protocol(MPAdColonyRouterDelegate));
                    [[MPAdColonyRouter sharedRouter] removeCustomEvent:newObject forZoneId:zoneID];
                    [MPAdColonyRouter sharedRouter].events[zoneID] should equal(event);
                });
            });
        });

        context(@"when overwriting the event for a specific zoneID", ^{
            __block id<MPAdColonyRouterDelegate> eventOverwrite;

            beforeEach(^{
                eventOverwrite = nice_fake_for(@protocol(MPAdColonyRouterDelegate));
                [[MPAdColonyRouter sharedRouter] setCustomEvent:eventOverwrite forZoneId:zoneID];
            });

            it(@"should not contain the original event for the zoneID", ^{
                [MPAdColonyRouter sharedRouter].events[zoneID] should_not equal(event);
            });

            it(@"should contain the new event for the zoneID", ^{
                [MPAdColonyRouter sharedRouter].events[zoneID] should equal(eventOverwrite);
            });
        });
    });

    context(@"on ad availability change", ^{
        beforeEach(^{
            [[MPAdColonyRouter sharedRouter] setCustomEvent:event forZoneId:zoneID];
        });

        context(@"when available", ^{
            context(@"when custom event zone is available", ^{
                beforeEach(^{
                    event stub_method(@selector(zoneAvailable)).and_return(YES);
                    [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:YES inZone:zoneID];
                });

                it(@"should not tell the custom event the zone did load", ^{
                    event should_not have_received(@selector(zoneDidLoad));
                });
            });

            context(@"when custom event zone is not available", ^{
                beforeEach(^{
                    event stub_method(@selector(zoneAvailable)).and_return(NO);
                    [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:YES inZone:zoneID];
                });

                it(@"should tell the custom event the zone did load", ^{
                    event should have_received(@selector(zoneDidLoad));
                });
            });

            context(@"when zoneID doesn't map to anything,", ^{
                beforeEach(^{
                    event stub_method(@selector(zoneAvailable)).and_return(NO);
                    [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:YES inZone:@"somethingWrong"];
                });

                it(@"should not tell the custom event the zone did load", ^{
                    event should_not have_received(@selector(zoneDidLoad));
                });
            });
        });

        context(@"when not available", ^{
            context(@"when custom event zone is available", ^{
                beforeEach(^{
                    event stub_method(@selector(zoneAvailable)).and_return(YES);
                    [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:NO inZone:zoneID];
                });

                it(@"should tell the custom event the zone did expire", ^{
                    event should have_received(@selector(zoneDidExpire));
                });
            });

            context(@"when custom event zone is not available", ^{
                beforeEach(^{
                    event stub_method(@selector(zoneAvailable)).and_return(NO);
                    [[MPAdColonyRouter sharedRouter] onAdColonyAdAvailabilityChange:NO inZone:zoneID];
                });

                it(@"should tell the custom event the zone did expire", ^{
                    event should_not have_received(@selector(zoneDidExpire));
                });
            });
        });
    });

    context(@"when reporting currency rewards", ^{
        beforeEach(^{
            [[MPAdColonyRouter sharedRouter] setCustomEvent:event forZoneId:zoneID];
        });

        context(@"when success is false", ^{
            it(@"should not pass the event to the custom event", ^{
                [[MPAdColonyRouter sharedRouter] onAdColonyV4VCReward:NO currencyName:@"hey" currencyAmount:3 inZone:zoneID];
                event should_not have_received(@selector(shouldRewardUserWithReward:));
            });
        });

        context(@"when success is true", ^{
            it(@"should pass the event to the custom event", ^{
                [[MPAdColonyRouter sharedRouter] onAdColonyV4VCReward:YES currencyName:@"hey" currencyAmount:3 inZone:zoneID];
                event should have_received(@selector(shouldRewardUserWithReward:));
            });
        });
    });
});

SPEC_END
