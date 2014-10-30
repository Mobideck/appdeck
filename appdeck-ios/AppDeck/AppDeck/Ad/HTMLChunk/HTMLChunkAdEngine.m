//
//  FakeAdEngine.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "HTMLChunkAdEngine.h"
#import "HTMLChunkAdViewController.h"

#import "../../AdRation.h"

@implementation HTMLChunkAdEngine

- (id)initWithAdManager:(AdManager *)adManager andConfiguration:(NSDictionary *)config
{
    self = [super initWithAdManager:adManager andConfiguration:config];
    return self;
}

-(AppDeckAdViewController *)adViewControllerFromAdRation:(AdRation *)adRation andAdConfig:(NSDictionary *)adConfig
{
    HTMLChunkAdViewController *ad = [[HTMLChunkAdViewController alloc] initWithAdRation:adRation engine:self config:adConfig];
    return ad;
}


@end
