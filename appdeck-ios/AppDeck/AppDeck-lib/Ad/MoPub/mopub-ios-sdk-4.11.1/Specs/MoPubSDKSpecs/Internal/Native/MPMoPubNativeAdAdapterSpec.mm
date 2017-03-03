#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPStaticNativeAdImpressionTimer+Specs.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPNativeAdConstants.h"
#import "MPGlobalSpecHelper.h"
#import <Cedar/Cedar.h>

#define kImpressionTrackerURLsKey   @"imptracker"
#define kDefaultActionURLKey        @"clk"
#define kClickTrackerURLKey         @"clktracker"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPMoPubNativeAdAdapter ()

@property (nonatomic, strong) MPStaticNativeAdImpressionTimer *impressionTimer;

@end

SPEC_BEGIN(MPMoPubNativeAdAdapterSpec)

describe(@"MPMoPubNativeAdAdapter", ^{
    NSArray *clickTrackerURLArray = @[
                                      @"http://www.mopub.com/byebyebye",
                                      @"http://lol.haha.haha/",
                                      @"http://lol.rofl.lmao/haha",
                                      @"ab#($@%" // give a bad URL to make sure it is discarded
                                      ];

    NSDictionary *validProperties = @{kAdTitleKey : @"WUT",
                                      kAdTextKey : @"WUT DaWG",
                                      kAdIconImageKey : kMPSpecsTestImageURL,
                                      kAdMainImageKey : kMPSpecsTestImageURL,
                                      kAdCTATextKey : @"DO IT",
                                      kImpressionTrackerURLsKey: @[@"http://www.mopub.com/tearinupmyheartwhenimwithyou", @"http://www.mopub.com/pop", @"ab#($@%"],
                                      kClickTrackerURLKey : @"http://www.mopub.com/byebyebye",
                                      kDefaultActionURLKey : @"http://www.mopub.com/iwantyouback"
                                      };

    NSDictionary *validPropertiesWithClickArray = @{kAdTitleKey : @"WUT",
                                      kAdTextKey : @"WUT DaWG",
                                      kAdIconImageKey : kMPSpecsTestImageURL,
                                      kAdMainImageKey : kMPSpecsTestImageURL,
                                      kAdCTATextKey : @"DO IT",
                                      kImpressionTrackerURLsKey: @[@"ab#($@%", @"http://www.mopub.com/tearinupmyheartwhenimwithyou", @"http://www.mopub.com/pop"],
                                      kClickTrackerURLKey : clickTrackerURLArray,
                                      kDefaultActionURLKey : @"http://www.mopub.com/iwantyouback"
                                      };

    context(@"when initializing with valid properties", ^{
        __block MPMoPubNativeAdAdapter *adAdapter;
        __block id<CedarDouble, MPNativeAdAdapterDelegate> delegate;

        beforeEach(^{
            adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[validProperties mutableCopy]];
        });

        it(@"should load the properties correctly", ^{
            NSArray *clickTrackerURLs = @[
                                          [NSURL URLWithString:[validProperties objectForKey:kClickTrackerURLKey]]
                                          ];

            NSArray *impressionTrackerURLs = [MPGlobalSpecHelper convertStrArrayToURLArray:[validProperties objectForKey:kImpressionTrackerURLsKey]];

            [adAdapter.defaultActionURL absoluteString] should equal([validProperties objectForKey:kDefaultActionURLKey]);
            adAdapter.clickTrackerURLs should equal(clickTrackerURLs);
            adAdapter.impressionTrackerURLs should equal(impressionTrackerURLs);

            NSString *daaIconString = [adAdapter.properties objectForKey:kAdDAAIconImageKey];
            [daaIconString rangeOfString:@"MPDAAIcon.png"].location should_not equal(NSNotFound);
        });

        it(@"should load the click array tracker correctly", ^{
            adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[validPropertiesWithClickArray mutableCopy]];

            adAdapter.clickTrackerURLs.count should equal(3);
            adAdapter.clickTrackerURLs should contain([NSURL URLWithString:clickTrackerURLArray[0]]);
            adAdapter.clickTrackerURLs should contain([NSURL URLWithString:clickTrackerURLArray[1]]);
            adAdapter.clickTrackerURLs should contain([NSURL URLWithString:clickTrackerURLArray[2]]);
        });

        it(@"should clean the properties", ^{
            NSDictionary *adProperties = adAdapter.properties;

            [adProperties objectForKey:kImpressionTrackerURLsKey] should be_nil;
            [adProperties objectForKey:kClickTrackerURLKey] should be_nil;
            [adProperties objectForKey:kDefaultActionURLKey] should be_nil;
        });

        context(@"when displaying content for URL", ^{
            __block MPAdDestinationDisplayAgent *fakeDisplayAgent;

            beforeEach(^{
                fakeDisplayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = fakeDisplayAgent;

                delegate = nice_fake_for(@protocol(MPNativeAdAdapterDelegate));
                adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[validProperties mutableCopy]];
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
                    adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[validProperties mutableCopy]];
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

        context(@"impression tracking", ^{
            it(@"should require the ad to be visible for 0.0 seconds", ^{
                adAdapter.impressionTimer.requiredSecondsForImpression should equal(1.0);
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
    });

    context(@"when requesting an ad with invalid info", ^{
        __block MPMoPubNativeAdAdapter *adAdapter;

        it(@"should return nil", ^{
            adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:nil];
            adAdapter should be_nil;
        });
    });

    context(@"when the daa icon is tapped", ^{
        it(@"should try to open the mopub daa icon url", ^{
            MPAdDestinationDisplayAgent *fakeAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
            fakeCoreProvider.fakeMPAdDestinationDisplayAgent = fakeAgent;

            MPMoPubNativeAdAdapter *adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:validProperties.mutableCopy];
            [adAdapter displayContentForDAAIconTap];

            fakeAgent should have_received(@selector(displayDestinationForURL:)).with([NSURL URLWithString:@"https://www.mopub.com/optout"]);
        });
    });

    context(@"when the ad view is loaded", ^{
        __block MPMoPubNativeAdAdapter *adAdapter;
        __block UIView *view;

        beforeEach(^{
            view = [[UIView alloc] init];
            adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[validProperties mutableCopy]];
            spy_on(adAdapter.impressionTimer);
            [adAdapter willAttachToView:view];
        });

        it(@"should tell the impression timer to start tracking the view", ^{
            adAdapter.impressionTimer should have_received(@selector(startTrackingView:)).with(view);
        });
    });

    context(@"when initializing with a single bad click URL", ^{
        NSDictionary *invalidClickProperties = @{kAdTitleKey : @"WUT",
                                                 kAdTextKey : @"WUT DaWG",
                                                 kAdIconImageKey : kMPSpecsTestImageURL,
                                                 kAdMainImageKey : kMPSpecsTestImageURL,
                                                 kAdCTATextKey : @"DO IT",
                                                 kImpressionTrackerURLsKey: @[@"http://www.mopub.com/tearinupmyheartwhenimwithyou", @"http://www.mopub.com/pop"],
                                                 kClickTrackerURLKey : @"ab#($@%",
                                                 kDefaultActionURLKey : @"http://www.mopub.com/iwantyouback"
                                                 };

        it(@"should return a nil adapter", ^{
            MPMoPubNativeAdAdapter *adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[invalidClickProperties mutableCopy]];

            adAdapter should be_nil;
        });
    });
});

SPEC_END
