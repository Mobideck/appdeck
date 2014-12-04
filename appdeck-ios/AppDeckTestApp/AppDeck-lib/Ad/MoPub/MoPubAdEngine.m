//
//  MoPubAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MoPubAdEngine.h"
#import "MoPubAdViewController.h"
#import "MoPubInterstitialAdViewController.h"

@implementation MoPubAdEngine

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
        
//        [MPSessionTracker loadRENAME];
        
        self.bannerAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"bannerAdUnitId"]];
        self.rectangleAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"rectangleAdUnitId"]];
        self.InterstitialAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialAdUnitId"]];
        self.InterstitialLandscapeAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialLandscapeAdUnitId"]];
        
        self.bannerTabletAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"bannerTabletAdUnitId"]];
        self.rectangleTabletAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"rectangleTabletAdUnitId"]];
        self.InterstitialTabletAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialTabletAdUnitId"]];
        self.InterstitialTabletLandscapeAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialTabletLandscapeAdUnitId"]];
    }
    return self;
}

-(void)setMetaData:(MPAdView *)ad
{
//    adView.keywords = @"m_age:24,m_gender:m,m_marital:single";
//    adView.location = (CLLocation)location;
    //ad.testing = YES;
}

-(void)setInterstitialMetaData:(MPInterstitialAdController *)ad
{
    //ad.testing = YES;
}

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    MoPubAdViewController *ad = [[MoPubAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
    return ad;
}
/*
-(AppDeckAdViewController *)createAdWithType:(NSString *)type
{
    if ([type isEqualToString:@"banner"])
        return [[MoPubAdViewController alloc] initWithAdManager:self.adManager type:type engine:self];
    else if ([type isEqualToString:@"rectangle"])
        return [[MoPubAdViewController alloc] initWithAdManager:self.adManager type:type engine:self];
    else if ([type isEqualToString:@"interstitial"])
        return [[MoPubInterstitialAdViewController alloc] initWithAdManager:self.adManager type:type engine:self];
    return nil;
}*/

@end
