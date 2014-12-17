//
//  AppDelegate.m
//  TableViewSample
//
//  Created by Loïc GIRON DIT METAZ on 08/07/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "SASAdView.h"

#define kSiteID		50466
#define kBaseURL	@"http://mobile.smartadserver.com"


@implementation AppDelegate

- (void)dealloc {
	[_window release];
	[_viewController release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	//Setting the site ID and the base URL, enabling logging for easier debugging
    [SASAdView setSiteID:kSiteID baseURL:kBaseURL];
	
	//Enabling logging can be useful to get information if ads are not displayed properly.
	//Don't forget to turn the logging OFF before submitting to the App Store.
	[SASAdView setLoggingEnabled:YES];
    
    return YES;
}

@end
