#import "MPAdConfiguration.h"
#import "MPGoogleAdMobBannerCustomEvent.h"
#import "MPMillennialBannerCustomEvent.h"
#import "MPHTMLBannerCustomEvent.h"
#import "MPMRAIDBannerCustomEvent.h"
#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "MPMillennialInterstitialCustomEvent.h"
#import "MPHTMLInterstitialCustomEvent.h"
#import "MPMRAIDInterstitialCustomEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdConfigurationSpec)

describe(@"MPAdConfiguration", ^{
    __block MPAdConfiguration *configuration;
    __block NSDictionary *headers;

    context(@"when passed busted headers and data", ^{
        it(@"should have sane defaults", ^{
            configuration = [[MPAdConfiguration alloc] initWithHeaders:nil data:nil];

            configuration.adResponseData should be_nil;
            configuration.adType should equal(MPAdTypeUnknown);
            configuration.networkType should equal(@"");
            configuration.preferredSize should equal(CGSizeZero);
            configuration.clickTrackingURL should be_nil;
            configuration.impressionTrackingURL should be_nil;
            configuration.failoverURL should be_nil;
            configuration.interceptURLPrefix should be_nil;
            configuration.shouldInterceptLinks should equal(YES);
            configuration.scrollable should equal(NO);
            configuration.refreshInterval should equal(-1);
            configuration.adTimeoutInterval should equal(-1);
            configuration.nativeSDKParameters should be_nil;
            configuration.customSelectorName should be_nil;
            configuration.orientationType should equal(MPInterstitialOrientationTypeAll);
            configuration.customEventClass should be_nil;
            configuration.customEventClassData should be_nil;

            configuration.hasPreferredSize should equal(NO);
            configuration.clickDetectionURLPrefix should equal(@"");
            configuration.adResponseHTMLString should equal(@"");
        });
    });

    it(@"should save off the data and be able to return it as a string", ^{
        NSData *data = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
        configuration = [[MPAdConfiguration alloc] initWithHeaders:nil data:data];

        configuration.adResponseData should equal(data);
        configuration.adResponseHTMLString should equal(@"Hello World");
    });

    it(@"should process the ad type", ^{
        headers = @{kAdTypeHeaderKey: @"interstitial"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeInterstitial);

        headers = @{kAdTypeHeaderKey: @"mraid"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeBanner);

        headers = @{kAdTypeHeaderKey: @"mraid", kOrientationTypeHeaderKey: @"l"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeInterstitial);

        headers = @{kAdTypeHeaderKey: @"html"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeBanner);

        headers = @{kAdTypeHeaderKey: @"html", kOrientationTypeHeaderKey: @"p"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeInterstitial);

        headers = @{kAdTypeHeaderKey: @"custom", kOrientationTypeHeaderKey: @"p"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeInterstitial);

        headers = @{kAdTypeHeaderKey: @"fluffy barnacles"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeBanner);

        headers = @{kAdTypeHeaderKey: @""};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeBanner);

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adType should equal(MPAdTypeUnknown);
    });

    it(@"should process ad unit warming up", ^{
        headers = @{kAdUnitWarmingUpHeaderKey:@"1"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adUnitWarmingUp should be_truthy;

        headers = @{kAdUnitWarmingUpHeaderKey:@"0"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adUnitWarmingUp should be_falsy;

        headers = @{kAdTypeHeaderKey:@"interstitial"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adUnitWarmingUp should be_falsy;
    });

    it(@"should process the network type", ^{
        headers = @{kAdTypeHeaderKey: @"interstitial", kInterstitialAdTypeHeaderKey: @"magnets"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.networkType should equal(@"magnets");

        headers = @{kAdTypeHeaderKey: @"electrons", kInterstitialAdTypeHeaderKey: @"magnets"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.networkType should equal(@"electrons");

        headers = @{kAdTypeHeaderKey: @"interstitial"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.networkType should equal(@"");

        headers = @{kAdTypeHeaderKey: @"pandas"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.networkType should equal(@"pandas");

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.networkType should equal(@"");
    });

    it(@"should process the preferred size", ^{
        headers = @{kWidthHeaderKey:@"10"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.preferredSize should equal(CGSizeMake(10,0));
        configuration.hasPreferredSize should equal(NO);

        headers = @{kHeightHeaderKey:@"10"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.preferredSize should equal(CGSizeMake(0,10));
        configuration.hasPreferredSize should equal(NO);

        headers = @{kWidthHeaderKey:@"0", kHeightHeaderKey:@"0"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.preferredSize should equal(CGSizeZero);
        configuration.hasPreferredSize should equal(NO);

        headers = @{kWidthHeaderKey:@"10", kHeightHeaderKey:@"20"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.preferredSize should equal(CGSizeMake(10,20));
        configuration.hasPreferredSize should equal(YES);

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.preferredSize should equal(CGSizeZero);
        configuration.hasPreferredSize should equal(NO);
    });

    it(@"should have a variety of URLS", ^{
        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.clickTrackingURL should be_nil;
        configuration.impressionTrackingURL should be_nil;
        configuration.failoverURL should be_nil;
        configuration.interceptURLPrefix should be_nil;
        configuration.clickDetectionURLPrefix should equal(@"");

        headers = @{
                    kClickthroughHeaderKey: @"http://click.through/",
                    kImpressionTrackerHeaderKey: @"http://impression/",
                    kFailUrlHeaderKey: @"http://fail/",
                    kLaunchpageHeaderKey: @"http://interceptor/launch.url?q=3",
                    };
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.clickTrackingURL.absoluteString should equal(@"http://click.through/");
        configuration.impressionTrackingURL.absoluteString should equal(@"http://impression/");
        configuration.failoverURL.absoluteString should equal(@"http://fail/");
        configuration.interceptURLPrefix.absoluteString should equal(@"http://interceptor/launch.url?q=3");
        configuration.clickDetectionURLPrefix should equal(@"http://interceptor/launch.url?q=3");
    });

    it(@"should process interceptLinks", ^{
        headers = @{kInterceptLinksHeaderKey: @"0"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.shouldInterceptLinks should equal(NO);

        headers = @{kInterceptLinksHeaderKey: @"1"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.shouldInterceptLinks should equal(YES);

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.shouldInterceptLinks should equal(YES);
    });

    it(@"should process scrollable", ^{
        headers = @{kScrollableHeaderKey: @"0"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.scrollable should equal(NO);

        headers = @{kScrollableHeaderKey: @"1"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.scrollable should equal(YES);

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.scrollable should equal(NO);
    });

    it(@"should process the refresh interval", ^{
        headers = @{kRefreshTimeHeaderKey: @"100.12"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.refreshInterval should equal(100.12);

        headers = @{kRefreshTimeHeaderKey: @"9.9"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.refreshInterval should equal(10.0);

        headers = @{kRefreshTimeHeaderKey: @"pandas"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.refreshInterval should equal(10.0);

        headers = @{kRefreshTimeHeaderKey: @""};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.refreshInterval should equal(10.0);

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.refreshInterval should equal(-1);
    });

    it(@"should process the ad timeout interval", ^{
        headers = @{kAdTimeoutHeaderKey: @"9"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adTimeoutInterval should equal(9);

        headers = @{kAdTimeoutHeaderKey: @"0"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adTimeoutInterval should equal(0);

        headers = @{kAdTimeoutHeaderKey: @"-100"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adTimeoutInterval should equal(-1);

        headers = @{kAdTimeoutHeaderKey: @"5.5"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adTimeoutInterval should equal(5);

        headers = @{kAdTimeoutHeaderKey: @"llamas"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adTimeoutInterval should equal(-1);

        headers = @{kAdTimeoutHeaderKey: @""};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adTimeoutInterval should equal(-1);

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.adTimeoutInterval should equal(-1);
    });

    it(@"should process rewardedVideo", ^{
        headers = @{kRewardedVideoCurrencyNameHeaderKey: @"gold", kRewardedVideoCurrencyAmountHeaderKey: @"1234"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.rewardedVideoReward should_not be_nil;

        configuration.rewardedVideoReward.currencyType should equal(@"gold");
        configuration.rewardedVideoReward.amount.intValue should equal(1234);

    });

    it(@"should have completion url for rewarded video server to server", ^{
        headers = @{kRewardedVideoCompletionUrlHeaderKey: @"http://ads.mopub.com/m/rewarded_video_completion?req=332dbe5798d644309d9d950321d37e3c&reqt=1460590468.0&id=54c94899972a4d4fb00c9cbf0fd08141&cid=303d4529ee3b42e7ac1f5c19caf73515&udid=ifa%3A3E67D059-6F94-4C88-AD2A-72539FE13795&cppck=09CCC"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.rewardedVideoCompletionUrl should_not be_nil;
    });

    it(@"should process the nativeSDKParameters", ^{
        headers = @{kNativeSDKParametersHeaderKey: @"{\"foo\":\"bar\", \"baz\":2, \"nah\":null}"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.nativeSDKParameters should equal(@{@"foo": @"bar", @"baz": @2});

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.nativeSDKParameters should be_nil;
    });

    it(@"should process the custom selector name", ^{
        headers = @{kCustomSelectorHeaderKey: @"doIt:"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customSelectorName should equal(@"doIt:");

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customSelectorName should be_nil;
    });

    it(@"should process the orientation type", ^{
        headers = @{kOrientationTypeHeaderKey: @"p"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.orientationType should equal(MPInterstitialOrientationTypePortrait);

        headers = @{kOrientationTypeHeaderKey: @"l"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.orientationType should equal(MPInterstitialOrientationTypeLandscape);

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.orientationType should equal(MPInterstitialOrientationTypeAll);
    });

    it(@"should process the custom event class", ^{
        headers = @{kCustomEventClassNameHeaderKey: @"NSObject", kAdTypeHeaderKey: @"custom"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([NSObject class]);

        headers = @{kCustomEventClassNameHeaderKey: @"NSNotReallyAClassSoWhoCares", kAdTypeHeaderKey: @"custom"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should be_nil;

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should be_nil;
    });

    it(@"should convert network/ad type to custom event class", ^{
        headers = @{kAdTypeHeaderKey: @"admob_native"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPGoogleAdMobBannerCustomEvent class]);

        headers = @{kAdTypeHeaderKey: @"millennial_native"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPMillennialBannerCustomEvent class]);

        headers = @{kAdTypeHeaderKey: @"html"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPHTMLBannerCustomEvent class]);

        headers = @{kAdTypeHeaderKey: @"mraid"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPMRAIDBannerCustomEvent class]);

        headers = @{kAdTypeHeaderKey: @"interstitial", kInterstitialAdTypeHeaderKey: @"admob_full"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPGoogleAdMobInterstitialCustomEvent class]);

        headers = @{kAdTypeHeaderKey: @"interstitial", kInterstitialAdTypeHeaderKey: @"millennial_full"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPMillennialInterstitialCustomEvent class]);

        headers = @{kAdTypeHeaderKey: @"html", kOrientationTypeHeaderKey: @"l"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPHTMLInterstitialCustomEvent class]);

        headers = @{kAdTypeHeaderKey: @"mraid", kOrientationTypeHeaderKey: @"p"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClass should equal([MPMRAIDInterstitialCustomEvent class]);
    });

    it(@"should process the customEventClassData", ^{
        headers = @{kCustomEventClassDataHeaderKey: @"{\"foo\":\"bar\", \"baz\":2, \"nah\":null}"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClassData should equal(@{@"foo": @"bar", @"baz": @2});

        headers = @{kCustomEventClassDataHeaderKey: @"{\"foo\":\"bar\", \"baz\":2, \"nah\":null}", kNativeSDKParametersHeaderKey: @"{\"native\":\"guy\"}"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClassData should equal(@{@"foo": @"bar", @"baz": @2});

        headers = @{kNativeSDKParametersHeaderKey: @"{\"native\":\"guy\"}"};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClassData should equal(@{@"native": @"guy"});

        headers = @{};
        configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
        configuration.customEventClassData should be_nil;
    });
});

SPEC_END
