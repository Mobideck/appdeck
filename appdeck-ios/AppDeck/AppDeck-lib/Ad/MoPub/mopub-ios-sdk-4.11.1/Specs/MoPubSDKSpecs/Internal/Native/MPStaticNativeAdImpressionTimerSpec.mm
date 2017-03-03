#import "MPStaticNativeAdImpressionTimer+Specs.h"
#import "MPTimer.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPStaticNativeAdImpressionTimerSpec)

describe(@"MPStaticNativeAdImpressionTimerSpec", ^{
    __block MPStaticNativeAdImpressionTimer *impressionTimer;

    beforeEach(^{
        impressionTimer = [[MPStaticNativeAdImpressionTimer alloc] initWithRequiredSecondsForImpression:1 requiredViewVisibilityPercentage:.5];
    });

    it(@"should default first visibility time stamp to -1", ^{
        impressionTimer.firstVisibilityTimestamp should equal(-1);
    });
});

SPEC_END
