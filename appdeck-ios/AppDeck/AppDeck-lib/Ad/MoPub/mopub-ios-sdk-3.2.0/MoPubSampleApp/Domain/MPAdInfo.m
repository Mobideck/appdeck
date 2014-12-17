//
//  MPAdInfo.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdInfo.h"

#import <Foundation/Foundation.h>

@implementation MPAdInfo

+ (NSArray *)supportedAdTypeNames
{
    static NSArray *adTypeNames = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        adTypeNames = @[@"Banner", @"Interstitial", @"MRect", @"Leaderboard", @"Native"];
    });

    return adTypeNames;
}

+ (NSArray *)bannerAds
{
    NSMutableArray *ads = [NSMutableArray array];

    [ads addObjectsFromArray:@[
                               [MPAdInfo infoWithTitle:@"HTML Banner Ad" ID:@"c92be421345c4eab964645f6a1818284" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"MRAID Banner Ad" ID:@"23b49916add211e281c11231392559e4" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"HTML MRECT Banner Ad" ID:@"2aae44d2ab91424d9850870af33e5af7" type:MPAdInfoMRectBanner],
                               ]];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [ads addObject:[MPAdInfo infoWithTitle:@"HTML Leaderboard Banner Ad" ID:@"d456ea115eec497ab33e02531a5efcbc" type:MPAdInfoLeaderboardBanner]];
    }

    return ads;
}

+ (NSArray *)interstitialAds
{
    return @[
             [MPAdInfo infoWithTitle:@"HTML Interstitial Ad" ID:@"4f117153f5c24fa6a3a92b818a5eb630" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"MRAID Interstitial Ad" ID:@"3aba0056add211e281c11231392559e4" type:MPAdInfoInterstitial],
             ];
}

+ (NSArray *)nativeAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Native Ad" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Ad (TableView Manager)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeInTableView],
             [MPAdInfo infoWithTitle:@"Native Ad (CollectionView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeInCollectionView],
             [MPAdInfo infoWithTitle:@"Native Ad (TableView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeTableViewPlacer]
             ];
}

+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type
{
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
