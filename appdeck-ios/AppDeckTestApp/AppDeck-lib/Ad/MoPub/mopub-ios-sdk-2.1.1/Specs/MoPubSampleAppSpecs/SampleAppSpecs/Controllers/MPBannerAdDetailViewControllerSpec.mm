#import "MPBannerAdDetailViewController.h"
#import "MPAdInfo.h"
#import "FakeMPAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerAdDetailViewControllerSpec)

describe(@"MPBannerAdDetailViewController", ^{
    __block MPBannerAdDetailViewController *controller;
    __block MPAdInfo *bannerAdInfo;
    __block FakeMPAdView *adView;

    beforeEach(^{
        bannerAdInfo = [MPAdInfo infoWithTitle:@"foo" ID:@"bar" type:MPAdInfoBanner];
        controller = [[[MPBannerAdDetailViewController alloc] initWithAdInfo:bannerAdInfo] autorelease];
        controller.view should_not be_nil;

        adView = fakeProvider.lastFakeAdView;
    });

    it(@"should configure its labels", ^{
        controller.titleLabel.text should equal(@"foo");
        controller.IDLabel.text should equal(@"bar");
    });

    describe(@"its ad view", ^{
        it(@"should have an ad unit ID and delegate set", ^{
            adView.adUnitId should equal(@"bar");
            adView.delegate should equal(controller);
        });

        it(@"should be added to the ad view container", ^{
            controller.adViewContainer.subviews.lastObject should equal(adView);
        });
    });

    describe(@"MPAdViewDelegate methods", ^{
        it(@"should return a view controller for presenting modal views", ^{
            [adView.delegate viewControllerForPresentingModalView] should equal(controller);
        });
    });

    context(@"when its orientation changes", ^{
        it(@"should tell the ad view", ^{
            [controller willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:1.0];
            adView.orientation should equal(UIInterfaceOrientationLandscapeLeft);
        });
    });

    context(@"when its view has appeared", ^{
        beforeEach(^{
            adView.wasLoaded should equal(NO);
            [controller viewDidAppear:NO];
        });

        it(@"should tell the ad view to load", ^{
            adView.wasLoaded should equal(YES);
        });

        it(@"should have a spinner", ^{
            controller.spinner.isAnimating should equal(YES);
        });

        context(@"when the ad arrives", ^{
            beforeEach(^{
                [adView.delegate adViewDidLoadAd:adView];
            });

            it(@"should hide the spinner", ^{
                controller.spinner.isAnimating should equal(NO);
            });
        });

        context(@"when the ad fails to arrive", ^{
            beforeEach(^{
                [adView.delegate adViewDidFailToLoadAd:adView];
            });

            it(@"should hide the spinner and show the fail label", ^{
                controller.spinner.isAnimating should equal(NO);
                controller.failLabel.hidden should equal(NO);
            });
        });

        context(@"when the view appears again", ^{
            it(@"should not tell the ad to reload", ^{
                adView.wasLoaded = NO;
                [controller viewDidAppear:NO];
                adView.wasLoaded should equal(NO);
            });
        });
    });
});

SPEC_END
