#import "MPInterstitialAdController.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPAdServerCommunicator.h"
#import "FakeGADInterstitial.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPGoogleAdMobIntegrationSuite)

describe(@"MPGoogleAdMobIntegrationSuite", ^{
    __block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;
    __block MPInterstitialAdController *interstitial = nil;
    __block UIViewController *presentingController;
    __block FakeGADInterstitial *fakeGADInterstitial;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;
    __block GADRequest<CedarDouble> *fakeGADInterstitialRequest;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialAdControllerDelegate));

        interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"admob_interstitial"];
        interstitial.location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                               altitude:11
                                                     horizontalAccuracy:12.3
                                                       verticalAccuracy:10
                                                              timestamp:[NSDate date]];
        interstitial.delegate = delegate;

        presentingController = [[UIViewController alloc] init];

        // request an Ad
        [interstitial loadAd];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        communicator.loadedURL.absoluteString should contain(@"admob_interstitial");

        // prepare the fake and tell the injector about it
        fakeGADInterstitial = [[FakeGADInterstitial alloc] init];
        fakeProvider.fakeGADInterstitial = fakeGADInterstitial.masquerade;
        fakeGADInterstitialRequest = nice_fake_for([GADRequest class]);
        fakeProvider.fakeGADInterstitialRequest = fakeGADInterstitialRequest;

        // receive the configuration -- this will create an adapter which will use our fake interstitial
        NSDictionary *headers = @{kInterstitialAdTypeHeaderKey: @"admob_full",
                                  kNativeSDKParametersHeaderKey:@"{\"adUnitID\":\"g00g1e\"}"};
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers HTMLString:nil];
        [communicator receiveConfiguration:configuration];

        // clear out the communicator so we can make future assertions about it
        [communicator resetLoadedURL];

        setUpInterstitialSharedContext(communicator, delegate, interstitial, @"admob_interstitial", fakeGADInterstitial, configuration.failoverURL);
    });

    it(@"should set up the google ad request correctly", ^{
        fakeGADInterstitial.adUnitID should equal(@"g00g1e");
        fakeGADInterstitialRequest should have_received(@selector(setLocationWithLatitude:longitude:accuracy:)).with((CGFloat)37.1).and_with((CGFloat)21.2).and_with((CGFloat)12.3);
    });

    context(@"while the ad is loading", ^{
        beforeEach(^{
            fakeGADInterstitial.loadedRequest should_not be_nil;
        });

        it(@"should not tell the delegate anything, nor should it be ready", ^{
            delegate.sent_messages should be_empty;
            interstitial.ready should equal(NO);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatPreventsLoading); });
        context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatTimesOut); });
    });

    context(@"when the ad successfully loads", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [fakeGADInterstitial simulateLoadingAd];
        });

        it(@"should tell the delegate and -ready should return YES", ^{
            verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
            interstitial.ready should equal(YES);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });

        context(@"and the user shows the ad", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                [interstitial showFromViewController:presentingController];
            });

            it(@"should track an impression and tell AdMob to show", ^{
                verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                fakeGADInterstitial.presentingViewController should equal(presentingController);
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });

            context(@"when the user interacts with the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                });

                it(@"should track only one click, no matter how many interactions there are, and should tell the delegate about each click", ^{
                    [fakeGADInterstitial simulateUserInteraction];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);
                    [fakeGADInterstitial simulateUserInteraction];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations.count should equal(1);

                    delegate.sent_messages.count should equal(2);
                });
            });

            context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatHasAlreadyLoaded); });

            context(@"and the user tries to show (again)", ^{
                __block UIViewController *newPresentingController;

                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];

                    newPresentingController = [[UIViewController alloc] init];
                    [interstitial showFromViewController:newPresentingController];
                });

                it(@"should tell AdMob to show and send the delegate messages again", ^{
                    // XXX: The "ideal" behavior here is to ignore any -show messages after the first one, until the
                    // underlying ad is dismissed. However, given the risk that some third-party or custom event
                    // network could give us a silent failure when presenting (and therefore never dismiss), it might
                    // be best just to allow multiple calls to go through.

                    fakeGADInterstitial.presentingViewController should equal(newPresentingController);
                    verify_fake_received_selectors(delegate, @[@"interstitialWillAppear:", @"interstitialDidAppear:"]);
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(0);
                });
            });

            context(@"when the ad is dismissed", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeGADInterstitial simulateUserDismissingAd];
                });

                it(@"should tell the delegate and should no longer be ready", ^{
                    verify_fake_received_selectors(delegate, @[@"interstitialWillDisappear:", @"interstitialDidDisappear:"]);
                    interstitial.ready should equal(NO);
                });

                context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
                context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
            });
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [fakeGADInterstitial simulateFailingToLoad];
        });

        itShouldBehaveLike(anInterstitialThatLoadsTheFailoverURL);
        context(@"and the timeout interval elapses", ^{ itShouldBehaveLike(anInterstitialThatDoesNotTimeOut); });
    });
});

SPEC_END
