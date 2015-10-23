//
//  AppDeck.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 12/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDeckApiCall.h"
#import "AppDeckUserProfile.h"
#import "KeyboardStateListener.h"

#define APPDECK_VERSION @"1.10"

@class LoaderViewController;
@class AppURLCache;
@class CustomWebViewFactory;
@class LoaderViewController;
@class LogViewController;

@interface AppDeck : NSObject <AppDeckApiCallDelegate>
{
    UIWebView *firstWebView;
    BOOL shouldConfigureApp;
}
+(AppDeck *)sharedInstance;

@property (assign, nonatomic)   float iosVersion;

@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) KeyboardStateListener *keyboardStateListener;

@property (strong, nonatomic) AppURLCache *cache;
@property (strong, nonatomic) CustomWebViewFactory *customWebViewFactory;
@property (strong, nonatomic) LoaderViewController *loader;

@property (strong, nonatomic) AppDeckUserProfile *userProfile;

@property (assign, nonatomic) BOOL  enable_debug;
@property (assign, nonatomic) BOOL  isTestApp;

@property (strong, nonatomic)   NSString    *userAgent;
@property (strong, nonatomic)   NSString    *userAgentWebView;
@property (strong, nonatomic)   NSString    *userAgentChunk;

+(LoaderViewController *)open:(NSString *)url  withLaunchingWithOptions:(NSDictionary *)launchOptions;
+(void)reloadFrom:(NSString *)url;
+(void)restart;

//-(id)api:(NSString *)command param:(id)param;
//-(NSString *)JSapi:(NSString *)command param:(NSString *)paramJSON;

-(BOOL)apiCall:(AppDeckApiCall *)call;

-(void)configureApp;

@end