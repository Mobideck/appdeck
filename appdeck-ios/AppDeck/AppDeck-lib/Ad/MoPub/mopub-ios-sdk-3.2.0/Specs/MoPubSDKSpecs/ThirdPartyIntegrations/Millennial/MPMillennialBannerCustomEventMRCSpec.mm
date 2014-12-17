#import "MPMillennialBannerCustomEvent.h"
#import "FakeMMAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMillennialBannerCustomEventMRCSpec)

describe(@"MPMillennialBannerCustomEvent MRC", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block FakeMMAdView *banner;
    __block NSDictionary *customEventInfo;

    beforeEach(^{
        banner = [[FakeMMAdView alloc] initWithFrame:CGRectMake(0,0,32,10)];
        fakeProvider.fakeMMAdView = banner;

        customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@728, @"adHeight":@90};
    });

    describe(@"deallocation", ^{
        it(@"should avoid retain cycles and not cause problems", ^{
            MPMillennialBannerCustomEvent *aNewEvent = [[MPMillennialBannerCustomEvent alloc] init];
            delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));
            aNewEvent.delegate = delegate;

            // Shouldn't allow the completion block to retain the custom event...
            NSUInteger retainCount = aNewEvent.retainCount;
            [aNewEvent requestAdWithSize:CGSizeZero customEventInfo:customEventInfo];
            aNewEvent.retainCount should equal(retainCount);
            [aNewEvent release]; //now it's gone

            [delegate reset_sent_messages];
            [banner simulateLoadingAd]; //should not crash
            delegate.sent_messages should be_empty;
        });
    });
});

SPEC_END
