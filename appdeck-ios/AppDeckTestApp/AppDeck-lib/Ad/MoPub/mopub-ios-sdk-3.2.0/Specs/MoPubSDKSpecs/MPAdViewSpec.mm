#import "MPAdView.h"
#import "MRAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdViewSpec)

describe(@"MPAdView", ^{
    __block MPAdView *adView;

    beforeEach(^{
        adView = [[MPAdView alloc] initWithAdUnitId:@"foo" size:MOPUB_BANNER_SIZE];
    });

    describe(@"loadAd", ^{
        it(@"should tell its manager to begin loading", ^{
            adView.keywords = @"hi=4";
            adView.location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(20, 20)
                                                             altitude:10
                                                   horizontalAccuracy:100
                                                     verticalAccuracy:200
                                                            timestamp:[NSDate date]];
            adView.testing = YES;
            [adView loadAd];

            NSString *requestedPath = fakeCoreProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString;
            requestedPath should contain(@"id=foo");
            requestedPath should contain(@"&q=hi=4");
            requestedPath should contain(@"&ll=20,20");
            requestedPath should contain(@"&lla=100");
            requestedPath should contain(@"http://testing.ads.mopub.com");
        });
    });

    describe(@"orientation locking for third-party SDKs", ^{
        it(@"should default to not locking orientation and be settable and resettable", ^{
            adView.allowedNativeAdsOrientation should equal(MPNativeAdOrientationAny);

            [adView lockNativeAdsToOrientation:MPNativeAdOrientationLandscape];
            adView.allowedNativeAdsOrientation should equal(MPNativeAdOrientationLandscape);

            [adView unlockNativeAdsOrientation];
            adView.allowedNativeAdsOrientation should equal(MPNativeAdOrientationAny);
        });
    });

    describe(@"-adContentViewSize", ^{
        context(@"when there is no content view", ^{
            it(@"should return the original size of the ad view", ^{
                [adView adContentViewSize] should equal(MOPUB_BANNER_SIZE);
            });
        });

        context(@"when there is a content view", ^{
            it(@"should return the size of the content view", ^{
                [adView setAdContentView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 50)]];
                [adView adContentViewSize] should equal(CGSizeMake(40, 50));
            });
        });

        context(@"when the content view is an MRAID view", ^{
            it(@"should return the original size of the ad view (don't ask)", ^{
                MRAdView *mrAdView = [[MPInstanceProvider sharedProvider] buildMRAdViewWithFrame:CGRectMake(0, 0, 40, 50)
                                                                                 allowsExpansion:YES
                                                                                closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                                   placementType:MRAdViewPlacementTypeInline
                                                                                        delegate:nil];
                [adView setAdContentView:mrAdView];
                [adView adContentViewSize] should equal(MOPUB_BANNER_SIZE);
            });
        });
    });
});

SPEC_END
