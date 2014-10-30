#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMMAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMillennialBannerIntegrationSuite)

describe(@"MPMillennialBannerIntegrationSuite", ^{
    __block FakeMMAdView *fakeAd;
    __block MPAdConfiguration *configuration;

    __block MPAdView *banner;
    __block id<CedarDouble, MPAdViewDelegate> delegate;
    __block UIViewController *presentingController;
    __block FakeMPAdServerCommunicator *communicator;

    beforeEach(^{
        presentingController = [[[UIViewController alloc] init] autorelease];
        delegate = nice_fake_for(@protocol(MPAdViewDelegate));
        delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);

        banner = [[[MPAdView alloc] initWithAdUnitId:@"admob_event" size:MOPUB_BANNER_SIZE] autorelease];
        banner.delegate = delegate;
        banner.location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                         altitude:11
                                               horizontalAccuracy:12.3
                                                 verticalAccuracy:10
                                                        timestamp:[NSDate date]] autorelease];
        [banner loadAd];

        fakeAd = [[[FakeMMAdView alloc] initWithFrame:CGRectMake(0,0,20,30)] autorelease];
        fakeProvider.fakeMMAdView = fakeAd;

        NSDictionary *headers = @{kAdTypeHeaderKey: @"millennial_native",
                                  kNativeSDKParametersHeaderKey:@"{\"adUnitID\":\"MILLENNIAL!\",\"adWidth\":300,\"adHeight\":250}"};
        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:headers
                                                                             HTMLString:nil];

        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        [communicator receiveConfiguration:configuration];
    });


    it(@"should ask the ad to load", ^{
        fakeAd.apid should equal(@"MILLENNIAL!");
        fakeAd.rootViewController should equal(presentingController);
        fakeAd.frame should equal(CGRectMake(0, 0, 300, 250));
        fakeAd.request.location should equal(banner.location);
    });

    context(@"when the ad loads succesfully", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [fakeAd simulateLoadingAd];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        });

        it(@"should tell the delegate, show the ad, and track an impression (only once)", ^{
            verify_fake_received_selectors(delegate, @[@"adViewDidLoadAd:"]);
            banner.subviews should equal(@[fakeAd]);
            banner.adContentViewSize should equal(CGSizeMake(300, 250));
            fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should equal(@[configuration]);

            [fakeAd simulateLoadingAd];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
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
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        });

        it(@"should start the waterfall", ^{
            communicator.loadedURL should equal(configuration.failoverURL);
        });
    });
});

SPEC_END
