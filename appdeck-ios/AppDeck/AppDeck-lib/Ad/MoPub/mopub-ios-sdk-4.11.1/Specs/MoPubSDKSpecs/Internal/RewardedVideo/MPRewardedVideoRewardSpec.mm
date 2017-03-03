#import "MPRewardedVideoReward.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPRewardedVideoRewardSpec)

describe(@"MPRewardedVideoReward", ^{
    __block MPRewardedVideoReward *reward;

    describe(@"Initialization", ^{
        context(@"when not using the initializer that takes in the currency type", ^{
            beforeEach(^{
                reward = [[MPRewardedVideoReward alloc] initWithCurrencyAmount:@101];
            });

            it(@"should record the amount correctly", ^{
                reward.amount should equal(@101);
            });

            it(@"should specify the currency type as unknown", ^{
                reward.currencyType should equal(kMPRewardedVideoRewardCurrencyTypeUnspecified);
            });
        });

        context(@"when using the initializer that takes in the currency type and amount", ^{
            beforeEach(^{
                reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:@"heyo" amount:@101];
            });

            it(@"should record the amount correctly", ^{
                reward.amount should equal(@101);
            });

            it(@"should record the currency type correctly", ^{
                reward.currencyType should equal(@"heyo");
            });
        });
    });
});

SPEC_END
