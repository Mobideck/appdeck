//
//  WideSpaceAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "SmartAdServerAdEngine.h"
#import "SmartAdServerAdViewController.h"
#import "AdManager.h"
#import "../../AdRation.h"

@implementation SmartAdServerAdEngine

// register this class to AdManager
+ (void)load
{
    [AdManager registerAdEngine:@"smart" class:NSStringFromClass(self)];
}

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
        self.siteID = [NSString stringWithFormat:@"%@", [config objectForKey:@"siteID"]];
        self.pageID = [NSString stringWithFormat:@"%@", [config objectForKey:@"pageID"]];
        self.formatBannerID = [NSString stringWithFormat:@"%@", [config objectForKey:@"formatBannerID"]];
        self.formatRectangleID = [NSString stringWithFormat:@"%@", [config objectForKey:@"formatRectangleID"]];
        self.formatinterstitialID = [NSString stringWithFormat:@"%@", [config objectForKey:@"formatinterstitialID"]];
        self.networkID = [NSString stringWithFormat:@"%@", [config objectForKey:@"networkID"]];
        self.baseURL = [NSString stringWithFormat:@"%@", [config objectForKey:@"baseURL"]];
        
        [SASAdView setSiteID:self.siteID.integerValue baseURL:self.baseURL];
        
        [SASAdView setLoggingEnabled:YES];
        //[SASAdView setTestModeEnabled:YES];
    }
    return self;
}

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    SmartAdServerAdViewController *ad = [[SmartAdServerAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
    return ad;
}

@end
