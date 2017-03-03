#import "MPChartboostRouter+Specs.h"
#import "ChartboostRewardedVideoCustomEvent.h"
#import "ChartboostInterstitialCustomEvent.h"
#import <Chartboost/Chartboost.h>
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPChartboostRouter (SpecFile)

- (void)setRewardedVideoEvent:(ChartboostRewardedVideoCustomEvent *)event forLocation:(NSString *)location;
- (void)setInterstitialEvent:(ChartboostInterstitialCustomEvent *)event forLocation:(NSString *)location;

@end

SPEC_BEGIN(MPChartboostRouterSpec)

describe(@"MPChartboostRouter", ^{

    afterEach(^{
        // Don't want remnants of previous tests to sit around in the router. So we clear out all the events.
        [[MPChartboostRouter sharedRouter] reset];
    });

    context(@"when loading rewarded video custom events", ^{
        __block NSString *location;
        __block ChartboostRewardedVideoCustomEvent *event;

        beforeEach(^{
            location = @"testLocationString";
            event = nice_fake_for([ChartboostRewardedVideoCustomEvent class]);
            event stub_method(@selector(location)).and_return(location);
        });

        context(@"when adding an event", ^{
            beforeEach(^{
                [[MPChartboostRouter sharedRouter] setRewardedVideoEvent:event forLocation:location];
            });

            it(@"should be able to retrieve the added event given the same location", ^{
                [MPChartboostRouter sharedRouter].rewardedVideoEvents[location] should equal(event);
            });

            context(@"when overwriting the event for a specific location", ^{
                __block ChartboostRewardedVideoCustomEvent *eventOverwrite;

                beforeEach(^{
                    eventOverwrite = nice_fake_for([ChartboostRewardedVideoCustomEvent class]);
                    [[MPChartboostRouter sharedRouter] setRewardedVideoEvent:eventOverwrite forLocation:location];
                });

                it(@"should not contain the original event for the location", ^{
                    [MPChartboostRouter sharedRouter].rewardedVideoEvents[location] should_not equal(event);
                });

                it(@"should contain the new event for the location", ^{
                    [MPChartboostRouter sharedRouter].rewardedVideoEvents[location] should equal(eventOverwrite);
                });
            });
        });
    });

    context(@"when loading interstitial custom events", ^{
        __block NSString *location;
        __block ChartboostInterstitialCustomEvent *event;

        beforeEach(^{
            location = @"testLocationString";
            event = nice_fake_for([ChartboostInterstitialCustomEvent class]);
            event stub_method(@selector(location)).and_return(location);
        });

        context(@"when adding an event", ^{
            beforeEach(^{
                [[MPChartboostRouter sharedRouter] setInterstitialEvent:event forLocation:location];
            });

            it(@"should be able to retrieve the added event given the same location", ^{
                [MPChartboostRouter sharedRouter].interstitialEvents[location] should equal(event);
                [MPChartboostRouter sharedRouter].activeInterstitialLocations should contain(location);
            });

            context(@"when removing an event", ^{
                it(@"should no longer be an event for the location", ^{
                    [[MPChartboostRouter sharedRouter] unregisterInterstitialEvent:event];
                    [MPChartboostRouter sharedRouter].activeInterstitialLocations should_not contain(location);
                });

                context(@"when trying to remove an object that isn't the object associated with the location", ^{
                    it(@"should not remove the custom event", ^{
                        ChartboostInterstitialCustomEvent<CedarDouble> *newObject = nice_fake_for([ChartboostInterstitialCustomEvent class]);
                        [[MPChartboostRouter sharedRouter] unregisterInterstitialEvent:newObject];
                        [MPChartboostRouter sharedRouter].interstitialEvents[location] should equal(event);
                        [MPChartboostRouter sharedRouter].activeInterstitialLocations should contain(location);
                    });
                });
            });

            context(@"when overwriting the event for a specific location", ^{
                __block ChartboostInterstitialCustomEvent *eventOverwrite;

                beforeEach(^{
                    eventOverwrite = nice_fake_for([ChartboostInterstitialCustomEvent class]);
                    [[MPChartboostRouter sharedRouter] setInterstitialEvent:eventOverwrite forLocation:location];
                });

                it(@"should not contain the original event for the location", ^{
                    [MPChartboostRouter sharedRouter].interstitialEvents[location] should_not equal(event);
                });

                it(@"should contain the new event for the location", ^{
                    [MPChartboostRouter sharedRouter].interstitialEvents[location] should equal(eventOverwrite);
                    [MPChartboostRouter sharedRouter].activeInterstitialLocations should contain(location);
                });
            });
        });
    });

});

SPEC_END
