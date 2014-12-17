//
//  KIFMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFMPInstanceProvider.h"
#import "GSBannerAdView.h"
#import "GSFullscreenAd.h"
#import "GSAdDelegate.h"
#import "IMInterstitial.h"
#import "IMBanner.h"
#import "IMInterstitialDelegate.h"

static KIFMPInstanceProvider *sharedProvider = nil;

@interface MPInstanceProvider (ThirdPartyIntegrations)

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;
- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;
- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId;
- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize;

@end

@implementation MPInstanceProvider (KIF)

+ (MPInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[KIFMPInstanceProvider alloc] init];
    }
    return sharedProvider;
}

@end

@implementation KIFMPInstanceProvider

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    return [super buildGSFullscreenAdWithDelegate:delegate GUID:@"1d73efc1-c8c5-44e6-9b02-b6dd29374c1c"];
}

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size
{
    return [super buildGreystripeBannerAdViewWithDelegate:delegate GUID:@"1d73efc1-c8c5-44e6-9b02-b6dd29374c1c" size:size];
}

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId
{
    return [super buildIMInterstitialWithDelegate:delegate appId:@"5d6694314fbe4ddb804eab8eb4ad6693"];
}

- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize
{
    return [super buildIMBannerWithFrame:frame appId:@"5d6694314fbe4ddb804eab8eb4ad6693" adSize:adSize];
}

@end
