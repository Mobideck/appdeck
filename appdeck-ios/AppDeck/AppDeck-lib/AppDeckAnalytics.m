//
//  AppDeckAnalytics.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/07/2015.
//  Copyright (c) 2015 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckAnalytics.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
#import "GoogleAnalytics/GAI.h"
#import "GoogleAnalytics/GAIFields.h"
#import "GoogleAnalytics/GAIDictionaryBuilder.h"
#import "Flurry.h"

@implementation AppDeckAnalytics

-(id)initWithLoader:(LoaderViewController *)loader;
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.loader = loader;
        [self configureGA];
    }
    return self;
}

-(void)configureGA
{
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    if (self.loader.conf.ga)
        self.GATracker = [[GAI sharedInstance] trackerWithTrackingId:self.loader.conf.ga];
    self.GAGlobalTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-39746493-1"];
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [self.GATracker set:[GAIFields customDimensionForIndex:1] value:appId];
    if (self.loader.conf.app_api_key)
        [self.GAGlobalTracker set:[GAIFields customDimensionForIndex:2] value:self.loader.conf.app_api_key];
    else
        [self.GAGlobalTracker set:[GAIFields customDimensionForIndex:2] value:@"none"];
}

-(void)configureFlurry
{
    if (self.loader.conf.flurry)
    {
        [Flurry setDebugLogEnabled:YES];
        [Flurry startSession:self.loader.conf.flurry];
    }
}

-(void)sendEventWithName:(NSString *)name action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    if (self.GATracker)
    {
        [self.GATracker send:[[GAIDictionaryBuilder createEventWithCategory:name
                                                                     action:action
                                                                      label:label
                                                                      value:value] build]];
    }
    if (self.GAGlobalTracker)
    {
        [self.GAGlobalTracker send:[[GAIDictionaryBuilder createEventWithCategory:name
                                                                     action:action
                                                                      label:label
                                                                      value:value] build]];
    }
    if (self.loader.conf.flurry)
    {
        NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                      action, @"action",
                                      label, @"label",
                                      value, @"value",
                                      nil];
        
        [Flurry logEvent:name withParameters:flurryParams];
    }
}

-(void)sendScreenView:(NSString *)relativePath
{
    if (self.GATracker)
    {
        [self.GATracker set:kGAIScreenName value:relativePath];
        [self.GATracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
    if (self.GAGlobalTracker)
    {
        [self.GAGlobalTracker set:kGAIScreenName value:relativePath];
        [self.GAGlobalTracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
    if (self.loader.conf.flurry)
    {
        [Flurry logPageView];
    }
}

@end
