#import "MPiAdBannerCustomEvent.h"
#import "FakeADBannerView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPiAdBannerCustomEventSpec)

describe(@"MPiAdBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block MPiAdBannerCustomEvent *event;
    __block FakeADBannerView *banner;

    beforeEach(^{
        banner = [[[FakeADBannerView alloc] init] autorelease];
        fakeProvider.fakeADBannerView = banner.masquerade;

        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        event = [[[MPiAdBannerCustomEvent alloc] init] autorelease];
        event.delegate = delegate;
        [event requestAdWithSize:CGSizeZero customEventInfo:nil];
    });

    it(@"should not allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    describe(@"tracking impressions", ^{
        context(@"when an ad loads, and is not onscreen already", ^{
            beforeEach(^{
                [banner simulateLoadingAd];
            });

            it(@"should not track an impression", ^{
                delegate should_not have_received(@selector(trackImpression));
            });

            context(@"when the ad subsequently appears onscreen", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [event didDisplayAd];
                });

                it(@"should track an impression (only once)", ^{
                    delegate should have_received(@selector(trackImpression));

                    [delegate reset_sent_messages];
                    [event didDisplayAd];
                    delegate.sent_messages should be_empty;
                });

                context(@"when a new ad arrives", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [banner simulateLoadingAd];
                    });

                    it(@"should track an impression", ^{
                        delegate should have_received(@selector(trackImpression));
                    });
                });
            });
        });
    });

    describe(@"tracking clicks", ^{
        it(@"should track a click at most once per loaded ad", ^{
            [banner simulateLoadingAd];
            [banner simulateUserInteraction];
            delegate should have_received(@selector(trackClick));

            [delegate reset_sent_messages];
            [banner simulateUserInteraction];
            delegate should_not have_received(@selector(trackClick));

            [banner simulateLoadingAd];
            [banner simulateUserInteraction];
            delegate should have_received(@selector(trackClick));
        });
    });
});

SPEC_END
