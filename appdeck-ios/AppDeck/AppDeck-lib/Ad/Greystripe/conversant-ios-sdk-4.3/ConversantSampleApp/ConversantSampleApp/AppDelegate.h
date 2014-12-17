//
//  AppDelegate.h
//  ConversantSampleApp
//
//  Created by Jeff Carlson on 3/6/14.
//  Copyright (c) 2014 Conversant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GSAdDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CLLocationManager *locationManager;

// Used for Info Page. Not needed for SDK functionality

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

// Define the Conversant APP ID

#define APPID @"51d7ee3c-95fd-48d5-b648-c915209a00a5" // Conversant Test App ID

// For quick testing and debugging, paste your app's Conversant App ID below in "appID"
// Comment out the #define line above and uncomment the #define line below
// Clean and build your project for testing and debugging
// #define APPID @"appID"

@end
