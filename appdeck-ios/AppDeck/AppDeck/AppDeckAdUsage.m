//
//  AppDeckAdUsage.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 11/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckAdUsage.h"
#import "AppDeckAdConfig.h"
#include <stdlib.h>

@implementation AppDeckAdUsage

-(id)initWithConfig:(AppDeckAdConfig *)config
{
    self = [self init];
    if (self)
    {
        self.adConfig = config;
        self.adUsage = [[AppDeckAdConfig alloc] init];
    }
    return self;
}

-(void)resetAdUsageWithError:(BOOL)error
{
    self.adUsage.pageCap = self.adConfig.pageCap;
    self.adUsage.eventCap = self.adConfig.eventCap;
    self.adUsage.userCap = self.adConfig.userCap;
    self.adUsage.sessionCap = self.adConfig.sessionCap;
    
    self.adUsage.timeCap = [[NSDate date] timeIntervalSince1970] + self.adConfig.timeCap;
    
    if (error)
        self.adUsage.timeErrorCap = [[NSDate date] timeIntervalSince1970] + self.adConfig.timeErrorCap;
    else
        self.adUsage.timeErrorCap = 0;
}

-(BOOL)shouldFetchAdForPageViewController:(PageViewController *)page appearingWithEvent:(AdManagerEvent)event
{
    // first we update page cap
    if (event != AdManagerEventLaunch && event != AdManagerEventPopUp && event != AdManagerEventNone)
        self.adUsage.pageCap--;
    
    // check if original page event can trigger this ad
    if (page.adEvent == AdManagerEventLaunch && self.adConfig.showOnEventLaunch == NO)
        return NO;
    if (page.adEvent == AdManagerEventRoot && self.adConfig.showOnEventRoot == NO)
        return NO;
    if (page.adEvent == AdManagerEventPush && self.adConfig.showOnEventPush == NO)
        return NO;
    if (page.adEvent == AdManagerEventPop && self.adConfig.showOnEventPop == NO)
        return NO;
    if (page.adEvent == AdManagerEventSwipe && self.adConfig.showOnEventSwipe == NO)
        return NO;
    if (page.adEvent == AdManagerEventPopUp && self.adConfig.showOnEventPopUp == NO)
        return NO;
    
    if (event != AdManagerEventNone)
        self.adUsage.eventCap--;
    
    // for event launch, we don't check usage
    if (event != AdManagerEventLaunch)
    {
        // event cap or page cap check
        if (self.adUsage.pageCap > 0 || self.adUsage.eventCap > 0)
            return NO;
        
        // check ad ttl
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        if (self.adUsage.timeCap > timeStamp)
            return NO;
        
        // check time error
        if (self.adUsage.timeErrorCap > timeStamp)
            return NO;
        
        // session cap
        if (self.adUsage.sessionCap > 0)
            return NO;
        
        // user cap
        if (self.adConfig.userCap > 0)
            return NO;
    }
    
    // ad could be print, just apply random
    int r = arc4random_uniform(100);
    if (r > self.adConfig.percentPrint)
        return NO;

    return YES;
}

-(void)Ad:(AppDeckAdViewController *)ad willAppearWithEvent:(AdManagerEvent)event
{
    [self resetAdUsageWithError:NO];
}

-(void)AdDidFailed:(AppDeckAdViewController *)ad
{
    [self resetAdUsageWithError:YES];
}


@end
