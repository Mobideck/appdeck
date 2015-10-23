//
//  NetAvenirAdEngine.m
//  Oxom
//
//  Created by Sébastien Sans on 13/10/2015.
//  Copyright (c) 2015 Sébastien Sans. All rights reserved.
//

#import "NetAvenirAdEngine.h"
#import "NetAvenirAdViewController.h"
#import "AdManager.h"

@implementation NetAvenirAdEngine

// register this class to AdManager
+ (void)load
{
    [AdManager registerAdEngine:@"netavenir" class:NSStringFromClass(self)];
}

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    if (self) {
        // Custom initialization
        self.zid = [NSString stringWithFormat:@"%@", [config objectForKey:@"zid"]];
    }
    return self;
}

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    NetAvenirAdViewController *ad = [[NetAvenirAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
    return ad;
}

@end
