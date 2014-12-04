//
//  AppDelegate.m
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 11/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import "AppDelegate.h"
#import "SASAdView.h"
#import "Constants.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	//Setting SiteID and baseURL should be made in the application:didFinishLaunchingWithOptions: delegate and is mandatory.
	[SASAdView setSiteID:kAdSiteId baseURL:kAdBaseURL];
	
	//Enabling logging can be useful to get information if ads are not displayed properly.
	//Don't forget to turn the logging OFF before submitting to the App Store.
	[SASAdView setLoggingEnabled:YES];
	
	[self.window setBackgroundColor:[UIColor whiteColor]];
    return YES;
}

@end
