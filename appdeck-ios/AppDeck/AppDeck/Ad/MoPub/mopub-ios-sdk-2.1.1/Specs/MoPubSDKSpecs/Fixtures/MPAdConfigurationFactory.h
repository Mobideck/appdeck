//
//  MPAdConfigurationFactory.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdConfiguration.h"

@interface MPAdConfigurationFactory : NSObject

+ (NSMutableDictionary *)defaultBannerHeaders;
+ (MPAdConfiguration *)defaultBannerConfiguration;
+ (MPAdConfiguration *)defaultBannerConfigurationWithNetworkType:(NSString *)type;
+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName;
+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString;

+ (NSMutableDictionary *)defaultInterstitialHeaders;
+ (MPAdConfiguration *)defaultInterstitialConfiguration;
+ (MPAdConfiguration *)defaultMRAIDInterstitialConfiguration;
+ (MPAdConfiguration *)defaultFakeInterstitialConfiguration;
+ (MPAdConfiguration *)defaultInterstitialConfigurationWithNetworkType:(NSString *)type;
+ (MPAdConfiguration *)defaultChartboostInterstitialConfigurationWithLocation:(NSString *)location;
+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName;
+ (MPAdConfiguration *)defaultInterstitialConfigurationWithHeaders:(NSDictionary *)dictionary
                                                        HTMLString:(NSString *)HTMLString;

@end
