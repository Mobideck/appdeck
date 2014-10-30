//
//  MPAdInfo.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MPAdInfoBanner,
    MPAdInfoInterstitial,
    MPAdInfoMRectBanner,
    MPAdInfoLeaderboardBanner,
    MPAdInfoNative,
    MPAdInfoNativeInTableView
} MPAdInfoType;

@interface MPAdInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) MPAdInfoType type;
@property (nonatomic, copy) NSString *keywords;

+ (NSArray *)bannerAds;
+ (NSArray *)interstitialAds;
+ (NSArray *)nativeAds;
+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type;
+ (NSArray *)supportedAdTypeNames;

@end
