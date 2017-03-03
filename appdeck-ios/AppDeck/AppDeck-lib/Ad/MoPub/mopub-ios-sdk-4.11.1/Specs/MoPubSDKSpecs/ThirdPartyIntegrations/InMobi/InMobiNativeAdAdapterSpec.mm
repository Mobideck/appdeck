#import "InMobiNativeAdAdapter.h"
#import "IMNative.h"
#import "MPNativeAdConstants.h"
#import "MPStaticNativeAdImpressionTimer+Specs.h"
#import "MPAdDestinationDisplayAgent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface InMobiNativeAdAdapter ()

@property (nonatomic, strong) MPStaticNativeAdImpressionTimer *impressionTimer;

@end

SPEC_BEGIN(InMobiNativeAdAdapterSpec)

describe(@"InMobiNativeAdAdapter", ^{
    __block IMNative<CedarDouble> *mockIMAd;
    __block InMobiNativeAdAdapter *adAdapter;

    beforeEach(^{
        mockIMAd = nice_fake_for([IMNative class]);
        adAdapter = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:mockIMAd];
    });

    it(@"should not crash if any property is nil", ^{
        ^{
            InMobiNativeAdAdapter *testAd = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:mockIMAd];
            (void)testAd;  // Make Xcode think we're using the testAd so it'll compile.
        } should_not raise_exception;
    });

    context(@"a valid inmobi native ad", ^{

        beforeEach(^{
            mockIMAd stub_method(@selector(content)).and_return(@"{\"title\":\"Ad Title String\",\"landing_url\":\"https://appstorelink.com\",\"screenshots\":{\"w\":568,\"ar\":1.77,\"url\":\"https://mainimage.jpeg\",\"h\":320},\"icon\":{\"w\":568,\"ar\":1.77,\"url\":\"https://iconimage.jpeg\",\"h\":320},\"cta\":\"cta text\",\"description\":\"Description body text\"}");
            adAdapter = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:mockIMAd];
        });

        it(@"should map its properties correctly", ^{

            NSDictionary *properties = adAdapter.properties;

            [properties objectForKey:kAdTitleKey] should equal(@"Ad Title String");
            [properties objectForKey:kAdTextKey] should equal(@"Description body text");
            [properties objectForKey:kAdIconImageKey] should equal(@"https://iconimage.jpeg");
            [properties objectForKey:kAdMainImageKey] should equal(@"https://mainimage.jpeg");
            [properties objectForKey:kAdCTATextKey] should equal(@"cta text");
        });

        it(@"should have a valid defaultActionURL", ^{
            adAdapter.defaultActionURL.absoluteString should equal(@"https://appstorelink.com");
        });

        context(@"impression tracking", ^{
            it(@"should require the ad to be visible for 0.0 seconds", ^{
                adAdapter.impressionTimer.requiredSecondsForImpression should equal(0.0);
            });

            it(@"should require the 50% of the ad to be on screen to be considered as visible", ^{
                adAdapter.impressionTimer.requiredViewVisibilityPercentage should equal(0.5);
            });

            xit(@"should only be told to track an impression once", ^{

            });

            context(@"when the impression is tracked", ^{
                beforeEach(^{
                    adAdapter.delegate = nice_fake_for(@protocol(MPNativeAdAdapterDelegate));
                    [adAdapter performSelector:@selector(trackImpression)];
                });

                it(@"should tell its delegate it tracked an impression", ^{
                    adAdapter.delegate should have_received(@selector(nativeAdWillLogImpression:));
                });
            });
        });

        context(@"when the ad view is loaded", ^{
            __block UIView *view;

            beforeEach(^{
                view = [[UIView alloc] init];
                spy_on(adAdapter.impressionTimer);
                [adAdapter willAttachToView:view];
            });

            it(@"should tell the impression timer to start tracking the view", ^{
                adAdapter.impressionTimer should have_received(@selector(startTrackingView:)).with(view);
            });
        });

        context(@"when displaying content for URL", ^{
            __block MPAdDestinationDisplayAgent *fakeDisplayAgent;
            __block id<CedarDouble, MPNativeAdAdapterDelegate> delegate;

            beforeEach(^{
                fakeDisplayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = fakeDisplayAgent;

                delegate = nice_fake_for(@protocol(MPNativeAdAdapterDelegate));
                adAdapter = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:mockIMAd];
                adAdapter.delegate = delegate;
            });

            it(@"should not attempt to display the url content when not given a controller", ^{
                [adAdapter displayContentForURL:[NSURL URLWithString:@"www.dimsum.com"] rootViewController:nil];

                fakeDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
            });

            it(@"should not attempt to display the url content out when not given a URL", ^{
                [adAdapter displayContentForURL:nil rootViewController:[[UIViewController alloc] init]];

                fakeDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
            });

            context(@"when displaying URL content with valid parameters", ^{
                beforeEach(^{
                    fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;
                    adAdapter = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:mockIMAd];
                    adAdapter.delegate = delegate;
                });

                it(@"should tell the delegate the modal will present when displaying URL content with valid parameters", ^{
                    [adAdapter displayContentForURL:[NSURL URLWithString:@"www.dimsum.com"] rootViewController:[[UIViewController alloc] init]];
                    delegate should have_received(@selector(nativeAdWillPresentModalForAdapter:)).with(adAdapter);
                });

                context(@"when dismissing the modal", ^{
                    __block MPAdBrowserController *browser;
                    __block UIViewController *presentingViewController;

                    beforeEach(^{
                        presentingViewController = [[UIViewController alloc] init];
                        [adAdapter displayContentForURL:[NSURL URLWithString:@"www.dimsum.com"] rootViewController:presentingViewController];
                        browser = (MPAdBrowserController *)presentingViewController.presentedViewController;
                        [browser.doneButton tap];
                    });

                    it(@"should tell the its delegate that the modal was dismissed", ^{
                        delegate should have_received(@selector(nativeAdDidDismissModalForAdapter:)).with(adAdapter);
                    });
                });

                context(@"when the URL will take the user out of the application", ^{
                    __block NSURL *URL;

                    beforeEach(^{
                        URL =[NSURL URLWithString:@"mopubnativebrowser://navigate?url=http://www.google.com"];
                        [adAdapter displayContentForURL:URL rootViewController:[[UIViewController alloc] init]];
                    });

                    it(@"should tell the delegate the user will leave the app", ^{
                        delegate should have_received(@selector(nativeAdWillLeaveApplicationFromAdapter:)).with(adAdapter);
                    });
                });
            });
        });
    });
});

SPEC_END
