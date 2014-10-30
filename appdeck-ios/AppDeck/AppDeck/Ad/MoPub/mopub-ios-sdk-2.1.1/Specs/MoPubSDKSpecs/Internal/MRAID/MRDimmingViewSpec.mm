#import "MRDimmingView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRDimmingViewSpec)

describe(@"MRDimmingView", ^{
    __block MRDimmingView *view;

    beforeEach(^{
        view = [[MRDimmingView alloc] init];
    });

    context(@"on -init", ^{
        it(@"should be transparent", ^{
            view.alpha should equal(0);
        });
    });

    context(@"setDimmed:", ^{
        it(@"should adjust appropriately", ^{
            [view setDimmingOpacity:0.8];

            [view setDimmed:YES];
            view.alpha should be_close_to(0.8);

            [view setDimmingOpacity:0.5];
            view.alpha should be_close_to(0.5);

            [view setDimmed:NO];
            view.alpha should equal(0);

            [view setDimmingOpacity:0.7];
            view.alpha should equal(0);

            [view setDimmed:YES];
            view.alpha should be_close_to(0.7);
        });
    });
});

SPEC_END
