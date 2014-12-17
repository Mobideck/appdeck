/*
 * ViewController.m
 * ChartboostExampleApp
 *
 * Copyright (c) 2013 Chartboost. All rights reserved.
 */

#import "ViewController.h"
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBNewsfeed.h>
#import <Chartboost/CBAnalytics.h>

#import <StoreKit/StoreKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showInterstitial {
    [Chartboost showInterstitial:CBLocationHomeScreen];
}

- (IBAction)showMoreApps {
    [Chartboost showMoreApps:self location:CBLocationHomeScreen];
}

- (IBAction)cacheInterstitial {
    [Chartboost cacheInterstitial:CBLocationHomeScreen];
}

- (IBAction)cacheMoreApps {
    [Chartboost cacheMoreApps:CBLocationHomeScreen];
}

- (IBAction)showNewsfeed {
    [CBNewsfeed showNewsfeedUI];
}

- (IBAction)cacheRewardedVideo {
    [Chartboost cacheRewardedVideo:CBLocationHomeScreen];
}

- (IBAction)showRewardedVideo {
    [Chartboost showRewardedVideo:CBLocationMainMenu];
}

- (IBAction)showNotificationUI:(id)sender {
    [CBNewsfeed showNotificationUI];
}

- (IBAction)showSupport:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://answers.chartboost.com"]];
}

/*
 * This is an example of how to call the Chartboost Post Install Analytics API.
 * To fully use this feature you must implement the Apple In-App Purchase
 *
 * Checkout https://developer.apple.com/in-app-purchase/ for information on how to setup your app to use StoreKit
 */
- (void)trackInAppPurchase:(NSData *)transactionReceipt product:(SKProduct *)product {
    [CBAnalytics trackInAppPurchaseEvent:transactionReceipt product:product];
}

@end
