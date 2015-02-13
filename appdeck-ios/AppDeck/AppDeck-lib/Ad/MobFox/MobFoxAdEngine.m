//
//  WideSpaceAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MobFoxAdEngine.h"
#import "MobFoxAdViewController.h"
#import "MobFoxVideoInterstitialAdViewController.h"

#import "../../AdRation.h"

@implementation MobFoxAdEngine

// register this class to AdManager
+ (void)load
{
    [AdManager registerAdEngine:@"mobfox" class:NSStringFromClass(self)];
}

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
        self.publisherID = [NSString stringWithFormat:@"%@", [config objectForKey:@"publisherID"]];
    }
    return self;
}

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    AdPlacement *adPlacement = adRation.adScenario.adPlacement;
    if ([adPlacement.type isEqualToString:@"interstitial"])
    {
        return [[MobFoxVideoInterstitialAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
    }
    MobFoxAdViewController *ad = [[MobFoxAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];    
    return ad;
}

@end
