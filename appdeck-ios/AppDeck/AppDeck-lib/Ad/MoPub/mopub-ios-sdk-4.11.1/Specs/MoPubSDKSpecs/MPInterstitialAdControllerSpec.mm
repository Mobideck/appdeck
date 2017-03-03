#import "MPInterstitialAdController.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialAdControllerSpec)

describe(@"MPInterstitialAdController", ^{
    __block MPInterstitialAdController *controller;

    context(@"when asking for a shared interstitial", ^{
        context(@"if an interstitial already exists for the given ad unit ID", ^{
            it(@"should return the same instance", ^{
                controller = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"guy1"];
                MPInterstitialAdController *another = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"guy1"];
                controller should be_same_instance_as(another);
                controller.adUnitId should equal(@"guy1");
            });
        });
    });

    describe(@"removing shared interstitials", ^{
        context(@"if the interstitial exists", ^{
            it(@"should not return that interstitial ever again", ^{
                controller = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"guy1"];
                [MPInterstitialAdController removeSharedInterstitialAdController:controller];
                MPInterstitialAdController *another = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"guy1"];
                another should_not be_same_instance_as(controller);
            });
        });

        context(@"if the interstitial does not exist", ^{
            it(@"should not blow up", ^{
                controller = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"guy1"];
                [MPInterstitialAdController removeSharedInterstitialAdController:nil];
            });
        });
    });

    describe(@"loadAd", ^{
        it(@"should tell its manager to begin loading", ^{
            controller = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"guy1"];
            controller.keywords = @"hi=4";
            controller.location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(20, 20)
                                                                 altitude:10
                                                       horizontalAccuracy:100
                                                         verticalAccuracy:200
                                                                timestamp:[NSDate date]];
            controller.testing = YES;
            [controller loadAd];

            NSString *requestedPath = fakeCoreProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString;
            requestedPath should contain(@"id=guy1");
            requestedPath should contain(@"&q=hi=4");
            requestedPath should contain(@"&ll=20,20");
            requestedPath should contain(@"&lla=100");
            requestedPath should contain(@"https://testing.ads.mopub.com");
        });
    });

    describe(@"showFromViewController:", ^{
        __block MPInterstitialAdManager<CedarDouble> *manager;

        beforeEach(^{
            manager = nice_fake_for([MPInterstitialAdManager class]);
            fakeProvider.fakeMPInterstitialAdManager = manager;
            controller = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"guy1"];
        });

        context(@"when passed a nil view controller", ^{
            it(@"should not tell its manager to present anything", ^{
                [controller showFromViewController:nil];
                manager should_not have_received(@selector(presentInterstitialFromViewController:));
            });
        });

        context(@"when passed a valid view controller", ^{
            __block UIViewController *presentingViewController;

            beforeEach(^{
                presentingViewController = [[UIViewController alloc] init];
            });

            it(@"should tell its manager to present an interstitial from that view controller", ^{
                [controller showFromViewController:presentingViewController];
                manager should have_received(@selector(presentInterstitialFromViewController:)).with(presentingViewController);
            });
        });
    });
});

SPEC_END
