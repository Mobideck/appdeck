//
//  AppDeckADConfig.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 10/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckAdConfig.h"
#include <stdlib.h>

@implementation AppDeckAdConfig

/*-(id)init
{
    self.priority = 0;
    self.weight = 0;
    
    self.eCPM = 0.0;
    
    self.refreshTime = 60; // auto refresh after 60 seconds
    
    self.randPrint = 1.0; // allow some random print. 1.0 = always 0.5 = 50% 0.0 = never ...
    
    self.eventCap = 0; // show only every XX enabled event
    self.pageCap = 0; // show only every XX page view (launch, root, push, pop, swipe, popup ...)
    self.timeCap = 0; // show only every XX seconds
    self.sessionCap = 0; // show only every XX session (user must close app, or put in in background)
    self.userCap = 0; // 0 = disabled, 1 = show only once per user, 2 = non sense ...
    
    self.showOnEventLaunch = NO;
    self.showOnEventRoot = YES;
    self.showOnEventPush = YES;
    self.showOnEventPop = YES;
    self.showOnEventSwipe = YES;
    self.showOnEventPopUp = NO;
    
    return self;
}*/

-(void)setDefaults
{
    self.priority = 100;
    self.weight = 1;
    
    self.eCPM = 0.0;
    
    self.refreshTime = 60; // auto refresh after 60 seconds
    
    self.percentPrint = 100; // allow some random print. 1.0 = always 0.5 = 50% 0.0 = never ...
    
    self.eventCap = 0; // show only every XX enabled event
    self.pageCap = 0; // show only every XX page view (launch, root, push, pop, swipe, popup ...)
    self.timeCap = 0; // show only every XX seconds
    self.timeErrorCap = 60; // show only every XX seconds
    self.sessionCap = 0; // show only every XX session (user must close app, or put in in background)
    self.userCap = 0; // 0 = disabled, 1 = show only once per user, 2 = non sense ...
    
    self.showOnEventLaunch = NO;
    self.showOnEventRoot = YES;
    self.showOnEventPush = YES;
    self.showOnEventPop = YES;
    self.showOnEventSwipe = YES;
    self.showOnEventPopUp = NO;

}

+(AppDeckAdConfig *)adConfigFronJson:(NSDictionary *)config
{
    if (config == nil)
        return nil;
    if ([config respondsToSelector:@selector(objectForKey:)] == NO)
        return nil;
    
    AppDeckAdConfig *adConf = [[AppDeckAdConfig alloc] init];

    [adConf setDefaults];
    
    if ([config objectForKey:@"priority"] != nil)
        adConf.priority = [[config objectForKey:@"priority"] intValue];
    if ([config objectForKey:@"weight"] != nil)
        adConf.weight = [[config objectForKey:@"weight"] intValue];

    if ([config objectForKey:@"eCPM"] != nil)
        adConf.eCPM = [[config objectForKey:@"eCPM"] floatValue];

    if ([config objectForKey:@"refreshTime"] != nil)
        adConf.refreshTime = [[config objectForKey:@"refreshTime"] intValue];

    if ([config objectForKey:@"percentPrint"] != nil)
        adConf.percentPrint = [[config objectForKey:@"percentPrint"] intValue];
    
    if ([config objectForKey:@"eventCap"] != nil)
        adConf.eventCap = [[config objectForKey:@"evenCap"] intValue];
    if ([config objectForKey:@"pageCap"] != nil)
        adConf.pageCap = [[config objectForKey:@"pageCap"] intValue];
    if ([config objectForKey:@"timeCap"] != nil)
        adConf.timeCap = [[config objectForKey:@"timeCap"] intValue];
    if ([config objectForKey:@"timeErrorCap"] != nil)
        adConf.timeCap = [[config objectForKey:@"timeErrorCap"] intValue];
    if ([config objectForKey:@"sessionCap"] != nil)
        adConf.sessionCap = [[config objectForKey:@"sessionCap"] intValue];
    if ([config objectForKey:@"userCap"] != nil)
        adConf.userCap = [[config objectForKey:@"userCap"] intValue];
    
    if ([config objectForKey:@"showOnEventLaunch"] != nil)
        adConf.showOnEventLaunch = [[config objectForKey:@"showOnEventLaunch"] boolValue];
    if ([config objectForKey:@"showOnEventRoot"] != nil)
        adConf.showOnEventRoot = [[config objectForKey:@"showOnEventRoot"] boolValue];
    if ([config objectForKey:@"showOnEventPush"] != nil)
        adConf.showOnEventPush = [[config objectForKey:@"showOnEventPush"] boolValue];
    if ([config objectForKey:@"showOnEventPop"] != nil)
        adConf.showOnEventPop = [[config objectForKey:@"showOnEventPop"] boolValue];
    if ([config objectForKey:@"showOnEventSwipe"] != nil)
        adConf.showOnEventSwipe = [[config objectForKey:@"showOnEventSwipe"] boolValue];
    if ([config objectForKey:@"showOnEventPopUp"] != nil)
        adConf.showOnEventPopUp = [[config objectForKey:@"showOnEventPopUp"] boolValue];
    
    return adConf;
}

- (NSComparisonResult)compare:(AppDeckAdConfig *)otherAdConfig
{
    NSNumber *priority = [NSNumber numberWithInt:self.priority];
    NSNumber *otherPriority = [NSNumber numberWithInt:otherAdConfig.priority];
    
    NSComparisonResult compare = [priority compare:otherPriority];
    
    // same priority, we shuffle per weight
    if (compare == NSOrderedSame)
    {
        int total_weight = self.weight + otherAdConfig.weight;
        NSNumber *weight = [NSNumber numberWithInt:self.weight];
        NSNumber *randomWeight = [NSNumber numberWithInt:arc4random_uniform(total_weight)];
        
        compare = [weight compare:randomWeight];
    }
    
    return compare;
}

@end
