//
//  AppDelegate.m
//  ARCSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "SASAdView.h"

#define kSiteID 28298
#define kBaseURL @"http://mobile.smartadserver.com"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	//The site ID and the base URL must be set before using the SDK, otherwise no ad will be retrieved.
	[SASAdView setSiteID:kSiteID baseURL:kBaseURL];
	
	//Enabling logging can be useful to get information if ads are not displayed properly.
	//Don't forget to turn the logging OFF before submitting to the App Store.
	[SASAdView setLoggingEnabled:YES];
	
	MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
	self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
