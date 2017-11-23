//
//  MenuViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/02/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MenuViewController.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
#import "PageViewController.h"
#import "ScreenConfiguration.h"
#import "ECSlidingViewController/ECSlidingViewController.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "IOSVersion.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url content:(UIWebView *)content header:(UIWebView *)headerOrNil footer:(UIWebView *)footerOrNil loader:(LoaderViewController *)loader width:(CGFloat) _width align:(MenuAlign)_align
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.url = url;
        self.loader = loader;
        align = _align;
        width = _width;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    if (self.loader.appDeck.iosVersion >= 7.0)
    {
        fakeStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - width, [UIApplication sharedApplication].statusBarFrame.size.height)];
        if (self.loader.conf.icon_theme == IconThemeDark)
            fakeStatusBar.backgroundColor = [UIColor blackColor];
        else
            fakeStatusBar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:fakeStatusBar];
    }
    
    container = [[UIView alloc] initWithFrame:CGRectMake((align == MenuAlignLeft ? 0 : self.view.frame.size.width - width), 0, width, self.view.frame.size.height)];
    [self.view addSubview:container];
    
    //NSLog(@"at load menu frame: %f - %f",  self.view.frame.size.width, self.view.frame.size.height);
    content = [ManagedWebView createManagedWebView];
    content.delegate = self;
    [container addSubview:content.view];
    [self addChildViewController:content];
    
//    content.view.frame = self.view.frame;
    content.scrollView.showsHorizontalScrollIndicator = NO;
    content.scrollView.showsVerticalScrollIndicator = NO;
    content.scrollView.alwaysBounceHorizontal = NO;
    content.scrollView.scrollsToTop = NO;
    [content setChromeless:YES];
    //content.webView.scalesPageToFit = YES;
    [content.webView setBackgroundColor:[UIColor clearColor]];
    content.webView.opaque = NO;

/*    [content.webView setBackgroundColor:self.loader.conf.app_background_color1];
    content.webView.opaque = ![self.loader.conf.app_background_color1 isEqual:[UIColor clearColor]];*/
    
    [self reload];

}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)isMain:(BOOL)isMain
{
    if (isMain)
    {
        [content sendJSEvent:@"appear" withJsonData:nil];
        [content.webView becomeFirstResponder];
    }
    else
        [content sendJSEvent:@"disappear" withJsonData:nil];
}

-(void)reload
{
    NSLog(@"MenuUrl: %@", self.url);
    NSURLRequest *request = nil;
    if (self.loader.conf.enable_clear_cache)
        request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    else
        request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    NSDate *date = nil;
    
    BOOL loadFromCache = NO;

    if ([self.loader.appDeck.cache requestIsInEmbedCache:request])
    {
        loadFromCache = YES;
    }
    else if ([self.loader.appDeck.cache shouldStoreRequest:request])
    {
        if ([self.loader.appDeck.cache requestIsInCache:[NSURLRequest requestWithURL:self.url] date:&date] == YES)
        {
            loadFromCache = YES;
        }
    }
    if (self.loader.conf.enable_clear_cache == YES)
        loadFromCache = NO;
    
    if (loadFromCache)
    {
        /*request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        NSCachedURLResponse *cachedResponse = [self.loader.appDeck.cache cachedResponseForRequest:request];
        [content loadRequest:request withCachedResponse:cachedResponse progess:^(float progress){ } completed:^(NSError *error) { }];*/
        request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [content loadRequest:request progess:^(float progress){ } completed:^(NSError *error) { }];
        
    }
    else
        [content loadRequest:request progess:^(float progress){} completed:^(NSError *error){
        
        if (error != nil)
        {
            hasReload = YES;

            NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
            [content loadRequest:request progess:^(float progress){ } completed:^(NSError *error) { }];
            
        }
        
        }];
    
    
    /*
    if (self.loader.conf.enable_clear_cache == NO && [self.loader.appDeck.cache requestIsInCache:[NSURLRequest requestWithURL:self.url] date:&date] == YES)
    {
        request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        NSCachedURLResponse *cachedResponse = [self.loader.appDeck.cache cachedResponseForRequest:request];
        [content loadRequest:request withCachedResponse:cachedResponse progess:^(float progress){ } completed:^(NSError *error) { }];
    }
    else
        [content loadRequest:request progess:^(float progress){} completed:^(NSError *error){}];*/
    
    [content setBackgroundColor1:self.backgroundColor1 color2:self.backgroundColor2];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)executeJS:(NSString *)js
{
    [content executeJS:js];
    return @"";
}

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    if ([call.command isEqualToString:@"load"])
    {
        return YES;
    }
    
    if ([call.command isEqualToString:@"ready"])
    {
        return YES;
    }
    
    return [self.loader apiCall:call];
}

-(BOOL)managedWebView:(ManagedWebView *)managedWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    LoaderChildViewController *page = [self.loader loadRootPage:request.URL.absoluteString];
    
    if (page.screenConfiguration.isPopUp == NO)
    {
            //[self.slidingViewController resetTopView];
    }
        
    return NO;    
}

#pragma mark - UIWebView delegate
/*
- (BOOL)webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    NSLog(@"should load: %@ - %d - %d", request.URL.absoluteString, _webView.isLoading, navigationType);

    if (navigationType == UIWebViewNavigationTypeOther)
        return YES;

    [self.loader loadRootPage:request.URL.absoluteString];
    
    if (self.loader.slidingViewController.topViewIsOffScreen == YES)
    {
    [self.loader.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
//        CGRect frame = self.slidingViewController.topViewController.view.frame;
//        self.slidingViewController.topViewController = newTopViewController;
//        self.slidingViewController.topViewController.view.frame = frame;
//        [self.loader loadRootPage:request.URL.absoluteString];
//        [self.slidingViewController resetTopView];
        [self.loader.slidingViewController resetTopViewWithAnimations:nil onComplete:^{
            //[self.loader viewWillLayoutSubviews];
        }];
    }];
    }
    
    return NO;
}
*/
#pragma mark - Rotate

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
#ifdef DEBUG_OUTPUT
    NSLog(@"menu frame: %f - %f",  self.view.bounds.size.width, self.view.bounds.size.height);
#endif
    float y = 0;
    if (fakeStatusBar)
    {
        y = [UIApplication sharedApplication].statusBarFrame.size.height;
        fakeStatusBar.frame = CGRectMake((align == MenuAlignLeft ? 0 : self.view.frame.size.width - width), 0, width, [UIApplication sharedApplication].statusBarFrame.size.height);
    }
    container.frame = CGRectMake((align == MenuAlignLeft ? 0 : self.view.frame.size.width - width), y, width, self.view.bounds.size.height - y);
    content.view.frame = CGRectMake(0, 0, width, self.view.bounds.size.height - y);

}

@end
