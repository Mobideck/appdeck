//
//  AppDeck.h
//  PhoenixJP.News
//
//  Created by Mathieu De Kermadec on 12/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppURLCache.h"
#import "CustomWebViewFactory.h"

@class LoaderViewController;

@interface AppDeck : NSObject

+(AppDeck *)sharedInstance;

@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) AppURLCache *cache;
@property (strong, nonatomic) CustomWebViewFactory *customWebViewFactory;
@property (strong, nonatomic) LoaderViewController *loader;

+(LoaderViewController *)open:(NSString *)url  withLaunchingWithOptions:(NSDictionary *)launchOptions;
+(void)reloadFrom:(NSString *)url;
+(void)restart;

@end