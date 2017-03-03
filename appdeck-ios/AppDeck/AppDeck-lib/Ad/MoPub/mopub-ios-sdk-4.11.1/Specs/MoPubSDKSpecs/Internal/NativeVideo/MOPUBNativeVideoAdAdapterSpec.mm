#import "MOPUBNativeVideoAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPStaticNativeAdImpressionTimer+Specs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MOPUBNativeVideoAdAdapter (Specs)

@property (nonatomic) MPStaticNativeAdImpressionTimer *staticImpressionTimer;

- (void)trackImpression;

@end

SPEC_BEGIN(MOPUBNativeVideoAdAdapterSpec)

describe(@"MOPUBNativeVideoAdAdapterSpec", ^{
    NSDictionary *validProperties = @{kAdTitleKey : @"WUT",
                                      kAdTextKey : @"WUT DaWG",
                                      kAdIconImageKey : kMPSpecsTestImageURL,
                                      kAdMainImageKey : kMPSpecsTestImageURL,
                                      kAdCTATextKey : @"DO IT",
                                      kImpressionTrackerURLsKey: @[@"ab#($@%", @"http://www.mopub.com/tearinupmyheartwhenimwithyou", @"http://www.mopub.com/pop"],
                                      kClickTrackerURLKey : @[@"http://www.mopub.com/byebyebye"],
                                      kDefaultActionURLKey : @"http://www.mopub.com/iwantyouback"
                                      };

    __block MOPUBNativeVideoAdAdapter *adapter;
    __block id<CedarDouble, MPNativeAdAdapterDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPNativeAdAdapterDelegate));

        adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:validProperties.mutableCopy];
        adapter.delegate = delegate;
    });

    context(@"initialization", ^{
        it(@"should not create a static impression timer", ^{
            adapter.staticImpressionTimer should be_nil;
        });
    });

    context(@"when the native ad will attach itself to a view", ^{
        beforeEach(^{
            [adapter willAttachToView:[UIView new]];
        });

        it(@"should create a static impression timer", ^{
            adapter.staticImpressionTimer should_not be_nil;
        });

        it(@"should start the timer for tracking the static impression", ^{
            adapter.staticImpressionTimer.viewVisibilityTimer.isScheduled should be_truthy;
        });
    });

    context(@"when the video has progressed", ^{
        it(@"should deallocate the static impression timer", ^{
            [adapter willAttachToView:[UIView new]];
            adapter.staticImpressionTimer should_not be_nil;

            [adapter handleVideoHasProgressedToTime:1];

            adapter.staticImpressionTimer should be_nil;
        });
    });
});

SPEC_END
