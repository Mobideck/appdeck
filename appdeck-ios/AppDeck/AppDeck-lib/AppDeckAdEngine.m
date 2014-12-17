//
//  AppDeckAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckAdEngine.h"
#import "AppDeckAdConfig.h"
#import "AppDeckAdUsage.h"

@implementation AppDeckAdEngine

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.adManager = adManager;
        self.config = config;
/*
        self.adUsages = [[NSMutableDictionary alloc] initWithCapacity:self.adManager.adTypes.count];
        self.adConfigs = [[NSMutableDictionary alloc] initWithCapacity:self.adManager.adTypes.count];
        
        for (NSString *adType in self.adManager.adTypes)
        {
            AppDeckAdConfig *adConfig = [AppDeckAdConfig adConfigFronJson:[config objectForKey:adType]];
            if (adConfig)
            {
                AppDeckAdUsage *adUsage = [[AppDeckAdUsage alloc] initWithConfig:adConfig];
                [self.adUsages setObject:adUsage forKey:adType];
                [self.adConfigs setObject:adConfig forKey:adType];
            }
        }*/
    }
    return self;
}

/*
-(AppDeckAdViewController *)createAdWithType:(NSString *)adType
{
    return nil;
}*/

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    return nil;
}

/*
#pragma mark - compare

- (NSComparisonResult)compareBanner:(AppDeckAdEngine *)otherAppDeckAdEngine
{
    return [self.bannerConfig compare:otherAppDeckAdEngine.bannerConfig];
}

- (NSComparisonResult)compareRectangle:(AppDeckAdEngine *)otherAppDeckAdEngine
{
    return [self.rectangleConfig compare:otherAppDeckAdEngine.rectangleConfig];
}

- (NSComparisonResult)compareInterstitial:(AppDeckAdEngine *)otherAppDeckAdEngine
{
    return [self.interstitialConfig compare:otherAppDeckAdEngine.interstitialConfig];
}
*/


@end
