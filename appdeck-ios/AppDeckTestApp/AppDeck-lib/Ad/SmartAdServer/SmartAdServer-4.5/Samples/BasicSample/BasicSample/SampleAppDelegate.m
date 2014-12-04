//
//  SampleAppDelegate.m
//  Sample
//
//  Created by Julien Stoeffler on 07/07/11.
//  Copyright 2011 Smart AdServer. All rights reserved.
//

#import "SampleAppDelegate.h"
#import "SASAdView.h"
#import "RootViewController.h"

#define kSiteID 27893
#define kBaseURL @"http://mobile.smartadserver.com"
#define kPageID @"185330"
#define kFormatID 12160


@interface SampleAppDelegate ()

@property (nonatomic, retain) RootViewController *controller;

@end

@implementation SampleAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.controller = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	_navigationController = [[UINavigationController alloc] initWithRootViewController:_controller];

	self.window.rootViewController = self.navigationController;

	// Set the Site ID and the base URL of your application
	[SASAdView setSiteID:kSiteID baseURL:kBaseURL];
	[SASAdView setLoggingEnabled:YES];

	[self.window makeKeyAndVisible];
	return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self displayInterstitial];
}

#pragma mark - Ad lifecycle

- (void)displayInterstitial {
	
    if (!_startupInterstitial) {
        // Release of the old interstitial if it already exists
        self.startupInterstitial.delegate = nil;
        self.startupInterstitial = nil;
    }
    
    // We create the interstitial with a loader and without a status bar.
	//
	// The initializer initWithFrame:loader:hideStatusBar: is now deprecated. Since iOS 7, it is better to implement the status bar
	// behavior directly in the view controller rather than letting the SDK managing it globally.
	// See the 'ARCSample' or the 'SwiftSample' for a detailled explanation on how to implement the new implementation.
    SASInterstitialView *startupAdView = [[SASInterstitialView alloc] initWithFrame:self.navigationController.view.frame
                                                                             loader:SASLoaderActivityIndicatorStyleBlack
                                                                      hideStatusBar:YES];
    self.startupInterstitial = startupAdView;
    [_startupInterstitial release];
    
    // Set the RootViewController instance as the delegate, so that it will notify this instance of changes in its life cycle
	_startupInterstitial.delegate = _controller;
	
	// Set the dismissalAnimations property to the animations block containing everything you want to animate
    // Use the adView block parameter so that you don't have to worry about reference circles
    self.startupInterstitial.dismissalAnimations = ^(SASAdView *adView) {
		adView.alpha = 0;
	};
	
    // Load the ad for the given tags
    [_startupInterstitial loadFormatId:kFormatID pageId:kPageID master:YES target:nil timeout:20];
    
    // Add the view to the navigationController so that it stays fullscreen
    [self.navigationController.view addSubview:_startupInterstitial];
}

#pragma mark - SASAdViewDelegate

// Controller used in case of a post-click modal view. This should be your higher level controller, here the navigation controller
- (UIViewController *)viewControllerForAdView:(SASAdView *)adView {
	return _navigationController;
}


- (void)dealloc {
    self.startupInterstitial.delegate = nil;
	self.startupInterstitial = nil;
    
    self.window = nil;
    self.navigationController = nil;
	
	[super dealloc];
}

@end
