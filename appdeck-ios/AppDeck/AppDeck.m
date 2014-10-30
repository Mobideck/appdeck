//
//  AppDeck.m
//  PhoenixJP.News
//
//  Created by Mathieu De Kermadec on 12/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeck.h"

#import "LoaderViewController.h"
#import "JRSwizzle.h"
#import "RNCachingURLProtocol.h"
#import "ManagedUIWebViewURLProtocol.h"
#import "CookieStorage.h"
#import "WebViewHistory.h"
#import "MobilizeUIWebViewURLProtocol.h"
#import "CacheMonitoringURLProtocol.h"
#import "CustomWebViewFactory.h"
#import "LoaderURLProtocol.h"

@implementation AppDeck

+(AppDeck *)sharedInstance
{
    static AppDeck *appDeck = nil;
    
    if (appDeck == nil)
    {
        appDeck = [[AppDeck alloc] init];
    }
    return appDeck;
}

-(id)init
{
    NSError *error = nil;
    
	[UIWebView jr_swizzleMethod:@selector(webView:identifierForInitialRequest:fromDataSource:) withMethod:@selector(altwebView:identifierForInitialRequest:fromDataSource:) error:&error];
	[UIWebView jr_swizzleMethod:@selector(webView:resource:didFinishLoadingFromDataSource:) withMethod:@selector(altwebView:resource:didFinishLoadingFromDataSource:) error:&error];
  	[UIWebView jr_swizzleMethod:@selector(webView:resource:didFailLoadingWithError:fromDataSource:) withMethod:@selector(altwebView:resource:didFailLoadingWithError:fromDataSource:) error:&error];
  	[UIWebView jr_swizzleMethod:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:) withMethod:@selector(altwebView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:) error:&error];
    
	[UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:animated:) withMethod:@selector(altSetStatusBarHidden:animated:) error:&error];
  	[UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:) withMethod:@selector(altSetStatusBarHidden:) error:&error];
	[UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:withAnimation:) withMethod:@selector(altSetStatusBarHidden:withAnimation:) error:&error];
    
    // init UIWebView engine ASAP: this way we can also start webhistory
    id tmp = [[UIWebView alloc] init];
    tmp = nil;
    
    [CookieStorage loadCookies];
    [WebViewHistory sharedInstance];
    
    self.customWebViewFactory = [[CustomWebViewFactory alloc] init];
    
    [NSURLProtocol registerClass:[ManagedUIWebViewURLProtocol class]];
    [NSURLProtocol registerClass:[MobilizeUIWebViewURLProtocol class]];
    [NSURLProtocol registerClass:[CacheMonitoringURLProtocol class]];
    [NSURLProtocol registerClass:[LoaderURLProtocol class]];
    
    self.cache = [[AppURLCache alloc] init];
    [NSURLCache setSharedURLCache:self.cache];
    
    return self;
}

+(LoaderViewController *)open:(NSString *)url withLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    appDeck.url = url;
    appDeck.loader = [[LoaderViewController alloc] initWithNibName:nil bundle:nil];
    appDeck.loader.appDeck = [AppDeck sharedInstance];
    appDeck.loader.url = [NSURL URLWithString:url];
    appDeck.loader.baseUrl = [NSURL URLWithString:@"/" relativeToURL:appDeck.loader.url];
    appDeck.loader.launchOptions = launchOptions;
    return appDeck.loader;
}

+(void)reloadFrom:(NSString *)url
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    appDeck.loader.url = [NSURL URLWithString:url];
    appDeck.loader.baseUrl = [NSURL URLWithString:@"/" relativeToURL:appDeck.loader.url];

    [appDeck.loader loadConf];
}

+(void)restart
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    appDeck.loader.url = [NSURL URLWithString:appDeck.url];
    appDeck.loader.baseUrl = [NSURL URLWithString:@"/" relativeToURL:appDeck.loader.url];
    
    [appDeck.loader loadConf];
}
@end
