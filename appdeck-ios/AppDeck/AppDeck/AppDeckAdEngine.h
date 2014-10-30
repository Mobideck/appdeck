//
//  AppDeckAdEngine.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDeckAdViewController;
@class AdManager;
@class AppDeckAdConfig;
@class AppDeckAdUsage;
@class AdRation;

@interface AppDeckAdEngine : NSObject

@property (nonatomic, weak) AdManager *adManager;
@property (nonatomic, strong) NSDictionary *config;

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config;

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig;

//-(AppDeckAdViewController *)createAdWithType:(NSString *)adType;

@property (strong, nonatomic)    NSMutableDictionary*   adConfigs;
@property (strong, nonatomic)    NSMutableDictionary*   adUsages;

@end
