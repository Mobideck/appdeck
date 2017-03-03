#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "FBNativeAd+Specs.h"
#import "MPNativeAd.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface FacebookNativeAdAdapter (Specs) <FBNativeAdDelegate>
@end

SPEC_BEGIN(FacebookNativeAdAdapterSpec)

describe(@"FacebookNativeAdAdapter", ^{
    context(@"when initializing", ^{
        __block FBNativeAd<CedarDouble> *mockFBAd;
        __block FacebookNativeAdAdapter *adAdapter;

        beforeEach(^{
            mockFBAd = nice_fake_for([FBNativeAd class]);
            adAdapter = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:mockFBAd];
            adAdapter.delegate = nice_fake_for(@protocol(MPNativeAdAdapterDelegate));
            [FBNativeAd useZeroScaleInStarRating:NO];
        });

        it(@"should not crash if any property is nil", ^{
            ^{
                FacebookNativeAdAdapter *testAd = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:mockFBAd];
                (void)testAd;  // Make Xcode think we're using the testAd so it'll compile.
            } should_not raise_exception;
        });

        it(@"should not crash with a 0 scale in star rating", ^{
            ^{
                [FBNativeAd useZeroScaleInStarRating:YES];

                FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:@"399393939"];
                FacebookNativeAdAdapter *testAd = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd];

                (void)testAd;
            } should_not raise_exception;
        });

        it(@"should map its properties correctly", ^{
            FBNativeAd<CedarDouble> *mockPropertiesAd = nice_fake_for([FBNativeAd class]);
            mockPropertiesAd stub_method(@selector(coverImage)).and_return([[FBAdImage alloc] initWithURL:[NSURL URLWithString:kMPSpecsTestImageURL] width:50 height:50]);
            mockPropertiesAd stub_method(@selector(icon)).and_return([[FBAdImage alloc] initWithURL:[NSURL URLWithString:kMPSpecsTestImageURL] width:50 height:50]);
            mockPropertiesAd stub_method(@selector(title)).and_return(@"title");
            mockPropertiesAd stub_method(@selector(body)).and_return(@"text");
            mockPropertiesAd stub_method(@selector(callToAction)).and_return(@"cta");

            FacebookNativeAdAdapter *testAd = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:mockPropertiesAd];
            NSDictionary *properties = testAd.properties;

            [properties objectForKey:kAdTitleKey] should equal(@"title");
            [properties objectForKey:kAdTextKey] should equal(@"text");
            [properties objectForKey:kAdIconImageKey] should equal(kMPSpecsTestImageURL);
            [properties objectForKey:kAdMainImageKey] should equal(kMPSpecsTestImageURL);
            [properties objectForKey:kAdCTATextKey] should equal(@"cta");
        });

        it(@"should calculate star rating correctly", ^{
            // It doesn't look like we can return a struct in a stubbed method, so we'll use the FBNativeAd+Spec class to allow us to test that.
            FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:@"399393939"];
            FacebookNativeAdAdapter *testAd = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd];

            struct FBAdStarRating starRating = nativeAd.starRating;

            CGFloat ratio = 1.0f;

            if (starRating.scale != 0) {
                ratio = kUniversalStarRatingScale/starRating.scale;
                [NSNumber numberWithFloat:ratio*starRating.value] should equal([testAd.properties objectForKey:kAdStarRatingKey]);
            }
        });

        it(@"should give nil for star rating if fb star rating gives 0 for scale", ^{
            [FBNativeAd useZeroScaleInStarRating:YES];

            FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:@"399393939"];
            FacebookNativeAdAdapter *testAd = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd];

            [testAd.properties objectForKey:kAdStarRatingKey] should be_nil;
        });

        it(@"should have a nil defaultActionURL", ^{
            adAdapter.defaultActionURL should be_nil;
        });

        it(@"should return YES for enableThirdPartyClickTracking", ^{
            adAdapter.enableThirdPartyClickTracking should be_truthy;
        });

        it(@"should call back to its delegate when an impression is fired", ^{
            [adAdapter nativeAdWillLogImpression:mockFBAd];
            adAdapter.delegate should have_received(@selector(nativeAdWillLogImpression:));
        });

        it(@"should call back to its delegate when a click occurs", ^{
            [adAdapter nativeAdDidClick:mockFBAd];
            adAdapter.delegate should have_received(@selector(nativeAdDidClick:));

        });

        it(@"should notify the delegate that a modal will present when the ad is clicked", ^{
            [adAdapter nativeAdDidClick:mockFBAd];
            adAdapter.delegate should have_received(@selector(nativeAdWillPresentModalForAdapter:)).with(adAdapter);
        });

        it(@"should notify the delegate that the modal dismissed when FB has reported the click was handled", ^{
            [adAdapter nativeAdDidFinishHandlingClick:mockFBAd];
            adAdapter.delegate should have_received(@selector(nativeAdDidDismissModalForAdapter:)).with(adAdapter);
        });

        it(@"should provide an ad choices icon view", ^{
            [adAdapter respondsToSelector:@selector(privacyInformationIconView)] should be_truthy;
        });

        it(@"should provide a main media view", ^{
            [adAdapter respondsToSelector:@selector(mainMediaView)] should be_truthy;
        })
    });
});

SPEC_END
