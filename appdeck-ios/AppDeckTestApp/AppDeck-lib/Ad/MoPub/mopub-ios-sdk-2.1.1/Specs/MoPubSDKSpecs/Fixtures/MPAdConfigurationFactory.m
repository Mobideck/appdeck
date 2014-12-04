//
//  MPAdConfigurationFactory.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdConfigurationFactory.h"

@implementation MPAdConfigurationFactory

#pragma mark - Banners

+ (NSMutableDictionary *)defaultBannerHeaders
{
    return [[@{
            kAdTypeHeaderKey: kAdTypeHtml,
            kClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
            kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
            kHeightHeaderKey: @"50",
            kImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
            kInterceptLinksHeaderKey: @"1",
            kLaunchpageHeaderKey: @"http://publisher.com",
            kRefreshTimeHeaderKey: @"30",
            kWidthHeaderKey: @"320"
            } mutableCopy] autorelease];
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

    return [[[MPAdConfiguration alloc] initWithHeaders:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
}

#pragma mark - Interstitials

+ (NSMutableDictionary *)defaultInterstitialHeaders
{
    return [[@{
            kAdTypeHeaderKey: kAdTypeInterstitial,
            kClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
            kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
            kImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
            kInterceptLinksHeaderKey: @"1",
            kLaunchpageHeaderKey: @"http://publisher.com",
            kInterstitialAdTypeHeaderKey: kAdTypeHtml,
            kOrientationTypeHeaderKey: @"p"
            } mutableCopy] autorelease];
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
    NSMutableDictionary *data = [[@{@"appId": @"myAppId",
                                 @"appSignature": @"myAppSignature"} mutableCopy] autorelease];

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

    return [[[MPAdConfiguration alloc] initWithHeaders:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
}



@end
