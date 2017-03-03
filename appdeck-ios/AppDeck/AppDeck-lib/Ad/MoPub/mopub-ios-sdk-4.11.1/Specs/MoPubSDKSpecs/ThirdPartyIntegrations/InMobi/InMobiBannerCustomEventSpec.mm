#import "InMobiBannerCustomEvent.h"
#import "FakeIMAdView.h"
#import "InMobi+Specs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiBannerCustomEventSpec)

describe(@"InMobiBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block InMobiBannerCustomEvent *event;
    __block CLLocation *location;
    __block FakeIMAdView *banner;

    beforeEach(^{
        [InMobi initialize:@"YOUR_INMOBI_APP_ID"];

        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        event = [[InMobiBannerCustomEvent alloc] init];
        event.delegate = delegate;

        banner = [[FakeIMAdView alloc] initWithFrame:CGRectZero];
        fakeProvider.fakeIMAdView = banner;

        location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                  altitude:11
                                        horizontalAccuracy:12.3
                                          verticalAccuracy:10
                                                 timestamp:[NSDate date]];
        delegate stub_method("location").and_return(location);
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    context(@"when requesting an ad with a valid size", ^{
        it(@"should configure the ad correctly, tell it to fech and not tell the delegate anything just yet", ^{
            [event requestAdWithSize:MOPUB_BANNER_SIZE customEventInfo:nil];
            banner.appId should equal(@"YOUR_INMOBI_APP_ID");
            banner.adSize should equal(IM_UNIT_320x50);
            banner.frame should equal(CGRectMake(0, 0, 320, 50));
            banner.refreshInterval should equal(REFRESH_INTERVAL_OFF);
            delegate should_not have_received(@selector(bannerCustomEvent:didLoadAd:));
            delegate should_not have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:));
        });

        it(@"should load the banner with a proper request object", ^{
            [event requestAdWithSize:MOPUB_BANNER_SIZE customEventInfo:nil];

            NSDictionary *params = banner.additionaParameters;
            NSString *tpValue = [params objectForKey:@"tp"];
            tpValue should equal(@"c_mopub");
        });

        it(@"should set the location using the InMobi class method", ^{
            [InMobi mp_swizzleSetLocationMethod];
            [event requestAdWithSize:MOPUB_BANNER_SIZE customEventInfo:nil];

            [InMobi mp_getLatitude] should equal((CGFloat)37.1);
            [InMobi mp_getLongitude] should equal((CGFloat)21.2);
            [InMobi mp_getAccuracy] should equal((CGFloat)12.3);
        });

        it(@"should support the rectangular size", ^{
            [event requestAdWithSize:MOPUB_MEDIUM_RECT_SIZE customEventInfo:nil];
            banner.frame should equal(CGRectMake(0, 0, 300, 250));
            banner.adSize should equal(IM_UNIT_300x250);
        });

        it(@"should support the leaderboard size", ^{
            [event requestAdWithSize:MOPUB_LEADERBOARD_SIZE customEventInfo:nil];
            banner.frame should equal(CGRectMake(0, 0, 728, 90));
            banner.adSize should equal(IM_UNIT_728x90);
        });
    });

    context(@"when requesting an ad with an invalid size", ^{
        beforeEach(^{
            [event requestAdWithSize:CGSizeMake(1, 2) customEventInfo:nil];
        });

        it(@"should (immediately) tell the delegate that it failed", ^{
            delegate should have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
        });
    });
});

SPEC_END
