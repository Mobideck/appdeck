#import "MPNativeAdRequest.h"
#import "MPNativeAd+Specs.h"
#import "MPNativeAdRendering.h"
#import "MPAdConfigurationFactory.h"
#import "NSJSONSerialization+MPAdditions.h"
#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAd+Internal.h"
#import "UIView+MPNativeAd.h"
#import "MPNativeAdDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface AdView : UIView <MPNativeAdRendering>

@end

@implementation AdView

- (void)layoutAdAssets:(MPNativeAd *)adObject
{

}

@end

SPEC_BEGIN(MPNativeAdSpec)

describe(@"MPNativeAd", ^{
    __block MPNativeAd *nativeAd;
    __block MPAdConfiguration *configuration;
    __block AdView *adView;
    __block MPMoPubNativeAdAdapter *adAdapter;

    beforeEach(^{
        configuration = [MPAdConfigurationFactory defaultNativeAdConfiguration];

        NSDictionary *properties = [NSJSONSerialization mp_JSONObjectWithData:configuration.adResponseData options:0 clearNullObjects:YES error:nil];
        adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[properties mutableCopy]];
        nativeAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
        adView =  [[AdView alloc] init];
        [MPNativeAd mp_clearTrackMetricURLCallsCount];
    });

    context(@"ad configuration", ^{

        it(@"should use the default requiredSecondsForImpression", ^{
            nativeAd.requiredSecondsForImpression should equal(1.0);
        });

        it(@"should configure properties correctly", ^{
            [nativeAd.properties allKeys] should contain(@"ctatext");
            [nativeAd.properties allKeys] should contain(@"iconimage");
            [nativeAd.properties allKeys] should contain(@"mainimage");
            [nativeAd.properties allKeys] should contain(@"text");
            [nativeAd.properties allKeys] should contain(@"title");
        });

        it(@"should have a default action URL", ^{
            nativeAd.defaultActionURL should equal(adAdapter.defaultActionURL);
        });

        it(@"should not have engagement or impression tracker URLS", ^{
            // It is not the responsibility of the mpnative ad to fill in the URLs.
            nativeAd.engagementTrackingURL should be_nil;
            nativeAd.impressionTrackers.count should equal(0);
        });

        context(@"star rating", ^{
            __block id<CedarDouble, MPNativeAdAdapter> nativeAdAdapter;
            __block MPNativeAd *starRatingNativeAd;

            beforeEach(^{
                nativeAdAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
                starRatingNativeAd = [[MPNativeAd alloc] initWithAdAdapter:nativeAdAdapter];
            });

            it(@"should return a valid star rating object if the backing ad provides a valid value", ^{
                nativeAdAdapter stub_method("properties").and_return(@{@"starrating":@4.5f});
                starRatingNativeAd.starRating.floatValue should equal(4.5f);
            });

            it(@"should return a valid star rating object if the backing ad provides the minimum valid value", ^{
                nativeAdAdapter stub_method("properties").and_return(@{@"starrating":@0});
                starRatingNativeAd.starRating.floatValue should equal(0);
            });

            it(@"should return a valid star rating object if the backing ad provides the maximum valid value", ^{
                nativeAdAdapter stub_method("properties").and_return(@{@"starrating":@5.0f});
                starRatingNativeAd.starRating.floatValue should equal(5.0f);
            });

            it(@"should return a nil star rating object if the backing ad does not provide a value", ^{
                nativeAdAdapter stub_method("properties").and_return(@{});
                starRatingNativeAd.starRating should be_nil;
            });

            it(@"should return a nil star rating object if the backing ad does not provide an NSNumber as the value", ^{
                nativeAdAdapter stub_method("properties").and_return(@{@"starrating":@[@"hello"]});
                starRatingNativeAd.starRating should be_nil;
            });

            it(@"should return a nil star rating object if the backing ad provides a value that's over the maximum", ^{
                nativeAdAdapter stub_method("properties").and_return(@{@"starrating":@6.0f});
                starRatingNativeAd.starRating should be_nil;
            });

            it(@"should return a nil star rating object if the backing ad provides a value that's less than the minimum", ^{
                nativeAdAdapter stub_method("properties").and_return(@{@"starrating":@-1.34f});
                starRatingNativeAd.starRating should be_nil;
            });
        });
    });

    context(@"when the ad loads successfully", ^{
        beforeEach(^{
            spy_on(adView);
            [nativeAd prepareForDisplayInView:adView];
        });

        it(@"should layout the ad's assets into the specified view", ^{
            adView should have_received(@selector(layoutAdAssets:));
        });
    });

    context(@"associating views", ^{
        __block MPNativeAd *nativeAd2;

        beforeEach(^{
            nativeAd2 = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
        });

        it(@"should set the native ad as an associated object on the view", ^{
            [adView mp_nativeAd] should_not equal(nativeAd);
            [nativeAd prepareForDisplayInView:adView];
            [adView mp_nativeAd] should equal(nativeAd);
        });

        it(@"should only associate one native ad with one view at a time", ^{
            [nativeAd prepareForDisplayInView:adView];
            [nativeAd2 prepareForDisplayInView:adView];

            [adView mp_nativeAd] should equal(nativeAd2);
            [adView mp_nativeAd] should_not equal(nativeAd);
        });

        it(@"should only associate one view with one native ad at a time", ^{
            [nativeAd prepareForDisplayInView:adView];
            [nativeAd2 prepareForDisplayInView:adView];

            nativeAd.associatedView should be_nil;
            nativeAd2.associatedView should equal(adView);
        });
    });

    context(@"associating views (table view cell)", ^{
        __block MPNativeAd *nativeAd2;
        __block UITableViewCell *tableViewCell;

        beforeEach(^{
            tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseme"];
            nativeAd2 = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
        });

        it(@"should set the native ad as an associated object on the cell", ^{
            [tableViewCell mp_nativeAd] should_not equal(nativeAd);
            [nativeAd prepareForDisplayInView:tableViewCell];
            [tableViewCell mp_nativeAd] should equal(nativeAd);
        });

        it(@"should only associate one native ad with one view at a time", ^{
            [nativeAd prepareForDisplayInView:tableViewCell];
            [nativeAd2 prepareForDisplayInView:tableViewCell];

            [tableViewCell mp_nativeAd] should equal(nativeAd2);
            [tableViewCell mp_nativeAd] should_not equal(nativeAd);
        });

        it(@"should only associate one view with one native ad at a time", ^{
            [nativeAd prepareForDisplayInView:tableViewCell];
            [nativeAd2 prepareForDisplayInView:tableViewCell];

            nativeAd.associatedView should be_nil;
            nativeAd2.associatedView should equal(tableViewCell);
        });
    });

    context(@"associating views (collection view cell)", ^{
        __block MPNativeAd *nativeAd2;
        __block UICollectionViewCell *collectionViewCell;

        beforeEach(^{
            collectionViewCell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            nativeAd2 = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
        });

        it(@"should set the native ad as an associated object on the cell", ^{
            [collectionViewCell mp_nativeAd] should_not equal(nativeAd);
            [nativeAd prepareForDisplayInView:collectionViewCell];
            [collectionViewCell mp_nativeAd] should equal(nativeAd);
        });

        it(@"should only associate one native ad with one view at a time", ^{
            [nativeAd prepareForDisplayInView:collectionViewCell];
            [nativeAd2 prepareForDisplayInView:collectionViewCell];

            [collectionViewCell mp_nativeAd] should equal(nativeAd2);
            [collectionViewCell mp_nativeAd] should_not equal(nativeAd);
        });

        it(@"should only associate one view with one native ad at a time", ^{
            [nativeAd prepareForDisplayInView:collectionViewCell];
            [nativeAd2 prepareForDisplayInView:collectionViewCell];

            nativeAd.associatedView should be_nil;
            nativeAd2.associatedView should equal(collectionViewCell);
        });
    });

    context(@"interaction with the ad", ^{
        __block UIViewController *rootController;

        beforeEach(^{
            rootController = [[UIViewController alloc] init];
            // Make sure it has an engagement tracking url.
            nativeAd.engagementTrackingURL = [NSURL URLWithString:@"http://www.mopub.com"];
        });

        it(@"should track click when displayContentForURL is called", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [nativeAd displayContentForURL:nil rootViewController:rootController completion:nil];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });

        it(@"should call completion block with an error when displaying with a nil view controller", ^{
            __block BOOL wasSuccessful = YES;
            [nativeAd displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] rootViewController:nil completion:^(BOOL success, NSError *error) {
                wasSuccessful = success;
            }];

            wasSuccessful should be_falsy;
        });

        it(@"should track click when displaying content from the non-URL version", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [nativeAd displayContentFromRootViewController:nil completion:nil];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });

        it(@"should not track multiple clicks on the same ad", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [nativeAd trackClick];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
            [nativeAd trackClick];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });

        it(@"should track for all impression URLs", ^{
            [nativeAd.impressionTrackers addObjectsFromArray:@[@"http://www.mopub.com", @"http://www.mopub.com/t", @"http://www.mopub.com/tt"]];
             [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
             [nativeAd trackImpression];
             [MPNativeAd mp_trackMetricURLCallsCount] should equal(3);
        });

        it(@"should not track multiple impressions on the same ad", ^{
            // Make sure it has one impression tracker URL.
            [nativeAd.impressionTrackers addObject:@"http://www.mopub.com"];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [nativeAd trackImpression];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
            [nativeAd trackImpression];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });

        context(@"-displayContentForURL:completion:", ^{
            context(@"when the native ad has a delegate", ^{
                __block id <CedarDouble, MPNativeAdDelegate> adDelegate;

                beforeEach(^{
                    rootController = [[UIViewController alloc] init];
                    adDelegate = fake_for(@protocol(MPNativeAdDelegate));
                    nativeAd.delegate = adDelegate;
                });

                it(@"should pass the delegate's viewControllerForPresentingModalView to the adAdapter", ^{
                    adDelegate stub_method("viewControllerForPresentingModalView").and_return(rootController);
                    spy_on(adAdapter);
                    [nativeAd displayContentForURL:nil completion:nil];
                    adAdapter should have_received(@selector(displayContentForURL:rootViewController:completion:)).with(nil).and_with(rootController).and_with(nil);
                });

                it(@"should call completion block with an error when displaying with a nil view controller", ^{
                    adDelegate stub_method("viewControllerForPresentingModalView").and_return(nil);
                    __block BOOL wasSuccessful = YES;
                    [nativeAd displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] completion:^(BOOL success, NSError *error) {
                        wasSuccessful = success;
                    }];

                    wasSuccessful should be_falsy;
                });
            });

            context(@"when the native ad does not have a delegate", ^{
                it(@"should call displayContentForURL:rootViewController:completion: on the ad adapter", ^{
                    spy_on(adAdapter);
                    [nativeAd displayContentForURL:nil completion:nil];
                    adAdapter should have_received(@selector(displayContentForURL:rootViewController:completion:));
                });

                it(@"should call the completion block without success", ^{
                    __block BOOL wasSuccessful = YES;
                    [nativeAd displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] completion:^(BOOL success, NSError *error) {
                        wasSuccessful = success;
                    }];

                    wasSuccessful should_not be_truthy;
                });
            });
        });
    });

    context(@"when its native ad adapter implements all protocol methods and does not handle click or impression tracking", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;

        beforeEach(^{
            mockadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
            mockadAdapter stub_method(@selector(enableThirdPartyImpressionTracking)).and_return(NO);
            mockadAdapter stub_method(@selector(enableThirdPartyClickTracking)).and_return(NO);
            nativeAd = [[MPNativeAd alloc] initWithAdAdapter:mockadAdapter];
        });

        it(@"should forward track click to native ad adapter", ^{
            [nativeAd trackClick];
            mockadAdapter should have_received(@selector(trackClick));
        });

        it(@"should forward track impression to native ad adapter", ^{
            [nativeAd trackImpression];
            mockadAdapter should have_received(@selector(trackImpression));
        });

        it(@"should forward willAttachToView to native ad adapter", ^{
            [nativeAd prepareForDisplayInView:adView];
            mockadAdapter should have_received(@selector(willAttachToView:)).with(adView);
        });

        it(@"should forward requiredSecondsForImpression to native ad adapter", ^{
            [nativeAd requiredSecondsForImpression];
            mockadAdapter should have_received(@selector(requiredSecondsForImpression));
        });

        it(@"should forward displayContentForURL (URL version) to the adAdapter", ^{
            [nativeAd displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] rootViewController:[[UIViewController alloc] init] completion:nil];
            mockadAdapter should have_received(@selector(displayContentForURL:rootViewController:completion:));
        });

        it(@"should forward displayContentForURL (no-URL version) to the adAdapter", ^{
            [nativeAd displayContentFromRootViewController:[[UIViewController alloc] init] completion:nil];
            mockadAdapter should have_received(@selector(displayContentForURL:rootViewController:completion:));
        });

        it(@"should forward properties to the adAdapter", ^{
            [nativeAd properties];
            mockadAdapter should have_received(@selector(properties));
        });

        it(@"should forward defaultActionURL to the adAdapter", ^{
            [nativeAd defaultActionURL];
            mockadAdapter should have_received(@selector(defaultActionURL));
        });
    });

    context(@"when its native ad adapter implements none of the optional protocol methods", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;

        beforeEach(^{
            mockadAdapter = fake_for(@protocol(MPNativeAdAdapter));
            nativeAd = [[MPNativeAd alloc] initWithAdAdapter:mockadAdapter];
        });

        it(@"should not forward track click to native ad adapter", ^{
            [nativeAd trackClick];
            mockadAdapter should_not have_received(@selector(trackClick));
        });

        it(@"should not forward track impression to native ad adapter", ^{
            [nativeAd trackImpression];
            mockadAdapter should_not have_received(@selector(trackImpression));
        });

        it(@"should not forward willAttachToView to native ad adapter", ^{
            [nativeAd prepareForDisplayInView:adView];
            mockadAdapter should_not have_received(@selector(willAttachToView:));
        });

        it(@"should not forward requiredSecondsForImpression to native ad adapter", ^{
            [nativeAd requiredSecondsForImpression];
            mockadAdapter should_not have_received(@selector(requiredSecondsForImpression));
        });
    });

    context(@"when its native ad adapter handles click and impression tracking", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;

        beforeEach(^{
            mockadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
            mockadAdapter stub_method("enableThirdPartyImpressionTracking").and_return(YES);
            mockadAdapter stub_method("enableThirdPartyClickTracking").and_return(YES);
            nativeAd = [[MPNativeAd alloc] initWithAdAdapter:mockadAdapter];
        });

        it(@"should not forward track click to native ad adapter", ^{
            [nativeAd trackClick];
            mockadAdapter should_not have_received(@selector(trackClick));
        });

        it(@"should not forward track impression to native ad adapter", ^{
            [nativeAd trackImpression];
            mockadAdapter should_not have_received(@selector(trackImpression));
        });

        it(@"should forward willAttachToView to native ad adapter", ^{
            [nativeAd prepareForDisplayInView:adView];
            mockadAdapter should have_received(@selector(willAttachToView:)).with(adView);
        });

        it(@"should forward requiredSecondsForImpression to native ad adapter", ^{
            [nativeAd requiredSecondsForImpression];
            mockadAdapter should have_received(@selector(requiredSecondsForImpression));
        });

        it(@"should not forward displayContentForURL (URL version) to the adAdapter", ^{
            [nativeAd displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] rootViewController:[[UIViewController alloc] init] completion:nil];
            mockadAdapter should_not have_received(@selector(displayContentForURL:rootViewController:completion:));
        });

        it(@"should not forward displayContentForURL (no-URL version) to the adAdapter", ^{
            [nativeAd displayContentFromRootViewController:[[UIViewController alloc] init] completion:nil];
            mockadAdapter should_not have_received(@selector(displayContentForURL:rootViewController:completion:));
        });

        it(@"should forward properties to the adAdapter", ^{
            [nativeAd properties];
            mockadAdapter should have_received(@selector(properties));
        });

        it(@"should forward defaultActionURL to the adAdapter", ^{
            [nativeAd defaultActionURL];
            mockadAdapter should have_received(@selector(defaultActionURL));
        });
    });
});

SPEC_END
