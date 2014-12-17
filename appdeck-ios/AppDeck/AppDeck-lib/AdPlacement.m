//
//  AdPlacement.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 01/09/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "AdPlacement.h"
#import "AdScenario.h"

@implementation AdPlacement

-(id)initWithAdrequest:(AdRequest *)adRequest config:(NSDictionary *)config
//-(id)initWithManager:(AdManager *)adManager page:(PageViewController *)page request:(AdRequest *)adRequest config:(NSDictionary *)config
{
    self = [self init];
    
    if (self)
    {
        self.adRequest = adRequest;
        self.config = config;
        
        [self loadConfiguration:self.config];
    }
    
    return self;
}

-(BOOL)loadConfiguration:(NSDictionary *)config
{
    self.placementId = [config objectForKey:@"id"];
    // settings
    NSDictionary *settings = [config objectForKey:@"settings"];
    if (settings && [[settings class] isSubclassOfClass:[NSDictionary class]])
    {
        self.type = [settings objectForKey:@"type"];
        NSArray *orientations = [settings objectForKey:@"orientation"];
        if (orientations && [[orientations class] isSubclassOfClass:[NSArray class]])
        {
            for (NSString *orientation in orientations)
            {
                if ([orientation isEqualToString:@"portrait"])
                    self.supportOrientationPortrait = YES;
                else if ([orientation isEqualToString:@"landscape"])
                    self.supportOrientationLandscape = YES;
            }
        }
        self.position = [NSString stringWithFormat:@"%@", [settings objectForKey:@"position"]];
        self.sticky = [[settings objectForKey:@"sticky"] boolValue];
    }
    // scenarios
    NSArray *scenarios = [config objectForKey:@"scenarios"];
    if (scenarios && [[scenarios class] isSubclassOfClass:[NSArray class]])
    {
        self.scenarios = [[NSMutableArray alloc] initWithCapacity:scenarios.count];
        for (NSDictionary *scenarioConfig in scenarios)
        {
            if (![[scenarioConfig class] isSubclassOfClass:[NSDictionary class]])
                continue;
            AdScenario *adScenario = [[AdScenario alloc] initWithPlacement:self config:scenarioConfig];
            [self.scenarios addObject:adScenario];
        }
    }
   
    return YES;
}

-(void)cancel
{
    for (AdScenario *adScenario in self.scenarios)
    {
        [adScenario cancel];
    }
    self.scenarios = nil;
}

-(void)dealloc
{
    [self cancel];
}

#pragma mark - Ad Management

-(BOOL)isValid
{
    // check orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation) && self.supportOrientationPortrait == NO)
        return NO;
    if (UIInterfaceOrientationIsLandscape(orientation) && self.supportOrientationLandscape == NO)
        return NO;

    // ad disabled in user profile ?
    if (self.adRequest.page.loader.appDeck.userProfile.enable_ad == NO)
        return NO;
    
    // only one ad per page
    //if (self.adRequest.page.interstitialAd != nil || self.adRequest.page.rectangleAd != nil || self.adRequest.page.bannerAd != nil)
    //    return NO;
    
    // ad disabled ?
    if (self.adRequest.page.disableAds)
        return NO;

    return YES;
}

-(BOOL)start
{
    if ([self isValid] == NO)
        return NO;
    
    // get first scenario that fits
    for (AdScenario *adScenario in self.scenarios)
    {
        if ([adScenario isValid])
        {
            self.adScenario = adScenario;
            return [self.adScenario start];
        }
    }
    
    return NO;
}

@end
