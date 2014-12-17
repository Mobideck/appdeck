//
//  AppDelegate.m
//  ConversantSampleApp
//
//  Created by Jeff Carlson on 3/6/14.
//  Copyright (c) 2014 Conversant. All rights reserved.
//

#import "AppDelegate.h"

#import "GSSDKInfo.h"

@implementation AppDelegate

@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GSSDKInfo setGUID:APPID];

    // To pass location information to the Greystripe SDK, initialize CLLocationManager.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startMonitoringSignificantLocationChanges];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

// Conversant strongly recommends setting interface orientation on a per view controller basis
// Conversant's SDK supports rotation and any orientation on iOS devices

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    // Use the call below to pass your location to the Greystripe SDK
    //[GSSDKInfo updateLocation:newLocation];
    
    //Use the NSLogs below to see Location information in real time
    
    //NSLog(@"%@", newLocation);
    NSLog(@"Lat: %f", newLocation.coordinate.latitude);
    NSLog(@"Long: %f", newLocation.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //NSLog(@"updateLocation failed.");
}

#pragma mark iOS 6 Orientation Support

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
