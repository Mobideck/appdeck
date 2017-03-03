#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeCustomEvent.h"
#import "FBNativeAd+Specs.h"
#import "NSOperationQueue+MPSpecs.h"
#import "MPNativeAd+Internal.h"
#import "MPNativeAd+Specs.h"
#import "CedarAsync.h"
#import "MPStaticNativeAdRenderer.h"
#import "FakeNativeAdRenderingClass.h"
#import "MPStaticNativeAdRendererSettings.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface FacebookNativeCustomEvent()

@property (nonatomic) BOOL videoEnabled;

@end

SPEC_BEGIN(FacebookNativeCustomEventSpec)

describe(@"FacebookNativeCustomEvent", ^{
    NSDictionary *validInfo = @{@"placement_id" : @"288600224541553_653781581356747"};
    __block id<CedarDouble, MPNativeCustomEventDelegate> delegate;
    __block FacebookNativeCustomEvent *customEvent;
    __block MPStaticNativeAdRenderer *renderer;

    beforeEach(^{
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
        settings.renderingViewClass = [FakeNativeAdRenderingClass class];

        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

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

    // Test video_enabled flag
    // If key kFBVideoAdsEnabledKey doesn't exist in properties, self.videoEnabled's value is equal to gVideoEnabled.
    // Otherwise, the video_enabled value in properties will override gVideoEnabled.

    beforeEach(^{
        NSDictionary *validNoVideoInfo = @{@"placement_id" : @"288600224541553_653781581356747"};
        [FacebookNativeCustomEvent setVideoEnabled:YES];
        [customEvent requestAdWithCustomEventInfo:validNoVideoInfo];
    });

    context(@"when video_enabled is not set in properties", ^{
        it(@"should return NO if gVideoEnabled is not set", ^{
            customEvent.videoEnabled should_not be_truthy;
        });

        it(@"should return YES if gVideoEnabled is set to YES", ^ {
            [FacebookNativeCustomEvent setVideoEnabled:YES];
            customEvent.videoEnabled should be_truthy;
        });
    });

    beforeEach(^{
        NSDictionary *validVideoInfo = @{@"placement_id" : @"288600224541553_653781581356747", @"video_enabled": @"NO"};
        [FacebookNativeCustomEvent setVideoEnabled:YES];
        [customEvent requestAdWithCustomEventInfo:validVideoInfo];
    });

    context(@"when video_enabled is set in properties", ^{
        it(@"should return NO if it is set to be NO in properties", ^{
            customEvent.videoEnabled should_not be_truthy;
        });
    });

    beforeEach(^{
        NSDictionary *validVideoInfo = @{@"placement_id" : @"288600224541553_653781581356747", @"video_enabled": @"YES"};
        [FacebookNativeCustomEvent setVideoEnabled:NO];
        [customEvent requestAdWithCustomEventInfo:validVideoInfo];
    });

    context(@"when video_enabled is set in properties", ^{
        it(@"should return YES if it is set to be YES in properties", ^{
            customEvent.videoEnabled should be_truthy;
        });
    });
});

SPEC_END
