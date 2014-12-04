//
//  AppsFireAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import "AppsFireAdEngine.h"

@interface AppsFireAdViewController : AppDeckAdViewController <AppsfireAdSDKDelegate>

- (id)initWithAdRation:(AdRation *)adRation engine:(AppsFireAdEngine *)adEngine config:(NSDictionary *)config;
//- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(AppsFireAdEngine *)engine;

@property (nonatomic, strong)   AppsFireAdEngine *adEngine;

@end
