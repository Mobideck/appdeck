#import "GreystripeInterstitialCustomEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GreystripeInterstitialCustomEventSpec)

describe(@"GreystripeInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block GreystripeInterstitialCustomEvent *event;
    __block FakeGSFullscreenAd *interstitial;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        event = [[GreystripeInterstitialCustomEvent alloc] init];
        event.delegate = delegate;
    });

    describe(@"-requestInterstitialWithCustomEventInfo", ^{
        beforeEach(^{
            interstitial = [[FakeGSFullscreenAd alloc] init];
            fakeProvider.fakeGSFullscreenAd = interstitial;
        });

        context(@"using the right GUID", ^{
            afterEach(^{
                [GreystripeInterstitialCustomEvent setGUID:nil];
            });

            it(@"should use the GUID in customEventInfo if provided", ^{
                NSString *GUID = @"mopub_is_great";
                NSDictionary *info = @{@"GUID": GUID};
                [GreystripeInterstitialCustomEvent setGUID:@"dont_use_me!"];
                [event requestInterstitialWithCustomEventInfo:info];
                interstitial.GUID should equal(GUID);
            });

            it(@"should use the globally set GUID if the GUID isn't set in the customEventInfo", ^{
                NSString *GUID = @"mopub_is_really_really_spectacular";
                [GreystripeInterstitialCustomEvent setGUID:GUID];
                [event requestInterstitialWithCustomEventInfo:nil];
                interstitial.GUID should equal(GUID);

            });

            it(@"should use the #define'd GUID if the GUID isn't set in the customEventInfo or globally", ^{
                [event requestInterstitialWithCustomEventInfo:nil];
                interstitial.GUID should equal(@"YOUR_GREYSTRIPE_GUID");
            });
        });

        it(@"should use the hard-coded GUID if the GUID isn't provided in the custom event info", ^{
            [event requestInterstitialWithCustomEventInfo:nil];
            interstitial.didFetch should equal(YES);
            delegate should have_received(@selector(location));
            delegate.sent_messages.count should equal(1);
        });
    });
});

SPEC_END
