#import "MPNativeView.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPNativeViewSpec)

describe(@"MPNativeViewSpec", ^{
    __block UIView *superview;
    __block MPNativeView *view;
    __block id<CedarDouble, MPNativeViewDelegate> delegate;

    beforeEach(^{
        superview = [[UIView alloc] init];
        delegate = nice_fake_for(@protocol(MPNativeViewDelegate));
        view = [[MPNativeView alloc] init];
        view.delegate = delegate;
    });

    it(@"should tell its delegate when it's added to a view", ^{
        [superview addSubview:view];
        delegate should have_received(@selector(nativeViewWillMoveToSuperview:)).with(superview);
    });

    it(@"should tell its delegate when it's removed from its superview", ^{
        [superview addSubview:view];
        [delegate reset_sent_messages];
        [view removeFromSuperview];

        delegate should have_received(@selector(nativeViewWillMoveToSuperview:)).with(nil);
    });
});

SPEC_END
