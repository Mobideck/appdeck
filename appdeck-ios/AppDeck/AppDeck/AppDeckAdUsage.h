//
//  AppDeckAdUsage.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 11/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdManager.h"

//typedef AdManagerEvent;

@class AppDeckAdConfig;

@interface AppDeckAdUsage : NSObject

@property AppDeckAdConfig *adConfig;

@property AppDeckAdConfig *adUsage;

-(id)initWithConfig:(AppDeckAdConfig *)config;

//-(BOOL)pageViewController:(PageViewController *)page appearWithEvent:(AdManagerEvent)event;
-(BOOL)shouldFetchAdForPageViewController:(PageViewController *)page appearingWithEvent:(AdManagerEvent)event;
-(void)Ad:(AppDeckAdViewController *)ad willAppearWithEvent:(AdManagerEvent)event;
-(void)AdDidFailed:(AppDeckAdViewController *)ad;
@end
