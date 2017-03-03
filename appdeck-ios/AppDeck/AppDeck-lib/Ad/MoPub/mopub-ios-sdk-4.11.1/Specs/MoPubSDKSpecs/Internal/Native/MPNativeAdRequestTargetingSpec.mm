#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdConstants.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPNativeAdRequestTargetingSpec)

describe(@"MPNativeAdRequestTargeting", ^{
    __block MPNativeAdRequestTargeting *model;

    beforeEach(^{
        model = [MPNativeAdRequestTargeting targeting];
    });

    context(@"Setting desired assets", ^{
        it(@"should set nothing when nothing is set", ^{
            model.desiredAssets.count should equal(0);
        });

        it(@"should set the correct assets when some assets are set", ^{
            NSMutableSet *desiredAssets = [NSMutableSet setWithObjects:kAdTitleKey,
                                           kAdTextKey, kAdIconImageKey, kAdStarRatingKey,
                                           nil];
            model.desiredAssets = desiredAssets;

            model.desiredAssets should equal(desiredAssets);
        });

        it(@"should set the correct assets when some assets are invalid", ^{
            NSMutableSet *desiredAssets = [NSMutableSet setWithObjects:kAdTitleKey,
                                           kAdMainImageKey, @"a", @"b", @"c",
                                           nil];
            NSMutableSet *correctAssets = [NSMutableSet setWithObjects:kAdTitleKey,
                                           kAdMainImageKey,
                                           nil];
            model.desiredAssets = desiredAssets;

            model.desiredAssets should_not equal(desiredAssets);
            model.desiredAssets should equal(correctAssets);
        });
    });
});

SPEC_END
