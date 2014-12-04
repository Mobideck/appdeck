#import "MPManualAdViewController.h"
#import "FakeMPInterstitialAdController.h"
#import "FakeMPAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPManualAdViewControllerSpec)

describe(@"MPManualAdViewController", ^{
    __block MPManualAdViewController *controller;
    __block FakeMPInterstitialAdController *interstitial;

    __block UIButton *loadButton;
    __block UIButton *showButton;
    __block UILabel *statusLabel;
    __block UIActivityIndicatorView *spinner;
    __block UITextField *textField;

    beforeEach(^{
        controller = [[[MPManualAdViewController alloc] init] autorelease];
        controller.view should_not be_nil;
    });

    sharedExamplesFor(@"an interstitial manager", ^(NSDictionary *sharedContext) {
        context(@"when the load button is tapped", ^{
            beforeEach(^{
                [textField setText:@"fluffy pandas"];
                [loadButton tap];
                interstitial = fakeProvider.lastFakeInterstitialAdController;
            });

            it(@"should disable the load button", ^{
                loadButton.enabled should equal(NO);
            });

            it(@"should tell the ad view to load", ^{
                interstitial.adUnitId should equal(@"fluffy pandas");
                interstitial.wasLoaded should equal(YES);
            });

            it(@"should have a spinner and hide the show button", ^{
                spinner.isAnimating should equal(YES);
                showButton.hidden should equal(YES);
            });

            context(@"when the interstitial arrives", ^{
                beforeEach(^{
                    [interstitial.delegate interstitialDidLoadAd:interstitial];
                });

                it(@"should hide the spinner and un-hide the show button", ^{
                    spinner.isAnimating should equal(NO);
                    showButton.hidden should equal(NO);
                });

                it(@"should re-enable the load button", ^{
                    loadButton.enabled should equal(YES);
                });

                context(@"when the user taps show", ^{
                    beforeEach(^{
                        [showButton tap];
                    });

                    it(@"should present the interstitial", ^{
                        interstitial.presenter should equal(controller);
                    });

                    context(@"when the interstitial is dismissed", ^{
                        beforeEach(^{
                            [interstitial.delegate interstitialDidDisappear:interstitial];
                        });

                        it(@"should hide the show button", ^{
                            showButton.hidden should equal(YES);
                        });
                    });
                });

                context(@"when the interstitial expires", ^{
                    beforeEach(^{
                        [interstitial.delegate interstitialDidExpire:interstitial];
                    });

                    it(@"should hide the show button and show the expired label", ^{
                        showButton.hidden should equal(YES);
                        statusLabel.text should equal(@"Expired");
                    });

                    context(@"when the user taps load again", ^{
                        beforeEach(^{
                            [loadButton tap];
                        });

                        it(@"should hide the expired label", ^{
                            statusLabel.text should equal(@"");
                        });
                    });
                });

            });

            context(@"when the interstitial fails to arrive", ^{
                beforeEach(^{
                    [interstitial.delegate interstitialDidFailToLoadAd:interstitial];
                });

                it(@"should hide the spinner and show the fail label", ^{
                    spinner.isAnimating should equal(NO);
                    statusLabel.text should equal(@"Failed");
                });

                it(@"should reenable the load button", ^{
                    loadButton.enabled should equal(YES);
                });

                context(@"when the user taps load again", ^{
                    beforeEach(^{
                        [loadButton tap];
                    });

                    it(@"should hide the fail label", ^{
                        statusLabel.text should equal(@"");
                    });
                });
            });
        });
    });

    context(@"the first interstitial", ^{
        beforeEach(^{
            loadButton = controller.firstInterstitialLoadButton;
            showButton = controller.firstInterstitialShowButton;
            statusLabel = controller.firstInterstitialStatusLabel;
            textField = controller.firstInterstitialTextField;
            spinner = controller.firstInterstitialActivityIndicator;
        });

        itShouldBehaveLike(@"an interstitial manager");
    });


    context(@"the second interstitial", ^{
        beforeEach(^{
            loadButton = controller.secondInterstitialLoadButton;
            showButton = controller.secondInterstitialShowButton;
            statusLabel = controller.secondInterstitialStatusLabel;
            textField = controller.secondInterstitialTextField;
            spinner = controller.secondInterstitialActivityIndicator;
        });

        itShouldBehaveLike(@"an interstitial manager");
    });

    context(@"the banner", ^{
        __block FakeMPAdView *adView;

        beforeEach(^{
            loadButton = controller.bannerLoadButton;
            textField = controller.bannerTextField;
            spinner = controller.bannerActivityIndicator;
            statusLabel = controller.bannerStatusLabel;
        });

        context(@"when the load button is tapped", ^{
            beforeEach(^{
                statusLabel.text = @"something";
                textField.text = @"fluffy bears";
                [loadButton tap];
                
                adView = fakeProvider.lastFakeAdView;
            });

            it(@"should put the adView in the view hierarchy", ^{
                controller.bannerContainer.subviews.lastObject should equal(adView);
            });
            
            it(@"should tell the banner to load", ^{
                adView.adUnitId should equal(textField.text);
                adView.wasLoaded should equal(YES);
            });

            it(@"should show the spinner and clear out the status label", ^{
                spinner.isAnimating should equal(YES);
                statusLabel.text should equal(@"");
            });

            context(@"when the ad arrives", ^{
                beforeEach(^{
                    [adView.delegate adViewDidLoadAd:adView];
                });

                it(@"should hide the spinner", ^{
                    spinner.isAnimating should equal(NO);
                });
            });

            context(@"when the ad fails to arrive", ^{
                beforeEach(^{
                    [adView.delegate adViewDidFailToLoadAd:adView];
                });

                it(@"should hide the spinner update the status label", ^{
                    statusLabel.text should equal(@"Failed");
                    spinner.isAnimating should equal(NO);
                });
            });
        });
    });
});

SPEC_END
