//
//  NetWorkTester.m
//
//  Created by Mathieu De Kermadec on 24/09/14.
//  Copyright (c) 2012 Mobideck. All rights reserved.
//

#import "NetWorkTester.h"

@implementation NetWorkTester

@synthesize internetActive, hostActive, wifiActive;

+(NetWorkTester *)getNetworkTester
{
    static NetWorkTester *tester = nil;
    
    if (tester == nil)
        tester = [[NetWorkTester alloc] init];
    return tester;
}

-(id)init
{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
    [hostReachable startNotifier];

    self.internetActive = YES;
    self.hostActive = YES;
    
    return self;
}


-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            self.wifiActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            self.wifiActive = YES;            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            self.wifiActive = NO;            
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
        }
    }
}

@end
