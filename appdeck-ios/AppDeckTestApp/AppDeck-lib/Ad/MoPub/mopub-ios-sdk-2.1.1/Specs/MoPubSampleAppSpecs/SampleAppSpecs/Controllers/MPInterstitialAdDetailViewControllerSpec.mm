#import "MPInterstitialAdDetailViewController.h"
#import "MPAdInfo.h"
#import "FakeMPInterstitialAdController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialAdDetailViewControllerSpec)

describe(@"MPInterstitialAdDetailViewController", ^{
    __block MPInterstitialAdDetailViewController *controller;
    __block MPAdInfo *interstitialAdInfo;
    __block FakeMPInterstitialAdController *interstitial;

    beforeEach(^{
        interstitialAdInfo = [MPAdInfo infoWithTitle:@"foo" ID:@"bar" type:MPAdInfoInterstitial];
        controller = [[[MPInterstitialAdDetailViewController alloc] initWithAdInfo:interstitialAdInfo] autorelease];
        controller.view should_not be_nil;

        interstitial = fakeProvider.lastFakeInterstitialAdController;
    });

    it(@"should configure its labels and buttons", ^{
        controller.titleLabel.text should equal(@"foo");
        controller.IDLabel.text should equal(@"bar");
        controller.showButton.hidden should equal(YES);
        controller.spinner.isAnimating should equal(NO);
    });

    describe(@"its interstitial", ^{
        it(@"should have an ad unit ID and delegate set", ^{
            interstitial.adUnitId should equal(@"bar");
            interstitial.delegate should equal(controller);
        });
    });

    context(@"when the load button is tapped", ^{
        beforeEach(^{
            [controller.loadButton tap];
        });

        it(@"should disable the load button", ^{
            controller.loadButton.enabled should equal(NO);
        });

        it(@"should make all of the callback labels transparent", ^{
            controller.willAppearLabel.alpha should be_less_than(0.5);
            controller.didAppearLabel.alpha should be_less_than(0.5);
            controller.willDisappearLabel.alpha should be_less_than(0.5);
            controller.didDisappearLabel.alpha should be_less_than(0.5);
        });

        it(@"should tell the ad view to load", ^{
            interstitial.wasLoaded should equal(YES);
        });

        it(@"should have a spinner and hide the show button", ^{
            controller.spinner.isAnimating should equal(YES);
            controller.showButton.hidden should equal(YES);
        });

        context(@"when the interstitial arrives", ^{
            beforeEach(^{
                [interstitial.delegate interstitialDidLoadAd:interstitial];
            });

            it(@"should hide the spinner and un-hide the show button", ^{
                controller.spinner.isAnimating should equal(NO);
                controller.showButton.hidden should equal(NO);
            });

            it(@"should re-enable the load button", ^{
                controller.loadButton.enabled should equal(YES);
            });

            context(@"when the user taps show", ^{
                beforeEach(^{
                    [controller.showButton tap];
                });

                it(@"should present the interstitial", ^{
                    interstitial.presenter should equal(controller);
                });

                context(@"when receiving interstitial callbacks", ^{
                    it(@"should display the appropriate labels", ^{
                        [interstitial.delegate interstitialWillAppear:interstitial];
                        controller.willAppearLabel.alpha should equal(1);

                        [interstitial.delegate interstitialDidAppear:interstitial];
                        controller.didAppearLabel.alpha should equal(1);

                        [interstitial.delegate interstitialWillDisappear:interstitial];
                        controller.willDisappearLabel.alpha should equal(1);

                        [interstitial.delegate interstitialDidDisappear:interstitial];
                        controller.didDisappearLabel.alpha should equal(1);
                    });
                });

                context(@"when the interstitial is dismissed", ^{
                    beforeEach(^{
                        [interstitial.delegate interstitialDidDisappear:interstitial];
                    });

                    it(@"should hide the show button", ^{
                        controller.showButton.hidden should equal(YES);
                    });
                });
            });

            context(@"when the interstitial expires", ^{
                beforeEach(^{
                    [interstitial.delegate interstitialDidExpire:interstitial];
                });

                it(@"should hide the show button and show the expired label", ^{
                    controller.showButton.hidden should equal(YES);
                    controller.expireLabel.hidden should equal(NO);
                });
            });

        });

        context(@"when the interstitial expires", ^{
            beforeEach(^{
                [interstitial.delegate interstitialDidExpire:interstitial];
            });

            it(@"should hide the spinner and show the expired label", ^{
                controller.spinner.isAnimating should equal(NO);
                controller.expireLabel.hidden should equal(NO);
            });

            it(@"should reenable the load button", ^{
                controller.loadButton.enabled should equal(YES);
            });

            context(@"when the user taps load again", ^{
                beforeEach(^{
                    interstitial.wasLoaded = NO;
                    [controller.loadButton tap];
                });

                it(@"should hide the expired label", ^{
                    controller.expireLabel.hidden should equal(YES);
                });
            });
        });

        context(@"when the interstitial fails to arrive", ^{
            beforeEach(^{
                [interstitial.delegate interstitialDidFailToLoadAd:interstitial];
            });

            it(@"should hide the spinner and show the fail label", ^{
                controller.spinner.isAnimating should equal(NO);
                controller.failLabel.hidden should equal(NO);
            });

            it(@"should reenable the load button", ^{
                controller.loadButton.enabled should equal(YES);
            });

            context(@"when the user taps load again", ^{
                beforeEach(^{
                    interstitial.wasLoaded = NO;
                    [controller.loadButton tap];
                });

                it(@"should hide the fail label", ^{
                    controller.failLabel.hidden should equal(YES);
                });
            });
        });
    });
});

SPEC_END
