#import "InMobiNativeCustomEvent.h"
#import "NSOperationQueue+MPSpecs.h"
#import "MPNativeAd+Internal.h"
#import "MPNativeAd+Specs.h"
#import "IMNative+Specs.h"
#import "CedarAsync.h"
#import "MPStaticNativeAdRenderer.h"
#import "FakeNativeAdRenderingClass.h"
#import "MPStaticNativeAdRendererSettings.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiNativeCustomEventSpec)

describe(@"InMobiNativeCustomEvent", ^{
    NSDictionary *validInfo = @{@"app_id" : @"b15abe4c93a84f59a65faceca30c9591"};
    __block id<CedarDouble, MPNativeCustomEventDelegate> delegate;
    __block InMobiNativeCustomEvent *customEvent;
    __block MPStaticNativeAdRenderer *renderer;

    [InMobi initialize:@"b15abe4c93a84f59a65faceca30c9591"];

    beforeEach(^{
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
        settings.renderingViewClass = [FakeNativeAdRenderingClass class];

        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

        delegate = nice_fake_for(@protocol(MPNativeCustomEventDelegate));
        customEvent = [[InMobiNativeCustomEvent alloc] init];
        customEvent.delegate = delegate;

        [IMNative mp_switchToNormalContent];

        [NSOperationQueue mp_resetAddOperationWithBlockCount];
        [MPNativeAd mp_clearTrackMetricURLCallsCount];
    });

    afterEach(^{
        customEvent.delegate = nil;
         delegate = nil;
         customEvent = nil;
    });

    context(@"when requesting an ad with valid info", ^{
        it(@"should download the main image and icon image", ^{
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time([NSOperationQueue mp_addOperationWithBlockCount]) should equal(3);
        });

        it(@"should call the success callback", ^{
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time(delegate) should have_received("nativeCustomEvent:didLoadAd:");
        });
    });

    context(@"when requesting an ad with invalid info", ^{
        it(@"should call the failure callback", ^{
            [customEvent requestAdWithCustomEventInfo:nil];
            in_time(delegate) should have_received("nativeCustomEvent:didFailToLoadAdWithError:");
        });
    });

    context(@"when InMobi returns a native ad with invalid image urls", ^{
        it(@"should call the failure callback if the icon image is invalid", ^{
            [IMNative mp_switchToBadIconImageURLContent];
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time(delegate) should have_received("nativeCustomEvent:didFailToLoadAdWithError:");
        });

        it(@"should call the failure callback if the main image is invalid", ^{
            [IMNative mp_switchToBadMainImageURLContent];
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time(delegate) should have_received("nativeCustomEvent:didFailToLoadAdWithError:");
        });
    });
});

SPEC_END
