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
    return [super buildGSFullscreenAdWithDelegate:delegate GUID:@"31d51c95-d79b-48c1-925e-ad328eb48c87"];
}

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size
{
    return [super buildGreystripeBannerAdViewWithDelegate:delegate GUID:@"31d51c95-d79b-48c1-925e-ad328eb48c87" size:size];
}

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId
{
    return [super buildIMInterstitialWithDelegate:delegate appId:@"c8e9d75780cd439cad91d5def5200d25"];
}

- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize
{
    return [super buildIMBannerWithFrame:frame appId:@"c8e9d75780cd439cad91d5def5200d25" adSize:adSize];
}

@end
