//
//  AppDelegate.m
//  AppDeck
//
//  Copyright (c) 2013 Mobideck. All rights reserved.
//

#import "AppDelegate.h"

#import <QuartzCore/CALayer.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // load app
    NSString *conf_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppDeckJSONURL"];
    NSString *api_key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppDeckApiKey"];
    if (api_key)
    {
        NSRange range = [api_key rangeOfString:@"#"];
        if (range.location != NSNotFound)
            api_key = [api_key substringToIndex:range.location];
    }
    if (api_key)
        conf_url = [NSString stringWithFormat:@"http://config.appdeck.mobi/json/%@", api_key];
    // App.io or appetize.io auto launch
    NSString *app_json_url = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_json_url"];
    if (app_json_url)
        conf_url = app_json_url;

    self.appDeck = [AppDeck open:conf_url withLaunchingWithOptions:launchOptions];
    
    self.window.rootViewController = self.appDeck;
    
    [self.window makeKeyAndVisible];

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - Push \Notification

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    [self.appDeck application:app didRegisterForRemoteNotificationsWithDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    [self.appDeck application:app didFailToRegisterForRemoteNotificationsWithError:err];
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.appDeck application:app didReceiveRemoteNotification:userInfo];
}

// ios8

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [self.appDeck application:application didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    [self.appDeck application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:completionHandler];
}

#pragma mark - Background Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.appDeck application:application performFetchWithCompletionHandler:completionHandler];
}

#pragma mark - Enter/Quit application

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
