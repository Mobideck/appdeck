#import "MPAdSection.h"
#import "MPAdInfo.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdSectionSpec)

describe(@"MPAdSection", ^{
    __block MPAdSection *section;

    beforeEach(^{
        section = [MPAdSection sectionWithTitle:@"section" ads:@[
                   [MPAdInfo infoWithTitle:@"1" ID:@"2" type:MPAdInfoBanner],
                   [MPAdInfo infoWithTitle:@"3" ID:@"4" type:MPAdInfoBanner]]];
    });

    describe(@"initialization", ^{
        it(@"should store the title and the ads", ^{
            section.title should equal(@"section");
            [[section adAtIndex:0] title] should equal(@"1");
        });

        it(@"should return the number of ads", ^{
            section.count should equal(2);
        });
    });
});

SPEC_END
