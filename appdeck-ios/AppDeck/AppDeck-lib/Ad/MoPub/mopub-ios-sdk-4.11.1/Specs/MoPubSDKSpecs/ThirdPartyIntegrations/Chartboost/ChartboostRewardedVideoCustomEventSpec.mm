#import "ChartboostRewardedVideoCustomEvent.h"
#import "MPChartboostRouter+Specs.h"
#import "MPRewardedVideoReward.h"
#import "Chartboost+Specs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ChartboostRewardedVideoCustomEvent (ChartboostRouter) <ChartboostDelegate>
@end

SPEC_BEGIN(ChartboostRewardedVideoCustomEventSpec)

describe(@"ChartboostRewardedVideoCustomEvent", ^{
    __block ChartboostRewardedVideoCustomEvent *customEvent;
    __block id<MPRewardedVideoCustomEventDelegate, CedarDouble> delegate;
    __block NSString *appId;
    __block NSString *appSignature;
    __block NSString *location;
    __block NSDictionary *customEventInfo;

    beforeEach(^{
        appId = @"myAppId";
        appSignature = @"myAppSignature";
        location = @"location";
        customEventInfo = @{@"appId" : appId, @"appSignature" : appSignature, @"location" : location};

        customEvent = [[ChartboostRewardedVideoCustomEvent alloc] init];
        delegate = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
        customEvent.delegate = delegate;
    });

    afterEach(^{
        // Don't want remnants of previous tests to sit around in the router. So we clear out all the events.
        [[MPChartboostRouter sharedRouter] reset];
    });

    context(@"when presenting a rewarded video ad", ^{
        beforeEach(^{
            [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
        });

        context(@"when an ad is not available to play", ^{
            beforeEach(^{
                UIViewController *vc = [[UIViewController alloc] init];
                [customEvent presentRewardedVideoFromViewController:vc];
            });

            it(@"should report a failure to play to its delegate", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToPlayForCustomEvent:error:));
            });
        });

        context(@"MPRewardedVideoDelegate", ^{
            it(@"should tell its delegate the rewarded video appeared when the ad starts playing", ^{
                delegate should_not have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
                [customEvent didDisplayRewardedVideo:location];
                delegate should have_received(@selector(rewardedVideoDidAppearForCustomEvent:)).with(customEvent);
            });

            it(@"should tells its delegate the rewarded video will disappear and did disappear when the ad finishes playing", ^{
                delegate should_not have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                delegate should_not have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
                [customEvent didCloseRewardedVideo:location];
                delegate should have_received(@selector(rewardedVideoWillDisappearForCustomEvent:)).with(customEvent);
                delegate should have_received(@selector(rewardedVideoDidDisappearForCustomEvent:)).with(customEvent);
            });

            it(@"should tell its delegate the ad loaded when the zone loads", ^{
                [customEvent didCacheRewardedVideo:location];
                delegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:)).with(customEvent);
            });

            it(@"should forward reward calls to its delegate", ^{
                [customEvent didCompleteRewardedVideo:location withReward:200];
                delegate should have_received(@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:));
            });
        });

        context(@"when the ad is no longer needed by the rewarded video system", ^{
            beforeEach(^{
                [customEvent requestRewardedVideoWithCustomEventInfo:customEventInfo];
            });

            it(@"should no longer be an event in the ad colony router", ^{
                [MPChartboostRouter sharedRouter].rewardedVideoEvents[location] should equal(customEvent);
                [customEvent handleCustomEventInvalidated];
                [MPChartboostRouter sharedRouter].rewardedVideoEvents[location] should be_nil;
            });
        });
    });
});

SPEC_END
