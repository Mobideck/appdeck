#import "MPAdInfo.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdInfoSpec)

describe(@"MPAdInfo", ^{
    __block MPAdInfo *info;

    it(@"should have a convenience method for creating info objects", ^{
        info = [MPAdInfo infoWithTitle:@"whoop" ID:@"hey" type:MPAdInfoBanner];
        info.title should equal(@"whoop");
        info.ID should equal(@"hey");
        info.type should equal(MPAdInfoBanner);
    });
});

SPEC_END
