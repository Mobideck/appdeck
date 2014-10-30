//
//  NetWorkTester.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/09/14.
//  Copyright (c) 2012 Mobideck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetWorkTester : NSObject
{
    Reachability* internetReachable;
    Reachability* hostReachable;
    
    
    BOOL internetActive;
    BOOL wifiActive;
    BOOL hostActive;
}

@property (assign) BOOL internetActive;
@property (assign) BOOL hostActive;
@property (assign) BOOL wifiActive;

-(void) checkNetworkStatus:(NSNotification *)notice;
+(NetWorkTester *)getNetworkTester;

@end
