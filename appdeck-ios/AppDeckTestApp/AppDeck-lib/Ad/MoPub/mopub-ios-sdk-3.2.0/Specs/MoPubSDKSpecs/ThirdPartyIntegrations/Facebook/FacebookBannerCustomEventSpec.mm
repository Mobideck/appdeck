#import "FacebookBannerCustomEvent.h"
#import "FakeFBAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPInstanceProvider (FacebookBanners_Spec)

- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID rootViewController:(UIViewController *)controller delegate:(id<FBAdViewDelegate>)delegate;

@end

SPEC_BEGIN(FacebookBannerCustomEventSpec)

describe(@"FacebookBannerCustomEvent", ^{
    __block FacebookBannerCustomEvent *event;
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block FakeFBAdView *banner;

    beforeEach(^{
        banner = [[FakeFBAdView alloc] init];
        fakeProvider.fakeFBAdView = banner.masquerade;

        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        event = [[FacebookBannerCustomEvent alloc] init];
        event.delegate = delegate;
        [event requestAdWithSize:kFBAdSize320x50.size customEventInfo:@{@"placement_id":@"fb_placement"}];
        NSLog(@"%@", banner.placementId);
    });

    it(@"should not allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    describe(@"tracking interactions", ^{
        context(@"when an ad loads", ^{
            beforeEach(^{
                [banner simulateLoadingAd];
            });

            context(@"when the ad subsequently appears onscreen", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [event adViewDidLoad:banner.masquerade];
                });

                it(@"should track an impression", ^{
                    delegate should have_received(@selector(trackImpression));
                });
            });

            describe(@"tracking clicks", ^{
                it(@"should track a click", ^{
                    [banner simulateUserInteraction];
                    delegate should have_received(@selector(trackClick));
                });
            });
        });
    });

    context(@"when asked to fetch a banner", ^{
        it(@"should set the banner's delegate", ^{
            banner.delegate should equal(event);
        });

        context(@"when the size is different than expected size of 320x50", ^{
            it(@"should fail to create the ad", ^{
                [event requestAdWithSize:CGSizeZero customEventInfo:@{@"placement_id":@"fb_placement"}];
                delegate should have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:));
            });
        });
    });
});

SPEC_END
