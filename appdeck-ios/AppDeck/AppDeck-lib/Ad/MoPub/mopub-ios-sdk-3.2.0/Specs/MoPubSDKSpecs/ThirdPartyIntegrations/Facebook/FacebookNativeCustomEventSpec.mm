#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeCustomEvent.h"
#import "FBNativeAd+Specs.h"
#import "NSOperationQueue+MPSpecs.h"
#import "MPNativeAd+Internal.h"
#import "MPNativeAd+Specs.h"
#import "CedarAsync.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FacebookNativeCustomEventSpec)

describe(@"FacebookNativeCustomEvent", ^{
    NSDictionary *validInfo = @{@"placement_id" : @"288600224541553_653781581356747"};
    __block id<CedarDouble, MPNativeCustomEventDelegate> delegate;
    __block FacebookNativeCustomEvent *customEvent;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPNativeCustomEventDelegate));
        customEvent = [[FacebookNativeCustomEvent alloc] init];
        customEvent.delegate = delegate;

        [NSOperationQueue mp_resetAddOperationWithBlockCount];
        [MPNativeAd mp_clearTrackMetricURLCallsCount];
        [FBNativeAd useNilForCoverImage:NO];
        [FBNativeAd useNilForIconImage:NO];
    });

    afterEach(^{
        customEvent.delegate = nil;
         delegate = nil;
         customEvent = nil;
    });

    context(@"when requesting an ad with valid info", ^{
        it(@"should download 2 images if main/icon images exist in the FBNativeAd", ^{
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time([NSOperationQueue mp_addOperationWithBlockCount]) should equal(3);
        });

        it(@"should download 1 image if main image is nil", ^{
            [FBNativeAd useNilForCoverImage:YES];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time([NSOperationQueue mp_addOperationWithBlockCount]) should equal(2);
        });

        it(@"should download 1 image if icon image is nil", ^{
            [FBNativeAd useNilForIconImage:YES];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time([NSOperationQueue mp_addOperationWithBlockCount]) should equal(2);
        });

        it(@"should download 0 images if both icon/main image are nil", ^{
            [FBNativeAd useNilForIconImage:YES];
            [FBNativeAd useNilForCoverImage:YES];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time([NSOperationQueue mp_addOperationWithBlockCount]) should equal(0);
        });

        it(@"should call the success callback", ^{
            [customEvent requestAdWithCustomEventInfo:validInfo];
            in_time(delegate) should have_received("nativeCustomEvent:didLoadAd:");
        });
    });

    context(@"when requesting an ad with invalid info", ^{
        it(@"should call the failure callback when initialized with nil info", ^{
            [customEvent requestAdWithCustomEventInfo:nil];
            delegate should have_received("nativeCustomEvent:didFailToLoadAdWithError:");
        });

        it(@"should call the failure callback when not given a placement_id", ^{
            [customEvent requestAdWithCustomEventInfo:@{}];
            delegate should have_received("nativeCustomEvent:didFailToLoadAdWithError:");
        });
    });
});

SPEC_END
