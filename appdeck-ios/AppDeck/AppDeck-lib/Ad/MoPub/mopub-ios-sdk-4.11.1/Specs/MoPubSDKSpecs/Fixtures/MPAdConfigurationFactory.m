//
//  MPAdConfigurationFactory.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdConfigurationFactory.h"
#import "MPNativeAd.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kClickTrackerURLKey         @"clktracker"
#define kDefaultActionURLKey        @"clk"


@implementation MPAdConfigurationFactory

#pragma mark - Native

+ (NSMutableDictionary *)defaultNativeAdHeaders
{
    return [@{
               kAdTypeHeaderKey: kAdTypeNative,
               kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
               kRefreshTimeHeaderKey: @"61",
               } mutableCopy];
}

+ (NSMutableDictionary *)defaultNativeProperties
{
    return [@{@"ctatext":@"Download",
               @"iconimage":@"image_url",
               @"mainimage":@"image_url",
               @"text":@"This is an ad",
               @"title":@"Sample Ad Title",
               kClickTrackerURLKey:@"http://ads.mopub.com/m/clickThroughTracker?a=1",
               kImpressionTrackerURLsKey:@[@"http://ads.mopub.com/m/impressionTracker"],
               kDefaultActionURLKey:@"http://mopub.com"
               } mutableCopy];
}

+ (MPAdConfiguration *)defaultNativeAdConfiguration
{
    return [self defaultNativeAdConfigurationWithHeaders:nil properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultNativeAdConfigurationWithHeaders:@{kAdTypeHeaderKey: type}
                                            properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [MPAdConfigurationFactory defaultNativeAdConfigurationWithHeaders:@{
                                                                             kCustomEventClassNameHeaderKey: eventClassName,
                                                                             kAdTypeHeaderKey: @"custom"}
                                                                properties:nil];
}


+ (MPAdConfiguration *)defaultNativeAdConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  properties:(NSDictionary *)properties
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    NSMutableDictionary *allProperties = [self defaultNativeProperties];
    if (properties) {
        [allProperties addEntriesFromDictionary:properties];
    }

    return [[MPAdConfiguration alloc] initWithHeaders:headers data:[NSJSONSerialization dataWithJSONObject:allProperties options:NSJSONWritingPrettyPrinted error:nil]];
}

#pragma mark - Banners

+ (NSMutableDictionary *)defaultBannerHeaders
{
    return [@{
            kAdTypeHeaderKey: kAdTypeHtml,
            kClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
            kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
            kHeightHeaderKey: @"50",
            kImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
            kInterceptLinksHeaderKey: @"1",
            kLaunchpageHeaderKey: @"http://publisher.com",
            kRefreshTimeHeaderKey: @"30",
            kWidthHeaderKey: @"320"
            } mutableCopy];
}

+ (MPAdConfiguration *)defaultBannerConfiguration
{
    return [self defaultBannerConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultBannerConfigurationWithHeaders:@{kAdTypeHeaderKey: type}
                                            HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:@{
                                            kCustomEventClassNameHeaderKey: eventClassName,
                                                          kAdTypeHeaderKey: @"custom"}
                                                                HTMLString:nil];
}


+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Ad";

    return [[MPAdConfiguration alloc] initWithHeaders:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Interstitials

+ (NSMutableDictionary *)defaultInterstitialHeaders
{
    return [@{
            kAdTypeHeaderKey: kAdTypeInterstitial,
            kClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
            kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
            kImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
            kInterceptLinksHeaderKey: @"1",
            kLaunchpageHeaderKey: @"http://publisher.com",
            kInterstitialAdTypeHeaderKey: kAdTypeHtml,
            kOrientationTypeHeaderKey: @"p"
            } mutableCopy];
}

+ (MPAdConfiguration *)defaultInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultMRAIDInterstitialConfiguration
{
    NSDictionary *headers = @{
                              kAdTypeHeaderKey: @"mraid",
                              kOrientationTypeHeaderKey: @"p"
                              };

    return [self defaultInterstitialConfigurationWithHeaders:headers
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultChartboostInterstitialConfigurationWithLocation:(NSString *)location
{
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"ChartboostInterstitialCustomEvent"];
    NSMutableDictionary *data = [@{@"appId": @"myAppId",
                                 @"appSignature": @"myAppSignature"} mutableCopy];

    if (location) {
        data[@"location"] = location;
    }

    configuration.customEventClassData = data;
    return configuration;
}

+ (MPAdConfiguration *)defaultFakeInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithNetworkType:@"fake"];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultInterstitialConfigurationWithHeaders:@{kInterstitialAdTypeHeaderKey: type}
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:@{
                                                  kCustomEventClassNameHeaderKey: eventClassName,
                                                    kInterstitialAdTypeHeaderKey: @"custom"}
                                                                      HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithHeaders:(NSDictionary *)dictionary
                                                        HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultInterstitialHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Interstitial";

    return [[MPAdConfiguration alloc] initWithHeaders:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Rewarded Video
+ (NSMutableDictionary *)defaultRewardedVideoHeaders
{
    return [@{
              kAdTypeHeaderKey: @"custom",
              kClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
              kImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
              kInterceptLinksHeaderKey: @"1",
              kLaunchpageHeaderKey: @"http://publisher.com",
              kInterstitialAdTypeHeaderKey: kAdTypeHtml,
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersWithReward
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kRewardedVideoCurrencyNameHeaderKey] = @"gold";
    dict[kRewardedVideoCurrencyAmountHeaderKey] = @"12";
    return dict;
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersServerToServer
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kRewardedVideoCompletionUrlHeaderKey] = @"http://ads.mopub.com/m/rewarded_video_completion?req=332dbe5798d644309d9d950321d37e3c&reqt=1460590468.0&id=54c94899972a4d4fb00c9cbf0fd08141&cid=303d4529ee3b42e7ac1f5c19caf73515&udid=ifa%3A3E67D059-6F94-4C88-AD2A-72539FE13795&cppck=09CCC";
    return dict;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfiguration
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:[self defaultRewardedVideoHeaders] data:nil];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithReward
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:[self defaultRewardedVideoHeadersWithReward] data:nil];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationServerToServer
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:[self defaultRewardedVideoHeadersServerToServer] data:nil];
    return adConfiguration;
}

@end
