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
#import <SwelenSDK/swAdAPI.h>
//#import <GADBannerView.h>
#import <SwelenSDK/swAdAPI.h>
#import <InMobi.h>
#import "AdManager.h"
#import "../../AdRation.h"
#import "../../AdScenario.h"
#import "../../AdPlacement.h"

@implementation MoPubAdEngine

// register this class to AdManager
+ (void)load
{
    [AdManager registerAdEngine:@"mopub" class:NSStringFromClass(self)];
}

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
/*
 
 a. Swelen ID P3L iOS interstitiel : 6a92f4b401186ddf5cffa9ec707ef03f
 b. Swelen ID P3L iOS Bannière : 8ff71a46-ccac-46d4-bbe9-99f2e2393d5b
 c. Swelen ID P3L iOS interstitiel iPad : 17b67fee-af9f-4eae-9178-ce5d182f7d3a
 d. Swelen ID P3L iOS Bannière iPad : 20de2774-5280-45b6-9f30-0f172a47fd8f
 e. Inmobi ID P3L iOS : 4f225cb3cbd84c85a6649702ffa2adab
 f. Mopub ID P3L iOS Bannière : 8620160dd05e43f3b205e44db182a26e
 g. Mopub ID P3L iOS Interstitiel : dc97591857704a4f9e3f961ffef9aa64
 h. Mopub ID P3L iOS Bannière iPad : 2a9afae96e224e45893871ca9acce2d4
 i. Mopub ID P3L iOS Interstitiel iPad : 61a41715ec9346c282eed155f5b82a11
 j. Admob pas besoin d'ID.
 
*/
//        [MPSessionTracker loadRENAME];
        
        self.bannerAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"bannerAdUnitId"]];
        self.rectangleAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"rectangleAdUnitId"]];
        self.InterstitialAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialAdUnitId"]];
        self.InterstitialLandscapeAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialLandscapeAdUnitId"]];
        
        self.bannerTabletAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"bannerTabletAdUnitId"]];
        self.rectangleTabletAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"rectangleTabletAdUnitId"]];
        self.InterstitialTabletAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialTabletAdUnitId"]];
        self.InterstitialTabletLandscapeAdUnitId = [NSString stringWithFormat:@"%@", [config objectForKey:@"InterstitialTabletLandscapeAdUnitId"]];
        /*
        NSString *swelenPassback = [NSString stringWithFormat:@"%@", [config objectForKey:@"swelenPassBack"]];
        if ([swelenPassback isEqualToString:@"1"])
        {
            NSString *swelenPassBackINMOBI = [NSString stringWithFormat:@"%@", [config objectForKey:@"swelenPassBackINMOBI"]];

            if (![swelenPassBackINMOBI isEqualToString:@""])
            {
                SW_LOAD_INMOBI(swelenPassBackINMOBI);
            }
            NSString *swelenPassBackADMOB = [NSString stringWithFormat:@"%@", [config objectForKey:@"swelenPassBackADMOB"]];
            if ([swelenPassBackADMOB isEqualToString:@"1"])
            {
                //SW_LOAD_ADMOB();
            }
        }*/
        
        
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
    // auto detect adType
    AdPlacement *adPlacement = adRation.adScenario.adPlacement;
    if ([adPlacement.type isEqualToString:@"interstitial"])
    {
        MoPubInterstitialAdViewController *ad = [[MoPubInterstitialAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
        return ad;
    }
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
