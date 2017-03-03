#import "MOPUBNativeVideoAdRenderer.h"
#import "MOPUBNativeVideoAdAdapter.h"
#import "MPNativeAdConstants.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MOPUBNativeVideoAdRenderer (Specs)

- (void)playerDidProgressToTime:(NSTimeInterval)playbackTime;
- (UIView *)retrieveViewWithAdapter:(MOPUBNativeVideoAdAdapter<MPNativeAdAdapter> *)adapter error:(NSError **)error;

@end

SPEC_BEGIN(MOPUBNativeVideoAdRendererSpec)

describe(@"MOPUBNativeVideoAdRendererSpec", ^{
    NSDictionary *validProperties = @{kAdTitleKey : @"WUT",
                                      kAdTextKey : @"WUT DaWG",
                                      kAdIconImageKey : kMPSpecsTestImageURL,
                                      kAdMainImageKey : kMPSpecsTestImageURL,
                                      kAdCTATextKey : @"DO IT",
                                      kImpressionTrackerURLsKey: @[@"ab#($@%", @"http://www.mopub.com/tearinupmyheartwhenimwithyou", @"http://www.mopub.com/pop"],
                                      kClickTrackerURLKey : @[@"http://www.mopub.com/byebyebye"],
                                      kDefaultActionURLKey : @"http://www.mopub.com/iwantyouback"
                                      };

    __block MOPUBNativeVideoAdRenderer *renderer;
    __block MOPUBNativeVideoAdAdapter *adapter;

    beforeEach(^{
        adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:validProperties.mutableCopy];
        spy_on(adapter);
        renderer = [[MOPUBNativeVideoAdRenderer alloc] init];
    });

    context(@"when the renderer is told the video has progressed", ^{
        it(@"should tell the adapter that the video has progressed", ^{
            [renderer retrieveViewWithAdapter:adapter error:nil];
            [renderer playerDidProgressToTime:1];
            adapter should have_received(@selector(handleVideoHasProgressedToTime:));
        });
    });
});

SPEC_END
