#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMMAdView.h"
#import "CedarAsync.h"

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
        presentingController = [[UIViewController alloc] init];
        delegate = nice_fake_for(@protocol(MPAdViewDelegate));
        delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);

        banner = [[MPAdView alloc] initWithAdUnitId:@"admob_event" size:MOPUB_BANNER_SIZE];
        banner.delegate = delegate;
        banner.location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                         altitude:11
                                               horizontalAccuracy:12.3
                                                 verticalAccuracy:10
                                                        timestamp:[NSDate date]];
        [banner loadAd];

        fakeAd = [[FakeMMAdView alloc] initWithFrame:CGRectMake(0,0,20,30)];
        fakeProvider.fakeMMAdView = fakeAd;

        NSDictionary *headers = @{kAdTypeHeaderKey: @"millennial_native",
                                  kNativeSDKParametersHeaderKey:@"{\"adUnitID\":\"MILLENNIAL!\",\"adWidth\":300,\"adHeight\":250}"};
        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:headers
                                                                             HTMLString:nil];

        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
        [communicator receiveConfiguration:configuration];
    });

    afterEach(^{
        banner.delegate = nil;
         delegate = nil;
         presentingController = nil;
         banner = nil;
         fakeAd = nil;
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
            in_time(banner.subviews) should equal(@[fakeAd]);
         });

        it(@"should tell the delegate, show the ad, and track an impression (only once)", ^{
            verify_fake_received_selectors_async(delegate, @[@"adViewDidLoadAd:"]);
            banner.adContentViewSize should equal(CGSizeMake(300, 250));
            in_time(fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations) should equal(@[configuration]);

            [fakeAd simulateLoadingAd];
            in_time(fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations) should equal(@[configuration]);
        });

        context(@"when the user taps the ad", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [fakeAd simulateUserTap];
            });

            it(@"should tell the delegate and track a click (just once)", ^{
                in_time(delegate) should have_received(@selector(willPresentModalViewForAd:));
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
                    verify_fake_received_selectors_async(delegate, @[@"didDismissModalViewForAd:"]);
                });
            });
        });

        context(@"when the user taps and leaves the application after a modal", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [fakeAd simulateUserLeavingApplication:YES];
            });

            it(@"should tell the delegate", ^{
                in_time(delegate) should have_received(@selector(willPresentModalViewForAd:));
                delegate should have_received(@selector(willLeaveApplicationFromAd:));
                delegate should have_received(@selector(didDismissModalViewForAd:));
            });
        });

        context(@"when the user taps and leaves the application without a modal", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [fakeAd simulateUserLeavingApplication:NO];
            });

            it(@"should tell the delegate", ^{
                in_time(delegate) should have_received(@selector(willPresentModalViewForAd:));
                delegate should have_received(@selector(willLeaveApplicationFromAd:));
                delegate should have_received(@selector(didDismissModalViewForAd:));
            });
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [fakeAd simulateFailingToLoad];
        });

        it(@"should start the waterfall", ^{
            in_time(communicator.loadedURL) should equal(configuration.failoverURL);
        });
    });
});

SPEC_END
