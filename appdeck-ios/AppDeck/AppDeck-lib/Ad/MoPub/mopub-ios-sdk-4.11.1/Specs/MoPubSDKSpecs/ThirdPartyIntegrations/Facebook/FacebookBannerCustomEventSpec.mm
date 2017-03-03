#import "FacebookBannerCustomEvent.h"
#import "FakeFBAdView.h"
#import "FBAdView+Specs.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPInstanceProvider (FacebookBanners_Spec)

- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID size:(FBAdSize)size rootViewController:(UIViewController *)controller delegate:(id<FBAdViewDelegate>)delegate;

@end

@interface FacebookBannerCustomEvent (Specs) <FBAdViewDelegate>

@property (nonatomic, strong) FBAdView *fbAdView;

@end

SPEC_BEGIN(FacebookBannerCustomEventSpec)

describe(@"FacebookBannerCustomEvent", ^{
    __block FacebookBannerCustomEvent *event;
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block FakeFBAdView *banner;
    __block UIViewController *presentingViewController;
    beforeEach(^{
        banner = [[FakeFBAdView alloc] init];
        fakeProvider.fakeFBAdView = banner.masquerade;

        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        presentingViewController = [[UIViewController alloc] init];
        delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingViewController);
        event = [[FacebookBannerCustomEvent alloc] init];
        event.delegate = delegate;
        [event requestAdWithSize:kFBAdSize320x50.size customEventInfo:@{@"placement_id":@"fb_placement"}];
        NSLog(@"%@", banner.placementId);
    });

    it(@"should not allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    it(@"should disable automatic refresh of the FBAdView", ^{
        fakeProvider.fakeFBAdView = nil;
        [FBAdView autoRefreshWasDisabled] should be_falsy;
        [event requestAdWithSize:kFBAdSize320x50.size customEventInfo:@{@"placement_id":@"fb_placement"}];
        [FBAdView autoRefreshWasDisabled] should be_truthy;
        [FBAdView resetAutoRefreshWasDisabledValue];
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

    describe(@"interacting with the ad", ^{
        context(@"when the ad is clicked", ^{
            beforeEach(^{
                [banner simulateLoadingAd];
                [banner simulateUserInteraction];
            });

            it(@"should tell the delegate an action is beginning", ^{
                delegate should have_received(@selector(bannerCustomEventWillBeginAction:)).with(event);
            });

            context(@"when the ad has finished handling the click", ^{
                beforeEach(^{
                    [banner simulateUserInteractionFinished];
                });

                it(@"should let the delegate know that the action has finished", ^{
                    delegate should have_received(@selector(bannerCustomEventDidFinishAction:)).with(event);
                });
            });
        });

        context(@"when interacting with the delegate's viewControllerForPresentingModalView", ^{
            it(@"should implement viewControllerForPresentingModalView and return its delegate's value for the same method", ^{
                [event viewControllerForPresentingModalView] should equal(presentingViewController);
            });

            it(@"should return the new view controller in viewControllerForPresentingModalView if it has a new delegate", ^{
                UIViewController *newPresentingViewController = [[UIViewController alloc] init];
                id<CedarDouble, MPBannerCustomEventDelegate> newDelegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));
                newDelegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(newPresentingViewController);
                event.delegate = newDelegate;
                [event viewControllerForPresentingModalView] should equal(newPresentingViewController);

            });
        });
    });

    context(@"when asked to fetch a banner", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            spy_on([FakeMPInstanceProvider sharedProvider]);
        });

        it(@"should set the banner's delegate", ^{
            banner.delegate should equal(event);
        });

        context(@"when the size is different than expected size of 320x50, 300x250, and flexible widths with heights of 50 or 90", ^{
            it(@"should fail to create the ad", ^{
                [event requestAdWithSize:CGSizeZero customEventInfo:@{@"placement_id":@"fb_placement"}];
                delegate should have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:));
            });
        });

        context(@"when the size is flexible width with a height of 50", ^{
            it(@"should create an ad", ^{
                [event requestAdWithSize:CGSizeMake(1024, 50) customEventInfo:@{@"placement_id":@"fb_placement"}];
                delegate should have_received(@selector(bannerCustomEvent:didLoadAd:));
            });

            it(@"should match the height of FBAdSize constant kFBAdSizeHeight50Banner", ^{
                fakeProvider.fakeFBAdView = nil;
                [event requestAdWithSize:CGSizeMake(1024, 50) customEventInfo:@{@"placement_id":@"fb_placement"}];
                [event.fbAdView fbAdSize].size.height should equal(kFBAdSizeHeight50Banner.size.height);
            });

            it (@"should match the desired width passed into requestAdWithSize:customEventInfo:", ^{
                fakeProvider.fakeFBAdView = nil;
                [event requestAdWithSize:CGSizeMake(728, 50) customEventInfo:@{@"placement_id":@"fb_placement"}];
                event.fbAdView.bounds.size.width should equal(728);
            });
        });

        context(@"when the size is flexible width with a height of 90", ^{
            it(@"should create an ad", ^{
                [event requestAdWithSize:CGSizeMake(1024, 90) customEventInfo:@{@"placement_id":@"fb_placement"}];
                delegate should have_received(@selector(bannerCustomEvent:didLoadAd:));
            });

            it(@"should match the height of FBAdSize constant kFBAdSizeHeight90Banner", ^{
                fakeProvider.fakeFBAdView = nil;
                [event requestAdWithSize:CGSizeMake(1024, 90) customEventInfo:@{@"placement_id":@"fb_placement"}];
                [event.fbAdView fbAdSize].size.height should equal(kFBAdSizeHeight90Banner.size.height);
            });

            it (@"should match the desired width passed into requestAdWithSize:customEventInfo:", ^{
                fakeProvider.fakeFBAdView = nil;
                [event requestAdWithSize:CGSizeMake(728, 90) customEventInfo:@{@"placement_id":@"fb_placement"}];
                event.fbAdView.bounds.size.width should equal(728);
            });
        });

        context(@"when the size is 300x250", ^{
            it(@"should create an ad", ^{
                [event requestAdWithSize:CGSizeMake(300, 250) customEventInfo:@{@"placement_id":@"fb_placement"}];
                delegate should have_received(@selector(bannerCustomEvent:didLoadAd:));
            });

            it(@"should match the size of FBAdSize constant kFBAdSizeHeight250Rectangle", ^{
                fakeProvider.fakeFBAdView = nil;
                [event requestAdWithSize:CGSizeMake(300, 250) customEventInfo:@{@"placement_id":@"fb_placement"}];
                [event.fbAdView fbAdSize].size should equal(kFBAdSizeHeight250Rectangle.size);
            });
        });

        context(@"when the size is 320x50", ^{
            it(@"should create an ad", ^{
                [event requestAdWithSize:CGSizeMake(320, 50) customEventInfo:@{@"placement_id":@"fb_placement"}];
                delegate should have_received(@selector(bannerCustomEvent:didLoadAd:));
            });

            it(@"should match the size of FBAdSize constant kFBAdSize320x50", ^{
                fakeProvider.fakeFBAdView = nil;
                [event requestAdWithSize:CGSizeMake(320, 50) customEventInfo:@{@"placement_id":@"fb_placement"}];
                [event.fbAdView fbAdSize].size should equal(kFBAdSize320x50.size);
            });
        });
    });
});

SPEC_END
