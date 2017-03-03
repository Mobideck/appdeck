#import "MPServerAdPositioning.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPServerAdPositioningSpec)

describe(@"MPServerAdPositioning", ^{
    __block MPServerAdPositioning *positioning;

    beforeEach(^{
        positioning = nil;
    });
});

SPEC_END
