#import "InMobiNativeAdAdapter.h"
#import "IMNative.h"
#import "MPNativeAdConstants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

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

        it(@"should have 0.0 for the requiredSecondsForImpression", ^{
            adAdapter.requiredSecondsForImpression should equal(0.0);
        });
    });

});

SPEC_END
