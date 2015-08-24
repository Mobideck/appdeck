//
//  AppsFireAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppsFireAdEngine.h"
#import "AppsFireAdViewController.h"
#import "AdManager.h"

@implementation AppsFireAdEngine

// register this class to AdManager
+ (void)load
{
    [AdManager registerAdEngine:@"appsfire" class:NSStringFromClass(self)];
}

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
        self.api_key = [NSString stringWithFormat:@"%@", [config objectForKey:@"api_key"]];
        self.api_secret = [NSString stringWithFormat:@"%@", [config objectForKey:@"api_secret"]];        
        self.type = AFAdSDKModalTypeSushi;
        NSString *type = [config objectForKey:@"type"];
        if (type && [type isEqualToString:@"uramaki"])
            self.type = AFAdSDKModalTypeUraMaki;
    }
    return self;
}

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    AppsFireAdViewController *ad = [[AppsFireAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
    return ad;
}

/*
-(AppDeckAdViewController *)createAdWithType:(NSString *)type
{
    if ([type isEqualToString:@"banner"])
        return nil;//[[WideSpaceAdViewController alloc] initWithAdManager:self.adManager type:type engine:self];
    else if ([type isEqualToString:@"rectangle"])
        return nil;//[[WideSpaceAdViewController alloc] initWithAdManager:self.adManager type:type engine:self];
    else if ([type isEqualToString:@"interstitial"])
    {
        //if ([AppsfireAdSDK isThereAModalAdAvailable])
        return [[AppsFireAdViewController alloc] initWithAdManager:self.adManager type:type engine:self];
        return nil;
    }
    return nil;
}*/

@end
