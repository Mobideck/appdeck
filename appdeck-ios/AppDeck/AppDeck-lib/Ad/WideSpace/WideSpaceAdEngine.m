//
//  WideSpaceAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "WideSpaceAdEngine.h"
#import "WideSpaceAdViewController.h"

#import "../../AdRation.h"

@implementation WideSpaceAdEngine

// register this class to AdManager
+ (void)load
{
    [AdManager registerAdEngine:@"widespace" class:NSStringFromClass(self)];
}

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
        self.bannerSID = [NSString stringWithFormat:@"%@", [config objectForKey:@"bannerSID"]];
        self.rectangleSID = [NSString stringWithFormat:@"%@", [config objectForKey:@"rectangleSID"]];
        self.interstitialSID = [NSString stringWithFormat:@"%@", [config objectForKey:@"interstitialSID"]];
        self.leaderboardSID = [NSString stringWithFormat:@"%@", [config objectForKey:@"leaderboardSID"]];
        //self.leaderboardSIDnomargin = [NSString stringWithFormat:@"%@", [AdNetworkconfig objectForKey:@"leaderboardSIDnomargin"]];
        self.squareSID = [NSString stringWithFormat:@"%@", [config objectForKey:@"squareSID"]];
    }
    return self;
}

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    WideSpaceAdViewController *ad = [[WideSpaceAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
    return ad;
}

@end
