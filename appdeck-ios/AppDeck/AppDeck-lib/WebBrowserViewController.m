//
//  WebBrowserViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "SwipeViewController.h"
#import "LoaderViewController.h"
#import "GoogleAnalytics/GAI.h"
#import "GoogleAnalytics/GAIFields.h"
#import "GoogleAnalytics/GAIDictionaryBuilder.h"
#import "LoaderConfiguration.h"
#import "ScreenConfiguration.h"
#import "PageBarButtonContainer.h"
#import "PageBarButton.h"
#import "IOSVersion.h"

@interface WebBrowserViewController ()

@end

@implementation WebBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url content:(UIWebView *)content header:(UIWebView *)headerOrNil footer:(UIWebView *)footerOrNil loader:(LoaderViewController *)loader
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.url = url;
        self.loader = loader;
    }
    return self;
}

-(NSURLRequest *)getRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    // if screen ttl == -1
    if (self.screenConfiguration.ttl == -1)
    {
        //cachePolicy = NSURLRequestReloadIgnoringCacheData;
        [request setValue:@"" forHTTPHeaderField:@"If-Modified-Since"];
        [request setValue:@"" forHTTPHeaderField:@"If-None-Match"];
    }
    return request;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initActionButton];
    
    self.content = [[ManagedUIWebViewController alloc] initWithNibName:nil bundle:nil];
    //[content setChromeless:YES];
    [self.view addSubview:self.content.view];
    //self.content.webView.scalesPageToFit = YES;
    self.content.delegate = self;
    self.content.webView.scrollView.delegate = self;
    [self.content setBackgroundColor1:self.loader.conf.app_background_color1 color2:self.loader.conf.app_background_color2];

    [self.swipeContainer child:self startProgressWithExpectedProgress:0.25 inTime:60];
    [self refreshActionButton];

    self.content.catch_link = NO;
    self.content.enable_api = NO;   
    
    [self.content loadRequest:[self getRequest] progess:^(float progress){
        if (progress > 0)
        {
            [self refreshActionButton];
            [self.swipeContainer child:self updateProgressWithProgress:(progress / 100) duration:0.125];
        }
    } completed:^(NSError *error) {
        [self refreshActionButton];
        [self.swipeContainer child:self endProgressDuration:0.125];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressEstimateChanged:) name:@"WebProgressEstimateChangedNotification" object:self.content.coreWebView];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshActionButton) userInfo:nil repeats:YES];    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.swipeContainer.navigationItem.titleView = nil;
    self.swipeContainer.title = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)childIsMain:(BOOL)isMain
{
    [super childIsMain:isMain];
    if (isMain)
    {
        if (self.loader.tracker)
        {
//            [self.loader.tracker sendView:[NSString stringWithFormat:@"Browser %@", self.url.host]];
            [self.loader.tracker set:kGAIScreenName value:[NSString stringWithFormat:@"Browser %@", self.url.host]];
            [self.loader.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
        }
        self.content.webView.scrollView.scrollsToTop = YES;
//        [self.loader.globalTracker trackEventWithCategory:@"browser" withAction:@"MobclixFullScreenAdViewController" withLabel:@"failed" withValue:[NSNumber numberWithInt:1]];
    }
}

#pragma mark - ManagedUIWebViewControllerDelegate

- (NSString *)webView:(UIWebView *)webView runPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame
{
    return @"";
}

- (BOOL)managedUIWebViewController:(ManagedUIWebViewController *)managedUIWebViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

//    [NSURLProtocol setProperty:managedUIWebViewController forKey:@"ManagedUIWebViewController" inRequest:request];    
    
    [managedUIWebViewController loadRequest:request progess:^(float progress) {
        
    } completed:^(NSError *error) {
        
    }];
    
    return NO;
}

#pragma mark - Actions

-(void)refreshActionButton
{
    [buttonPrevious setEnabled:[self.content.webView canGoBack]];
    [buttonNext setEnabled:[self.content.webView canGoForward]];
    [buttonCancel setEnabled:[self.content.webView isLoading]];
    //[buttonRefresh setEnabled:![content.webView isLoading]];
}

-(void)initActionButton
{
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeperator.width = -5;
    [buttons addObject:negativeSeperator];
    
    PageBarButtonContainer *container = [[PageBarButtonContainer alloc] initWithChild:self];
    
    buttonRefresh = [container addButton:@{@"content": @"browser:refresh", @"icon" : @"!refresh"}];
    buttonCancel = [container addButton:@{@"content": @"browser:cancel", @"icon" : @"!cancel"}];
    buttonPrevious = [container addButton:@{@"content": @"browser:back", @"icon" : @"!previous"}];
    buttonNext = [container addButton:@{@"content": @"browser:forward", @"icon" : @"!next"}];
    buttonAction = [container addButton:@{@"content": @"browser:share", @"icon" : @"!action"}];

    
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:container]];
    
    self.rightBarButtonItems = buttons;
    //self.swipeContainer.navigationItem.rightBarButtonItems = buttons;
    
}


-(BOOL)apiCall:(AppDeckApiCall *)call
{
    return [super apiCall:call];
}

-(void)load:(NSString *)url
{
    if ([url hasPrefix:@"browser:back"])
    {
        [self.content.webView goBack];
    }
    else if ([url hasPrefix:@"browser:forward"])
    {
        [self.content.webView goForward];
    }
    else if ([url hasPrefix:@"browser:stop"])
    {
        [self.content.webView stopLoading];
    }
    else if ([url hasPrefix:@"browser:refresh"])
    {
        NSString *webViewUrl = [self.content.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
        [self.swipeContainer child:self startProgressWithExpectedProgress:0.25 inTime:60];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webViewUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        [self.content loadRequest:request progess:^(float progress){
            if (progress > 0)
            {
                [self.swipeContainer child:self updateProgressWithProgress:(progress / 100) duration:0.125];
            }
        } completed:^(NSError *error) {
            [self.swipeContainer child:self endProgressDuration:0.125];
        }];
    }
    else if ([url hasPrefix:@"browser:share"])
    {
        AppDeck *appDeck = [AppDeck sharedInstance];
        if (appDeck.iosVersion >= 6.0)
        {
            NSArray *activityItems = @[self.content.currentRequest.URL];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact ];
            [self presentViewController:activityViewController animated:YES completion:NULL];
        }
    }
    else
        [super load:url];
}

/*
-(UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.loader.conf.icon_theme == IconThemeLight)
        return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
    //return UIStatusBarStyleLightContent;
}
*/
#pragma mark - Rotate

-(UIEdgeInsets)getDefaultContentInset
{
    UIEdgeInsets def = UIEdgeInsetsZero;
    AppDeck *appDeck = [AppDeck sharedInstance];
    if (appDeck.iosVersion >= 7.0 && self.navigationController.navigationBar.translucent)
        def.top = (self.view.frame.size.width > self.view.frame.size.height ? 52 : 64);
    return def;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.content.webView.scrollView.contentInset = [self getDefaultContentInset];
    self.content.webView.scrollView.scrollIndicatorInsets = [self getDefaultContentInset];
    
    self.content.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

@end
