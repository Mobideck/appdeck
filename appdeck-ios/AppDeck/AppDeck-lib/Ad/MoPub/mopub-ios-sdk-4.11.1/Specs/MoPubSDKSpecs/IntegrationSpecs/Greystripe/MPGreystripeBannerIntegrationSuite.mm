#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
#import "FakeGSBannerAdView.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPGreystripeBannerIntegrationSuite)

describe(@"MPGreystripeBannerIntegrationSuite", ^{
    __block FakeGSBannerAdView *fakeAd;
    __block MPAdConfiguration *configuration;

    __block MPAdView *banner;
    __block id<CedarDouble, MPAdViewDelegate> delegate;
    __block UIViewController *presentingController;
    __block FakeMPAdServerCommunicator *communicator;

    beforeEach(^{
        presentingController = [[UIViewController alloc] init];
        delegate = nice_fake_for(@protocol(MPAdViewDelegate));
        delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);

        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"GreystripeBannerCustomEvent"];
    });

    describe(@"with a valid size", ^{
        beforeEach(^{
            fakeAd = [[FakeGSBannerAdView alloc] init];
            fakeProvider.fakeGSBannerAdView = fakeAd;

            banner = [[MPAdView alloc] initWithAdUnitId:@"greystripe_banner" size:MOPUB_BANNER_SIZE];
            banner.delegate = delegate;
            [banner loadAd];

            communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
            [communicator receiveConfiguration:configuration];
        });

        it(@"should ask the ad to load", ^{
            fakeAd.didFetch should equal(YES);
        });

        it(@"should pass the view controller along", ^{
            fakeAd.delegate.greystripeBannerDisplayViewController should equal(presentingController);
        });

        context(@"when the ad loads succesfully", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [fakeAd simulateLoadingAd];
            });

            it(@"should tell the delegate, show the ad, and track an impression", ^{
                verify_fake_received_selectors(delegate, @[@"adViewDidLoadAd:"]);
                banner.subviews should equal(@[fakeAd]);
                banner.adContentViewSize should equal(fakeAd.frame.size);
                fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should equal(@[configuration]);
            });

            context(@"when the user taps the ad", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeAd simulateUserTap];
                });

                it(@"should tell the delegate and track a click (just once)", ^{
                    verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should equal(@[configuration]);

                    [fakeAd simulateUserTap];
                    fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should equal(@[configuration]);
                });

                context(@"when the user dismisses the modal", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [fakeAd simulateUserEndingInteraction];
                    });

                    it(@"should tell the delegate", ^{
                        verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:"]);
                    });
                });
            });
        });

        context(@"when the ad fails to load", ^{
            beforeEach(^{
                [fakeAd simulateFailingToLoad];
            });

            it(@"should start the waterfall", ^{
                communicator.loadedURL should equal(configuration.failoverURL);
            });
        });
    });

    describe(@"with an invalid size", ^{
        beforeEach(^{
            banner = [[MPAdView alloc] initWithAdUnitId:@"greystripe_banner" size:CGSizeMake(1,2)];
            banner.delegate = delegate;
            [banner loadAd];

            communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
            [communicator receiveConfiguration:configuration];
        });

        it(@"should immediately fail and start the waterfall", ^{
            communicator.loadedURL should equal(configuration.failoverURL);
        });
    });
});

SPEC_END
