//
//  MPAdInfo.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdInfo.h"

#import <Foundation/Foundation.h>

@implementation MPAdInfo

+ (NSDictionary *)supportedAddedAdTypes
{
    static NSDictionary *adTypes = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        adTypes = @{@"Banner":@(MPAdInfoBanner), @"Interstitial":@(MPAdInfoInterstitial), @"MRect":@(MPAdInfoMRectBanner), @"Leaderboard":@(MPAdInfoLeaderboardBanner), @"Native":@(MPAdInfoNative), @"Rewarded Video":@(MPAdInfoRewardedVideo)};
    });

    return adTypes;
}

+ (NSArray *)bannerAds
{
    NSMutableArray *ads = [NSMutableArray array];

    [ads addObjectsFromArray:@[
                               [MPAdInfo infoWithTitle:@"HTML Banner Ad" ID:@"0ac59b0996d947309c33f59d6676399f" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"MRAID Banner Ad" ID:@"23b49916add211e281c11231392559e4" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"HTML MRECT Banner Ad" ID:@"2aae44d2ab91424d9850870af33e5af7" type:MPAdInfoMRectBanner],
                               ]];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [ads addObject:[MPAdInfo infoWithTitle:@"HTML Leaderboard Banner Ad" ID:@"d456ea115eec497ab33e02531a5efcbc" type:MPAdInfoLeaderboardBanner]];
    }

    // 3rd Party Networks
#if CUSTOM_EVENTS_ENABLED
    [ads addObject:[MPAdInfo infoWithTitle:@"Facebook" ID:@"446dfa864dcb4469965267694a940f3d" type:MPAdInfoBanner]];
    [ads addObject:[MPAdInfo infoWithTitle:@"Flurry RTB Banner Ad" ID:@"b827dff81325466e95cc6d475f207fb3" type:MPAdInfoBanner]];
    [ads addObject:[MPAdInfo infoWithTitle:@"Google AdMob" ID:@"01535a569c8e11e281c11231392559e4" type:MPAdInfoBanner]];
    [ads addObject:[MPAdInfo infoWithTitle:@"Millennial" ID:@"1aa442709c9f11e281c11231392559e4" type:MPAdInfoBanner]];
#endif

    return ads;
}

+ (NSArray *)interstitialAds
{
    return @[
             [MPAdInfo infoWithTitle:@"HTML Interstitial Ad" ID:@"4f117153f5c24fa6a3a92b818a5eb630" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"MRAID Interstitial Ad" ID:@"3aba0056add211e281c11231392559e4" type:MPAdInfoInterstitial],

    // 3rd Party Networks
    #if CUSTOM_EVENTS_ENABLED
             [MPAdInfo infoWithTitle:@"Chartboost" ID:@"a425ff78959911e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Facebook" ID:@"cec4c5ea0ff140d3a15264da23449f97" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Flurry Interstitial Ad" ID:@"5124d5ff5e3944d2ab8ad496b87a0978" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Flurry RTB Interstitial Ad" ID:@"49960150e2874e9294105af00a77b85c" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Google AdMob" ID:@"16ae389a932d11e281c11231392559e4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Millennial" ID:@"de4205fc932411e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Tapjoy" ID:@"8f66c17adff74e189555247bc1bd26c4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Vungle" ID:@"20e01fce81f611e295fa123138070049" type:MPAdInfoInterstitial],
    #endif
             ];
}

+ (NSArray *)rewardedVideoAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Rewarded Video Ad" ID:@"8f000bd5e00246de9c789eed39ff6096" type:MPAdInfoRewardedVideo],
    // 3rd Party Networks
    #if CUSTOM_EVENTS_ENABLED
             [MPAdInfo infoWithTitle:@"Chartboost" ID:@"8be0bb08fb4f4e90a86416c29c235d4a" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Tapjoy" ID:@"58e30d62673e4c85b2098887a4218816" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Vungle" ID:@"48274e80f11b496bb3532c4f59f28d12" type:MPAdInfoRewardedVideo],
    #endif
             ];
}

+ (NSArray *)nativeAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Native Ad" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Video Ad" ID:@"b2b67c2a8c0944eda272ed8e4ddf7ed4" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Ad (CollectionView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeInCollectionView],
             [MPAdInfo infoWithTitle:@"Native Ad (TableView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeTableViewPlacer],
             [MPAdInfo infoWithTitle:@"Native Video Ad (TableView Placer)" ID:@"b2b67c2a8c0944eda272ed8e4ddf7ed4" type:MPAdInfoNativeTableViewPlacer],

    // 3rd Party Networks
    #if CUSTOM_EVENTS_ENABLED
             [MPAdInfo infoWithTitle:@"Facebook" ID:@"1ceee46ba9744155aed48ee6277ecbd6" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Flurry Native Ad" ID:@"1023187dc1984ec28948b49220e1e3d4" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Flurry Native Video Ad" ID:@"86fa46ac76c546178f1a5774bad66103" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Flurry Native Ad (TableView Placer)" ID:@"1023187dc1984ec28948b49220e1e3d4" type:MPAdInfoNativeTableViewPlacer],
             [MPAdInfo infoWithTitle:@"Millennial" ID:@"b6191f80fa6f4241a942254df07f0b59" type:MPAdInfoNative],
    #endif
             ];
}

+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type {
    MPAdInfo *info = [[MPAdInfo alloc] init];
    info.title = title;
    info.ID = ID;
    info.type = type;
    return info;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.keywords = [aDecoder decodeObjectForKey:@"keywords"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:((self.keywords != nil) ? self.keywords : @"") forKey:@"keywords"];
}

@end
