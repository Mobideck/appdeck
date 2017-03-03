#import "MPNativeAdRequest.h"
#import "MPNativeAd+Internal.h"
#import "MPNativeAd+Specs.h"
#import "MPNativeAdRendering.h"
#import "MPAdConfigurationFactory.h"
#import "NSJSONSerialization+MPAdditions.h"
#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAd+Internal.h"
#import "MPNativeAdDelegate.h"
#import "MPNativeAdRendererConfiguration.h"
#import "FakeNativeAdRenderingClass.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPNativeView.h"
#import "MPNativeAdAdapter.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPNativeAd (AdapterDelegate) <MPNativeAdAdapterDelegate>
@end

SPEC_BEGIN(MPNativeAdSpec)

describe(@"MPNativeAd", ^{
    __block MPNativeAd *nativeAd;
    __block MPAdConfiguration *configuration;
    __block MPMoPubNativeAdAdapter *adAdapter;
    __block MPStaticNativeAdRenderer *renderer;
    __block CGSize rendererViewSize;

    beforeEach(^{
        rendererViewSize = CGSizeMake(70, 113);
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];

        settings.renderingViewClass = [FakeNativeAdRenderingClass class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) {
            return rendererViewSize;
        };

        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

        configuration = [MPAdConfigurationFactory defaultNativeAdConfiguration];

        NSDictionary *properties = [NSJSONSerialization mp_JSONObjectWithData:configuration.adResponseData options:0 clearNullObjects:YES error:nil];
        adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[properties mutableCopy]];
        nativeAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
        nativeAd.renderer = renderer;
        [MPNativeAd mp_clearTrackMetricURLCallsCount];
    });

    context(@"ad configuration", ^{
        it(@"should configure properties correctly", ^{
            [nativeAd.properties allKeys] should contain(@"ctatext");
            [nativeAd.properties allKeys] should contain(@"iconimage");
            [nativeAd.properties allKeys] should contain(@"mainimage");
            [nativeAd.properties allKeys] should contain(@"text");
            [nativeAd.properties allKeys] should contain(@"title");
        });

        it(@"should not have click or impression tracker URLS", ^{
            // It is not the responsibility of the mpnative ad to fill in the URLs.
            nativeAd.clickTrackerURLs.count should equal(0);
            nativeAd.impressionTrackerURLs.count should equal(0);
        });

        context(@"star rating", ^{
            __block id<CedarDouble, MPNativeAdAdapter> nativeAdAdapter;
            __block MPNativeAd *starRatingNativeAd;

            beforeEach(^{
                nativeAdAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
                starRatingNativeAd = [[MPNativeAd alloc] initWithAdAdapter:nativeAdAdapter];
                nativeAd.renderer = renderer;
            });
        });
    });

    context(@"retrieveAdViewForSizeCalculationWithError:", ^{
        __block NSError *error;
        __block UIView *adView;

        context(@"when an ad can be successfully rendered", ^{
            beforeEach(^{
                spy_on(renderer);
                adView = [nativeAd retrieveAdViewForSizeCalculationWithError:&error];
            });

            it(@"retrieves registered ad view", ^{
                [adView isKindOfClass:[FakeNativeAdRenderingClass class]] should be_truthy;
            });
        });
    });

    context(@"retrieveAdViewWithError:", ^{
        __block NSError *error;
        __block UIView *renderedView;

        context(@"when an ad can be successfully rendered", ^{
            beforeEach(^{
                spy_on(renderer);
                renderedView = [nativeAd retrieveAdViewWithError:&error];
            });

            it(@"should ask the renderer for the ad view", ^{
                renderer should have_received(@selector(retrieveViewWithAdapter:error:)).with(adAdapter).and_with(Arguments::anything);
            });

            it(@"should return a valid rendered view", ^{
                renderedView should_not be_nil;
            });

            it(@"should not return an error", ^{
                error should be_nil;
            });

            it(@"should return a view of type MPNativeView", ^{
                [renderedView isKindOfClass:[MPNativeView class]] should be_truthy;
            });

            it(@"should have given the MPNativeView and rendered view the same size", ^{
                UIView *adView = renderedView.subviews[0];
                renderedView.bounds should equal(adView.frame);
            });

            it(@"should set the autoresizing mask to the ad view to flexible width/height", ^{
                UIView *adView = renderedView.subviews[0];
                adView.autoresizingMask should equal(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            });

            it(@"should have set up the ad view such that it fills the parent MPNativeView when the parent view resizes", ^{
                UIView *adView = renderedView.subviews[0];
                renderedView.frame = CGRectMake(100, 200, 5009, 6123);
                adView.frame should equal(CGRectMake(0, 0, 5009, 6123));
            });

            it(@"should have set up the ad view (even when the ad view initially has a different frame like it was loaded from a nib) such that it fills the parent MPNativeView when the parent view resizes", ^{
                CGRect viewFrame = CGRectMake(0, 0, 300, 435);
                UIView *framedView = [[UIView alloc] initWithFrame:viewFrame];
                framedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

                renderer = nice_fake_for([MPStaticNativeAdRenderer class]);
                renderer stub_method(@selector(retrieveViewWithAdapter:error:)).and_return(framedView);

                nativeAd.renderer = renderer;

                renderedView = [nativeAd retrieveAdViewWithError:&error];

                UIView *adView = renderedView.subviews[0];
                renderedView.frame = CGRectMake(100, 200, 5009, 6123);
                adView.frame should equal(CGRectMake(0, 0, 5009, 6123));
            });
        });

        context(@"when an ad cannot be successfully rendered", ^{
            __block NSError *returnedError;

            beforeEach(^{
                spy_on(renderer);

                // This block makes sure the error we give to mpnativead points to the error generated in the renderer.
                returnedError = [NSError errorWithDomain:@"a" code:1 userInfo:nil];
                renderer stub_method(@selector(retrieveViewWithAdapter:error:)).and_do_block(^UIView*(id<MPNativeAdAdapter> adapter, NSError **error) {
                    *error = returnedError;
                    return nil;
                });

                renderedView = [nativeAd retrieveAdViewWithError:&error];
            });

            it(@"should return a nil view", ^{
                renderedView should be_nil;
            });

            it(@"should return an error", ^{
                error should equal(returnedError);
            });
        });
    });

    context(@"updateAdViewSizeWithMaximumWidth:", ^{
        it(@"should set the frame of the ad view" , ^{
            CGSize size = CGSizeMake(43, 45);
            [nativeAd updateAdViewSize:size];
            nativeAd.associatedView.bounds.size should equal(size);
        });
    });

    context(@"nativeViewWillMoveToSuperview:", ^{
        context(@"if the delegate responds to adViewWillMoveToSuperview:", ^{
            it(@"should forward the call to its delegate", ^{
                UIView *view = [UIView new];
                spy_on(renderer);
                [nativeAd performSelector:@selector(nativeViewWillMoveToSuperview:) withObject:view];
                renderer should have_received(@selector(adViewWillMoveToSuperview:)).with(view);
            });
        });

        context(@"if the delegate doesn't respond to adViewWillMoveToSuperview:", ^{
            beforeEach(^{
                id<CedarDouble, MPNativeAdRenderer> fakeRenderer = nice_fake_for(@protocol(MPNativeAdRenderer));

                fakeRenderer reject_method(@selector(adViewWillMoveToSuperview:));
                nativeAd.renderer = fakeRenderer;
            });

            it(@"should not forward (and crash) the call to its delegate", ^{
                ^{
                    UIView *view = [UIView new];
                    [nativeAd performSelector:@selector(nativeViewWillMoveToSuperview:) withObject:view];
                } should_not raise_exception;
            });
        });
    });
    context(@"interaction with the ad", ^{
        __block UIViewController *rootController;
        __block UIView *adView;

        beforeEach(^{
            rootController = [[UIViewController alloc] init];
            // Make sure it has a click tracking url.
            [nativeAd.clickTrackerURLs addObject:[NSURL URLWithString:@"http://www.mopub.com"]];
            [nativeAd.clickTrackerURLs addObject:[NSURL URLWithString:@"http://lol.mopub.com"]];
            adView = [nativeAd retrieveAdViewWithError:nil];
        });

        context(@"when the renderer implements nativeAdTapped", ^{
            it(@"should notify its renderer when it's tapped", ^{
                id<MPNativeAdRenderer, CedarDouble> renderer = nice_fake_for(@protocol(MPNativeAdRenderer));
                nativeAd.renderer = renderer;

                [adView tap];
                renderer should have_received(@selector(nativeAdTapped));
            });
        });

        context(@"when the renderer doesn't implement nativeAdTapped", ^{
            it(@"should not notify its renderer when it's tapped", ^{
                id<MPNativeAdRenderer, CedarDouble> renderer = fake_for(@protocol(MPNativeAdRenderer));
                nativeAd.renderer = renderer;

                [adView tap];
                renderer should_not have_received(@selector(nativeAdTapped));
            });
        });

        it(@"should track multiple click URLs when its ad view is tapped", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [adView tap];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(2);
        });

        it(@"should not track multiple clicks on the same ad", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [adView tap];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(2);
            [adView tap];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(2);
        });

        it(@"should track for all impression URLs", ^{
            [nativeAd.impressionTrackerURLs addObjectsFromArray:@[
                                                                  [NSURL URLWithString:@"http://www.mopub.com"],
                                                                  [NSURL URLWithString:@"http://www.mopub.com/t"],
                                                                  [NSURL URLWithString:@"http://www.mopub.com/tt"]
                                                                  ]
             ];
             [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
             [nativeAd performSelector:@selector(trackImpression)];
             [MPNativeAd mp_trackMetricURLCallsCount] should equal(3);
        });

        it(@"should not track multiple impressions on the same ad", ^{
            // Make sure it has one impression tracker URL.
            [nativeAd.impressionTrackerURLs addObject:[NSURL URLWithString:@"http://www.mopub.com"]];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [nativeAd performSelector:@selector(trackImpression)];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
            [nativeAd performSelector:@selector(trackImpression)];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });
    });

    context(@"when its native ad adapter implements all protocol methods and does not handle click or impression tracking", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;
        __block UIView *adView;

        beforeEach(^{
            mockadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));

            mockadAdapter stub_method(@selector(enableThirdPartyClickTracking)).and_return(NO);
            nativeAd = [[MPNativeAd alloc] initWithAdAdapter:mockadAdapter];
            nativeAd.renderer = renderer;
            adView = [nativeAd retrieveAdViewWithError:nil];
        });

        it(@"should call track click on the native ad adapter", ^{
            [adView tap];
            mockadAdapter should have_received(@selector(trackClick));
        });

        it(@"should forward willAttachToView to native ad adapter", ^{
            UIView *adView = [nativeAd retrieveAdViewWithError:nil];
            mockadAdapter should have_received(@selector(willAttachToView:)).with(adView);
        });

        it(@"should call displayContentForURL on the adAdapter when the ad view is tapped", ^{
            [adView tap];
            mockadAdapter should have_received(@selector(displayContentForURL:rootViewController:));
        });

        it(@"should forward properties to the adAdapter", ^{
            [nativeAd properties];
            mockadAdapter should have_received(@selector(properties));
        });

        it(@"should place a gesture recognizer on the native ad view", ^{
            adView.gestureRecognizers.count should equal(1);
        });
    });

    context(@"when its native ad adapter implements none of the optional protocol methods", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;
        __block UIView *adView;

        beforeEach(^{
            mockadAdapter = fake_for(@protocol(MPNativeAdAdapter));
            mockadAdapter stub_method(@selector(properties)).and_return(nil);
            nativeAd = [[MPNativeAd alloc] initWithAdAdapter:mockadAdapter];
            nativeAd.renderer = renderer;
            adView = [nativeAd retrieveAdViewWithError:nil];
        });

        it(@"should not call track click on the native ad adapter", ^{
            [adView tap];
            mockadAdapter should_not have_received(@selector(trackClick));
        });

        it(@"should not forward willAttachToView to native ad adapter", ^{
            [nativeAd retrieveAdViewWithError:nil];
            mockadAdapter should_not have_received(@selector(willAttachToView:));
        });
    });

    context(@"when its native ad adapter handles clicks", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;
        __block UIView *adView;

        beforeEach(^{
            mockadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
            mockadAdapter stub_method("enableThirdPartyClickTracking").and_return(YES);
            nativeAd = [[MPNativeAd alloc] initWithAdAdapter:mockadAdapter];
            nativeAd.renderer = renderer;
            adView = [nativeAd retrieveAdViewWithError:nil];
        });

        it(@"should not call track click on the native ad adapter", ^{
            [adView tap];
            mockadAdapter should_not have_received(@selector(trackClick));
        });

        it(@"should forward willAttachToView to native ad adapter", ^{
            UIView *renderedView = [nativeAd retrieveAdViewWithError:nil];
            mockadAdapter should have_received(@selector(willAttachToView:)).with(renderedView);
        });

        it(@"should not call displayContentForURL on the adapter", ^{
            [adView tap];
            mockadAdapter should_not have_received(@selector(displayContentForURL:rootViewController:));
        });

        it(@"should forward properties to the adAdapter", ^{
            [nativeAd properties];
            mockadAdapter should have_received(@selector(properties));
        });
    });

    context(@"when the delegate implements all of the MPNativeAdDelegate methods", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block id<CedarDouble, MPNativeAdDelegate> delegate;

        beforeEach(^{
            mockadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
            delegate = nice_fake_for(@protocol(MPNativeAdDelegate));
            nativeAd.delegate = delegate;
        });

        it(@"should forward the didDismissModal call up the chain", ^{
            [nativeAd nativeAdDidDismissModalForAdapter:mockadAdapter];
            delegate should have_received(@selector(didDismissModalForNativeAd:)).with(nativeAd);
        });

        it(@"should forward the willPresentModal call up the chain", ^{
            [nativeAd nativeAdWillPresentModalForAdapter:mockadAdapter];
            delegate should have_received(@selector(willPresentModalForNativeAd:)).with(nativeAd);
        });

        it(@"should forward the willLeaveApplication call up the chain", ^{
            [nativeAd nativeAdWillLeaveApplicationFromAdapter:mockadAdapter];
            delegate should have_received(@selector(willLeaveApplicationFromNativeAd:)).with(nativeAd);
        });
    });

    context(@"when the delegate implements none of the MPNativeAdDelegate methods", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block id<CedarDouble, MPNativeAdDelegate> delegate;

        beforeEach(^{
            mockadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
            delegate = fake_for(@protocol(MPNativeAdDelegate));
            nativeAd.delegate = delegate;
        });

        it(@"should not forward the didDismissModal call up the chain", ^{
            [nativeAd nativeAdDidDismissModalForAdapter:mockadAdapter];
            delegate should_not have_received(@selector(didDismissModalForNativeAd:));
        });

        it(@"should not forward the willPresentModal call up the chain", ^{
            [nativeAd nativeAdWillPresentModalForAdapter:mockadAdapter];
            delegate should_not have_received(@selector(willPresentModalForNativeAd:));
        });

        it(@"should not forward the willLeaveApplication call up the chain", ^{
            [nativeAd nativeAdWillLeaveApplicationFromAdapter:mockadAdapter];
            delegate should_not have_received(@selector(willLeaveApplicationFromNativeAd:));
        });
    });
});

SPEC_END
