//
//  AppDelegate.m
//  Prefetch
//
//  Created by Julien Stoeffler on 14/03/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#define kSiteID 35151
#define kBaseURL @"http://mobile.smartadserver.com"


@implementation AppDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Set the Site ID and the base URL of your application
    [SASAdView setSiteID:kSiteID baseURL:kBaseURL];
	[SASAdView setLoggingEnabled:YES];
	
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Call loadInserstitial here if you want to display the interstitial each time the application comes back in the foreground.
    [_viewController loadInterstitial];
}

@end
