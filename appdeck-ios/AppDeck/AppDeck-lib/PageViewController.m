//
//  pageViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/12/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import "PageViewController.h"
#import "AppURLCache.h"
#import "NSString+MD5.h"
#import "LoaderViewController.h"
#import "UIImage+Resize.h"
#import "QuartzCore/QuartzCore.h"
#import "SwipeViewController.h"
#import "ScreenConfiguration.h"
#import "AppDeckAnalytics.h"
#import "LoaderConfiguration.h"
#import "PageBarButtonContainer.h"
#import "LoaderConfiguration.h"
#import "UIImageView+fromURL.h"
#import "UIColor+Gradient.h"
#import "IOSVersion.h"
#import "UIView+EasingFunctions.h"
#import "AHEasing/easing.h"
#import "AppDeckProgressHUD.h"
#import "LogViewController.h"

#import "AppDeckAdNative.h"
#import "KeyboardStateListener.h"
#import "VCFloatingActionButton.h"
#import "ImageBanner.h"
#import "ImageBannerTest.h"
#import "MyTabBarViewController.h"

#import "MapViewController.h"


@interface PageViewController ()

@end

@implementation PageViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkReloadContent:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.loader.appIsBusy = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(checkReloadContent:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    lastScrollToBottomEventTime = -1;
    lastScrollToBottomEventContentHeight = -1;
    scrollToBottomEventTimeInterval = 0.5;
/*
    // video ad test
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource: @"destiny" withExtension:@"m4v"];
    player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    player.scalingMode = MPMovieScalingModeAspectFill;
    player.movieControlMode = MPMovieControlModeHidden;
    [player prepareToPlay];
    [player.view setFrame: self.view.bounds];  // player's frame must match parent's
    [self.view addSubview:player.view];*/
    
/*    [UIView animateWithDuration:0.5
                     animations:^{
                         player.view.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];*/
    
    [self initialLoad];

    if (self.screenConfiguration.ttl > 0)
        timer = [NSTimer scheduledTimerWithTimeInterval:self.screenConfiguration.ttl target:self selector:@selector(checkReloadContent:) userInfo:nil repeats:YES];
    else
        timer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(checkReloadContent:) userInfo:nil repeats:YES];
    
    //register for iphone application events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    // also register rotation as it is fired
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRotate)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    shouldPatchContentInset = (self.loader.appDeck.iosVersion >= 7.0 && self.navigationController.navigationBar.translucent);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeFromParentViewController
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [contentCtl clean];
    [contentCtl.view removeFromSuperview];
    contentCtl = nil;
    [refreshCtl clean];
    [refreshCtl.view removeFromSuperview];
    refreshCtl = nil;
    
    self.bannerAd = nil;
    self.rectangleAd = nil;
    //self.interstitialAd = nil;
}

-(void)dealloc
{
    if (contentCtl)
        contentCtl.delegate = nil;
    if (refreshCtl)
        refreshCtl.delegate = nil;
    if (self.parentViewController != nil)
        [self removeFromParentViewController];
}

-(void)childIsMain:(BOOL)isMain
{
    BOOL oldIsMain = self.isMain;
    
    [super childIsMain:isMain];

    if (isMain == YES)
    {
//        if (self.loader.appDeck.iosVersion >= 6.0)
//            contentCtl.webView.suppressesIncrementalRendering = NO;
        [contentCtl addURLInOtherHistory:self.url.absoluteString];
        contentCtl.scrollView.scrollsToTop = YES;

        if (shouldReloadInBackground == YES && loadingInprogress == NO)
            if (self.isMain)
                [self loadInBackgroungRequest:contentCtl.currentRequest animated:NO seamless:YES];
        
        // ad state update
        if (_bannerAd)
            _bannerAd.state = AppDeckAdStateAppear;
        if (_rectangleAd)
            _rectangleAd.state = AppDeckAdStateAppear;
        //if (_interstitialAd)
        //    _interstitialAd.state = AppDeckAdStateAppear;
        
        if (oldIsMain != isMain && glLog)
        {
            [glLog info:@"SCREEN [%@]", self.screenConfiguration.title];
        }

        if (oldIsMain != isMain && glLog)
        {
            [contentCtl sendJSEvent:@"appear" withJsonData:nil];
        }
        
        [contentCtl.webView becomeFirstResponder];
    }
    else
    {
//        if (self.loader.appDeck.iosVersion >= 6.0)
//            contentCtl.webView.suppressesIncrementalRendering = YES;
        contentCtl.scrollView.scrollsToTop = NO;
        
         self.bannerAd = nil;
         self.rectangleAd = nil;
         //self.interstitialAd = nil;
        
        if (oldIsMain != isMain && glLog)
        {
            [contentCtl sendJSEvent:@"disappear" withJsonData:nil];
        }
        
/*
        if (_bannerAd)
            _bannerAd.state = AppDeckAdStateDisappear;
        if (_rectangleAd)
            _rectangleAd.state = AppDeckAdStateDisappear;
        if (_interstitialAd)
            _interstitialAd.state = AppDeckAdStateDisappear;
 */
    }
}

/*
-(void)appDidBecomeActive
{

}
*/

#pragma mark - Loading Step

-(void)setupManagedWebView:(ManagedWebView *)managedWebView
{
    [managedWebView setChromeless:YES];
   
    managedWebView.scrollView.contentInset = [self getPageContentInset];
    managedWebView.scrollView.scrollIndicatorInsets = [self getPageContentInset];//[self getDefaultContentInset];
    managedWebView.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);

  //  managedWebView.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    managedWebView.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [managedWebView setBackgroundColor1:self.loader.conf.app_background_color1 color2:self.loader.conf.app_background_color2];
}

-(void)initialLoad
{
    // clean if needed
    [errorImageView removeFromSuperview];
    [errorView removeFromSuperview];
    errorImageView = nil;
    errorView = nil;
    
    if (contentCtl)
    {
        [contentCtl clean];
        contentCtl = nil;
    }
    
    // load
    contentCtl = [ManagedWebView createManagedWebView];
    contentCtl.delegate = self;    
    [self.view addSubview:contentCtl.view];
    [self setupManagedWebView:contentCtl];
    [self enablePullToRefresh:contentCtl];

    NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy;
    BOOL animated = YES;
    loadingInprogress = YES;
    shouldReloadInBackground = NO;
    shouldAnimatedBackgroundReload = NO;
    lastUpdate = [NSDate date];   
    
    NSDate *date = nil;
    // embed cache ?
    if ([self.loader.appDeck.cache requestIsInEmbedCache:[NSURLRequest requestWithURL:self.url]] == YES)
    {
        self.loader.appDidLaunch = NO;
        shouldReloadInBackground = NO;
        shouldAnimatedBackgroundReload = NO;
        animated = NO;
        [self.loader.log info:@"Load from embed cache: %@", self.url.relativePath];
        NSLog(@"Load from embed cache: %@", self.url.relativePath);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [contentCtl loadRequest:request progess:^(float progress) {
            if (animated)
            {
                if (progress == 0)
                    [self.swipeContainer child:self startProgressWithExpectedProgress:0.25 inTime:60];
                else
                    [self.swipeContainer child:self updateProgressWithProgress:(progress / 100) duration:0.125];
            }
        } completed:^(NSError *error) {
            if (animated)
                [self.swipeContainer child:self endProgressDuration:0.125];
            [self setupNextPreviousSwipe];
            
            [self contentCompleted:error]; // do this on last because on error contentCtl is free
        }];
    }
    // cache ?
    else if (self.loader.appDidLaunch == NO && [self.loader.appDeck.cache requestIsInCache:[NSURLRequest requestWithURL:self.url] date:&date] == YES && self.screenConfiguration.ttl != -1)
    {
        cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        if ([date compare:[NSDate dateWithTimeIntervalSinceNow:-self.screenConfiguration.ttl]] == NSOrderedAscending)
        {
            shouldReloadInBackground = YES;
            shouldAnimatedBackgroundReload = YES;
        }
        animated = NO;
        [self.loader.log info:@"Load from cache: %@ (%f seconds old)", self.url.relativePath, [[NSDate date] timeIntervalSinceDate:date]];
        NSLog(@"Load from cache: %@ (%f seconds old)", self.url.relativePath, [[NSDate date] timeIntervalSinceDate:date]);

        NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [contentCtl loadRequest:request progess:^(float progress) {
            if (animated)
            {
                if (progress == 0)
                    [self.swipeContainer child:self startProgressWithExpectedProgress:0.25 inTime:60];
                else
                    [self.swipeContainer child:self updateProgressWithProgress:(progress / 100) duration:0.125];
            }
        } completed:^(NSError *error) {
            if (animated)
                [self.swipeContainer child:self endProgressDuration:0.125];
            [self setupNextPreviousSwipe];
            
            [self contentCompleted:error]; // do this on last because on error contentCtl is free
        }];        
    }
    else
    {
        self.loader.appDidLaunch = NO;
        [self.loader.log info:@"Load from network: %@", self.url.relativePath];
        NSLog(@"Load from network: %@", self.url.relativePath);
        self.loader.appIsBusy = YES;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:cachePolicy timeoutInterval:60];
        // if screen ttl == -1
        if (self.screenConfiguration.ttl == -1)
        {
            //cachePolicy = NSURLRequestReloadIgnoringCacheData;
            [request setValue:@"" forHTTPHeaderField:@"If-Modified-Since"];
            [request setValue:@"" forHTTPHeaderField:@"If-None-Match"];
        }
        [contentCtl loadRequest:request progess:^(float progress){
            if (animated)
            {
                if (progress == 0)
                    [self.swipeContainer child:self startProgressWithExpectedProgress:0.25 inTime:60];
                else
                    [self.swipeContainer child:self updateProgressWithProgress:(progress / 100) duration:0.125];
            }
        } completed:^(NSError *error) {
            if (animated)
                [self.swipeContainer child:self endProgressDuration:0.125];
            [self setupNextPreviousSwipe];
            [self contentCompleted:error]; // do this on last because on error contentCtl is free
        }];
    }
}

-(void)contentCompleted:(NSError *)error
{
    self.loader.appIsBusy = NO;
    if (error != nil)
    {
        //[self.loader showStatusBarError:error.localizedDescription];
//        [contentCtl.webView stopLoading];
//        [contentCtl.webView loadHTMLString:@"" baseURL:nil];
        
        errorView = [[UIView alloc] initWithFrame:self.view.bounds];
        errorView.backgroundColor = [UIColor colorWithGradientHeight:self.view.bounds.size.height
                                                          startColor:self.loader.conf.image_network_error_background_color1
                                                            endColor:self.loader.conf.image_network_error_background_color2];
        
        errorImageView = [UIImageView imageViewFromURL:[NSURL URLWithString:self.loader.conf.image_network_error_url relativeToURL:self.loader.conf.baseUrl] width:self.view.bounds.size.width];
        errorImageView.frame = self.view.bounds;
        
        [errorView addSubview:errorImageView];
        [contentCtl.scrollView addSubview:errorView];
        
        [self.loader.log error:@"load %@ failed: %@", self.url, error.localizedDescription];
        return;
    }
    
#ifdef DEBUG_OUTPUT
    NSLog(@"content is completed");
#endif
    
//    return;
    [self updateWebViewOrientation];
    
    
    if (shouldReloadInBackground == YES)
        if (self.isMain)
            [self loadInBackgroungRequest:contentCtl.currentRequest animated:shouldAnimatedBackgroundReload seamless:YES];
}

-(void)loadInBackgroungRequest:(NSURLRequest *)_request animated:(BOOL)animated seamless:(BOOL)seamless
{
#ifdef DEBUG_OUTPUT
   NSLog(@"should reload in BG !");
    
#endif
    
    shouldReloadInBackground = NO;
    self.loader.appIsBusy = YES;
    refreshCtl = [ManagedWebView createManagedWebView];
    [self.view insertSubview:refreshCtl.view belowSubview:contentCtl.view];
//    if (self.loader.appDeck.iosVersion >= 6.0)
//        refreshCtl.webView.suppressesIncrementalRendering = YES;
    
    refreshCtl.view.hidden = YES;
    [self setupManagedWebView:refreshCtl];
    refreshCtl.delegate = self;

    // remove any pending observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WebProgressEstimateChangedNotification" object:nil];
    
    if (animated)
        [self.swipeContainer child:self startProgressWithExpectedProgress:0.25 inTime:60];
    
    NSMutableURLRequest *request = [_request mutableCopy];
    if (self.loader.conf.enable_clear_cache)
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    else
        request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [request setValue:@"" forHTTPHeaderField:@"If-Modified-Since"];
    [request setValue:@"" forHTTPHeaderField:@"If-None-Match"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    __block PageViewController *me = self;
    [refreshCtl loadRequest:request progess:^(float progress){
        if (self == nil || me == nil)
            return;
        if (progress > 0)
        {
            if (animated)
                [me.swipeContainer child:me updateProgressWithProgress:(progress / 100) duration:0.125];
        }
        [me setupNextPreviousSwipe];
    } completed:^(NSError *error) {
        if (self == nil || me == nil)
            return;
        if (animated)
            [me.swipeContainer child:self endProgressDuration:0.125];
        [me refreshCompleted:error animated:animated seamless:seamless];
        if (error == nil && me != nil && self != nil)
            [me setupNextPreviousSwipe];
    }];
}

-(UIEdgeInsets)getDefaultContentInset
{
    UIEdgeInsets def = UIEdgeInsetsZero;
    if (shouldPatchContentInset)
        def.top = (self.view.frame.size.width > self.view.frame.size.height ? 52 : 64);
    if (showLoading)
        def.top += pullTorefreshArrow.frame.size.height * 1.5;    
    return def;
}

-(UIEdgeInsets)getPageContentInset
{
    UIEdgeInsets def = [self getDefaultContentInset];
    if (_rectangleAd)
    {
        def.top += _rectangleAd.height;
    }
    // add navigationbar
    if (/* DISABLES CODE */ (NO))
    {
        def.top += 64;
    }
    return def;
}


-(void)refreshCompleted:(NSError *)error animated:(BOOL)animated seamless:(BOOL)seamless
{
    showLoading = NO;
    self.loader.appIsBusy = NO;
    if (error != nil)
    {
        // disable mask if needed
        [contentCtl disableMask];
        //[self.loader showStatusBarError:@"La mise à jour a échoué"];
        [refreshCtl clean];
        refreshCtl = nil;
        [self restoreCleanPullToRefreshState:contentCtl];
        return;
    }

#ifdef DEBUG_OUTPUT
    NSLog(@"refresh is completed");
#endif
    
    lastUpdate = [NSDate date];
    
    [UIView animateWithDuration:0.25 animations:^{
        if (contentCtl == nil || refreshCtl == nil)
            return;
        
        pullTorefreshLoading.alpha = 0.0;
        [contentCtl.scrollView setContentInset:[self getPageContentInset]];
        [contentCtl.scrollView setScrollIndicatorInsets:[self getPageContentInset]];
        
    } completion:^(BOOL finished) {

        if (contentCtl == nil || refreshCtl == nil)
            return;
        
        refreshCtl.view.hidden = NO;
        
        UIEdgeInsets contentInset = contentCtl.scrollView.contentInset;
        CGPoint contentOffset = contentCtl.scrollView.contentOffset;
        
        if (seamless)
        {
            refreshCtl.scrollView.scrollsToTop = contentCtl.scrollView.scrollsToTop;
            
/*            [contentCtl evaluateJavaScript:@"$(window).scrollTop();" completionHandler:^(id scrollTop, NSError *error) {
                [refreshCtl evaluateJavaScript:[NSString stringWithFormat:@"$(window).scrollTop(%@);", scrollTop] completionHandler:^(id result, NSError *error) {

                }];
            }];*/
            
//            NSString *scrollTop = [contentCtl stringByEvaluatingJavaScriptFromString:@"$(window).scrollTop();"];
//            [refreshCtl stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$(window).scrollTop(%@);", scrollTop]];
            
            [refreshCtl.scrollView setContentInset:contentInset];
            [refreshCtl.scrollView setContentOffset:contentOffset];
            [refreshCtl.scrollView setScrollIndicatorInsets:[self getPageContentInset]];
        }
        
        // put rectangle ad in parent view
        
        if (_rectangleAd)
        {
            if ([_rectangleAd.view isDescendantOfView:contentCtl.scrollView])
            {
                [_rectangleAd removeFromParentViewController];
                [_rectangleAd.view removeFromSuperview];
            }
            [self addChildViewController:_rectangleAd];
            [self.view addSubview:_rectangleAd.view];
            [self.view bringSubviewToFront:refreshCtl.view];
            [self.view bringSubviewToFront:contentCtl.view];
            [self adjustRectangleAdView];
        }
        
        [UIView transitionFromView:contentCtl.view
                            toView:refreshCtl.view
                          duration:0.125
                           options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve
         | UIViewAnimationOptionAllowUserInteraction
                        completion:^(BOOL finished){
                            
                            if (_rectangleAd)
                            {
                                [_rectangleAd removeFromParentViewController];
                                [_rectangleAd.view removeFromSuperview];
                            }
                            
                            [self disablePullToRefresh:contentCtl];
                            [self enablePullToRefresh:refreshCtl];
                            
                            [contentCtl clean];
                            contentCtl = refreshCtl;
                            contentCtl.delegate = self;
                            refreshCtl = nil;
                            [self setupNextPreviousSwipe];
                            [self updateWebViewOrientation];
                            
                            [contentCtl executeJS:@"app.refreshUI();"];
                            //                        [self initButton];
                            // anime all next sub load
                            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressEstimateChanged:) name:@"WebProgressEstimateChangedNotification" object:contentCtl.coreWebView];
                            [self viewWillLayoutSubviews];
                        }];
        }];
}

-(void)applicationWillEnterForeground
{
    if (self.isMain)
        [self.loader.adManager pageViewController:self appearWithEvent:AdManagerEventWakeUp];
    shouldForceReloadInBackground = YES;
    [self checkReloadContent:nil];
}

- (void)willRotate
{
    [self performSelectorOnMainThread:@selector(checkReloadContent:) withObject:nil waitUntilDone:NO];
}

-(void)checkReloadContent:(id)origin
{
    if (self.loader.appRunInBackground == YES)
    {
        NSLog(@"checkReloadContent: don't refresh as application is in background");
        return;
    }
    if (self.screenConfiguration.ttl == 0)
    {
        NSLog(@"checkReloadContent: don't refresh this page as screen.ttl == 0");
        return;
    }
    if (lastUpdate == nil)
    {
        NSLog(@"checkReloadContent: don't refresh this page as last update is unknow");
        return;
    }
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:lastUpdate];

    // if reload from long time ago we move page to top
    NSTimeInterval lastUpdateInterval = [[NSDate date] timeIntervalSinceDate:lastUpdate];

    if (self.screenConfiguration.ttl == -1)
    {
        if (lastUpdateInterval > 600 * 60)
        {
            NSLog(@"checkReloadContent: Refresh this page as screen.ttl = -1 and last reload : %f seconds ago > %d * 10", lastUpdateInterval, 600 * 10);
            [self reLoadContent];
        } else {
            NSLog(@"checkReloadContent: don't refresh this page as screen.ttl = -1 and last reload : %f seconds ago > %d * 10", lastUpdateInterval, 600 * 10);
        }
        return;
    }
    
    if (lastUpdateInterval > self.screenConfiguration.ttl * 60)
    {
        NSLog(@"checkReloadContent: last reload long time ago: %f seconds ago > %ld * 10, we auto scroll to top then reload", lastUpdateInterval, self.screenConfiguration.ttl * 10);
        [contentCtl.scrollView setContentOffset:CGPointZero animated:YES];
        [self reLoadContent];
        return;
    }
    
    if (time > self.screenConfiguration.ttl)
    {
        NSLog(@"checkReloadContent: Refresh as last update: %f seconds ago. Screen TTL: %ld seconds", time, self.screenConfiguration.ttl);
        [self reLoadContent];
        return;
    }

    if (shouldForceReloadInBackground == YES)
    {
        shouldForceReloadInBackground = NO;
//        NSString *input = [[NSProcessInfo processInfo] globallyUniqueString];
        
        [contentCtl evaluateJavaScript:@"app.healthCheck('ping')" completionHandler:^(id ping, NSError *error) {
            if (![ping isKindOfClass:[NSString class]] || [ping isEqualToString:@"ok:ping"] == NO) {
                NSLog(@"checkReloadContent: forced, we try to ping page but it reply '%@' instead of 'ok:ping'", ping);
                [self reLoadContent];
                return;
            }
        }];
    }
    NSLog(@"checkReloadContent: don't Refresh as last update: %f seconds ago. Screen TTL: %ld seconds", time, self.screenConfiguration.ttl);
}

-(void)reload
{
    [self reLoadContent];
}

-(void)reLoadContent
{
    /*if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    if (self.screenConfiguration.ttl > 0)
        timer = [NSTimer scheduledTimerWithTimeInterval:self.screenConfiguration.ttl target:self selector:@selector(reLoadContentFromTimer:) userInfo:nil repeats:NO];*/
    // cancel current refresh if exist
    if (refreshCtl == nil)
    {
        NSLog(@"reLoadContent for %@", self.url);
        // stats
//        [self.loader.globalTracker trackEventWithCategory:@"child" withAction:@"reload" withLabel:self.url.absoluteString withValue:[NSNumber numberWithInt:1]];
        
        [self.loader.analytics sendEventWithName:@"child" action:@"reload" label:self.url.absoluteString value:[NSNumber numberWithInt:1]];       
        
        if (errorView)
            [self initialLoad];
        else
            [self loadInBackgroungRequest:contentCtl.currentRequest animated:YES seamless:YES];
    } else
        NSLog(@"can't reLoadContent for %@, reload in progress", self.url);
}

#pragma mark - next/previous page by swipe

-(void)setupNextPreviousSwipe
{
    if (self.loader.appDeck.iosVersion >= 6.0)
        return;
    if (self.nextUrl == nil)
    {
        [contentCtl evaluateJavaScript:@"var meta = document.getElementById('meta-next-page'); if (meta) meta.content" completionHandler:^(id next_url, NSError *error) {
            if (next_url != nil && [next_url isKindOfClass:[NSString class]] && [next_url isEqualToString:@""] == NO) {
                NSLog(@"next page: %@", next_url);
                self.nextUrl = [NSURL URLWithString:next_url relativeToURL:self.url];
                [self.swipeContainer insertNextChildView];
            }
        }];
    }
    if (self.previousUrl == nil)
    {
        [contentCtl evaluateJavaScript:@"var meta = document.getElementById('meta-previous-page'); if (meta) meta.content" completionHandler:^(id prev_url, NSError *error) {
            if (prev_url != nil && [prev_url isKindOfClass:[NSString class]] && [prev_url isEqualToString:@""] == NO) {
                NSLog(@"previous page: %@", prev_url);
                self.previousUrl = [NSURL URLWithString:prev_url relativeToURL:self.url];
                [self.swipeContainer insertPreviousChildView];
            }
        }];
    }
}

#pragma mark - setup button page by swipe

#pragma mark - Action button

/*
-(void)initButton
{
    NSString *js = @"var res = function(){\
	var entries = new Array();\
	Array.prototype.forEach.call(document.getElementsByTagName('meta'), function(meta){ if (meta.name == 'appdeck-menu-entry')\
    {\
        var entry = {};\
        for (var k = 0; k < meta.attributes.length; k++) {\
            var attr = meta.attributes[k];\
            if(attr.name != 'class')\
                entry[attr.name] = attr.value;\
        }\
        entries.push(entry);\
    }\
	});\
	return JSON.stringify(entries);\
}(); res;";
    
    id obj = [contentCtl JSonObjectByEvaluatingJavascriptFromString:js error:nil];
    if (obj == nil)
        return;
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];

    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeperator.width = -5;
    [buttons addObject:negativeSeperator];
    
    PageBarButtonContainer *container = [[PageBarButtonContainer alloc] initWithChild:self];
    
    for (NSDictionary *entry in obj)
    {
        [container addButton:entry];
    }
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:container]];
   
    if (self.swipeContainer.navigationItem.rightBarButtonItems == nil)
    {
        container.alpha = 0;
        [UIView animateWithDuration:0.125
                     animations:^{
                         container.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    }

    self.rightBarButtonItems = buttons;
    if (self.isMain)
        self.swipeContainer.navigationItem.rightBarButtonItems = buttons;
}*/

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    if ([call.command isEqualToString:@"postmessage"])
    {
        NSString *js = [NSString stringWithFormat:@"try {app.receiveMessage(%@.param);} catch (e) {}", call.inputJSON];
        [self.loader executeJS:js];
        return YES;
    }
    
    if ([call.command isEqualToString:@"disable_pulltorefresh"])
    {
        [self disablePullToRefresh:contentCtl];
        return YES;
    }
    if ([call.command isEqualToString:@"enable_pulltorefresh"])
    {
        [self enablePullToRefresh:contentCtl];
        return YES;
    }
    if ([call.command isEqualToString:@"nativead"])
    {
        /*
        NSString *divId = [NSString stringWithFormat:@"%@", [call.param objectForKey:@"id"]];
        if (nativeAds == nil)
            nativeAds = [[NSMutableDictionary alloc] init];
        AppDeckAdNative *nativeAd = [nativeAds objectForKey:divId];
        if (nativeAd == nil)
        {
            nativeAd = [[AppDeckAdNative alloc] init];
            [nativeAds setObject:nativeAd forKey:divId];
        }
        [nativeAd addApiCall:call];  */   
        return YES;
    }

    if ([call.command isEqualToString:@"nativeadclick"])
    {
        NSString *divId = [NSString stringWithFormat:@"%@", [call.param objectForKey:@"id"]];
        AppDeckAdNative *nativeAd = [nativeAds objectForKey:divId];
        if (nativeAd != nil)
        {
            [nativeAd click:self];
        }
        return YES;
    }
    if ([call.command isEqualToString:@"disable_cache"])
    {
        [self.loader.appDeck.cache removeCachedResponseForRequest:contentCtl.currentRequest];
        return YES;
    }
    
    if ([call.command isEqualToString:@"disable_ad"])
    {
        self.disableAds = YES;
        self.bannerAd = nil;
        self.rectangleAd = nil;
        //self.interstitialAd = nil;
        return YES;
    }    
    
    if ([call.command isEqualToString:@"load"])
    {
        return YES;
    }
    
    if ([call.command isEqualToString:@"ready"])
    {
        [self.swipeContainer child:self endProgressDuration:0.125];
        self.showProgress = NO;
        return YES;
    }
    
    if ([call.command isEqualToString:@"menu"])
    {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -5;
        [buttons addObject:negativeSeperator];
        
        PageBarButtonContainer *container = [[PageBarButtonContainer alloc] initWithChild:self];
                
        for (NSDictionary *entry in call.param)
        {
            [container addButton:entry];
        }
        [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:container]];
        
        if (container.count == 0)
            buttons = nil;
        
        self.rightBarButtonItems = buttons;
        if (self.isMain)
            self.swipeContainer.navigationItem.rightBarButtonItems = buttons;
        
    }
    
    if ([call.command isEqualToString:@"floating"])
    {
        
        NSMutableArray*buttons= [[NSMutableArray alloc]init];
        
        for (NSDictionary*dict in call.param)
        {
            [buttons addObject:dict];
        }
        
        CGRect floatFrame = CGRectMake(self.view.bounds.size.width - 44 - 20, self.view.bounds.size.height - 44 - 20, 44, 44);
        
        VCFloatingActionButton*addButton  = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"plus"] andPressedImage:[UIImage imageNamed:@"cross"] withScrollview:nil];
        
        addButton.buttonsArray = buttons;
        addButton.child=self;
        addButton.call=call;
        
        addButton.hideWhileScrolling = NO;
        
        [self.view addSubview:addButton];
        
        return YES;
    }
    
    if ([call.command isEqualToString:@"banner"])
    {
        if(!imageBanner){
            imageBanner = [[ImageBanner alloc] init];
            imageBanner.height= [call.param[@"height"] floatValue];
            imageBanner.frame=CGRectMake(0, 0, self.view.frame.size.width,imageBanner.height);
            [self.view addSubview:imageBanner];
        }
        [imageBanner addImage:call.param];
        
        return YES;
    }

    if ([call.command isEqualToString:@"info"])
    {

    }
    
    if ([call.command isEqualToString:@"tab"])
    {
        
        if ((!tabBarController)) {
            tabBarController=[[MyTabBarViewController alloc]initWithLoaderChild:self];
            [[self.loader getNavController] pushViewController:tabBarController animated:YES];

        }
        
        [tabBarController loadWithItem:call.param url:[NSURL URLWithString:call.param[@"content"]]];
        
        return YES;
    }
    
    if ([call.command isEqualToString:@"map"])
    {
        
        MapViewController*mapVC=[[MapViewController alloc]init];
        
        NSLog(@"call %@",call.param);
        mapVC.call = call;
        mapVC.child=self;
        mapVC.screenConfiguration = call.child.screenConfiguration;
        mapVC.title = mapVC.screenConfiguration.title;
        
        [self.loader loadChild:mapVC root:NO popup:LoaderPopUpYes];
        
        return YES;
        
    }
    
    if ([call.command isEqualToString:@"loadingshow"])
    {
        AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self];
        appdeckProgressHUD.graceTime = 0.0;
        appdeckProgressHUD.minShowTime = 0.0;
        [appdeckProgressHUD show];
        return YES;
    }

    if ([call.command isEqualToString:@"loadingset"])
    {
        return YES;
    }
    
    if ([call.command isEqualToString:@"loadinghide"])
    {
        AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self];
        [appdeckProgressHUD hide];
        return YES;
    }
    
    return [super apiCall:call];
}

-(void) didSelectMenuOptionAtIndex:(NSInteger)row{
    
}

-(void)load:(NSString *)url
{

    if ([url hasPrefix:@"javascript:"])
    {
        url = [url substringFromIndex:11];
        [contentCtl executeJS:url];
        return;
    }
    
    [contentCtl loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url relativeToURL:self.url]] progess:nil completed:nil];
}

-(NSString *)executeJS:(NSString *)js
{
    if (contentCtl)
        [contentCtl executeJS:js];
    return @"";
}

#pragma mark - CustomUIWebView

- (NSString *)managedWebView:(ManagedWebView *)managedWebView runPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame
{
    if ([prompt isEqualToString:@"event:ready"])
    {
        
    }
    else if ([prompt isEqualToString:@"event:open"])
    {
        [self.loader loadPage:defaultText];
        return @"";
    }
    else if ([prompt isEqualToString:@"event:mobilize"])
    {
        defaultText = [defaultText stringByReplacingOccurrencesOfString:@"http://" withString:@"mobilize://"];
        [self.loader loadPage:defaultText];
        return @"";
    }
    return @"";
}

- (BOOL)managedWebView:(ManagedWebView *)managedWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    if ([request.HTTPMethod isEqualToString:@"POST"])
    {
        [self loadInBackgroungRequest:request animated:YES seamless:NO];
        return NO;
    }
    if ([self.screenConfiguration isRelated:request.URL])
    {
        if (glLog)
        {
            [glLog info:@"Same SCREEN [%@] <=> [%@]", self.screenConfiguration.title, request.URL.absoluteString];
        }
        NSDate *date = nil;
        if ([self.loader.appDeck.cache requestIsInCache:request date:&date] == YES)
        {
            if ([date compare:[NSDate dateWithTimeIntervalSinceNow:-self.screenConfiguration.ttl]] != NSOrderedAscending)
            {
                NSLog(@"Load from cache: %@ (%f seconds old)", request.URL.relativePath, [[NSDate date] timeIntervalSinceDate:date]);
                
                [contentCtl setMaskColor:[UIColor blackColor] opcacity:0.5 anim:1.0 userInteractionEnabled:NO];
                
                NSMutableURLRequest *cachedRequest = [request mutableCopy];
                cachedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
                [self loadInBackgroungRequest:cachedRequest animated:NO seamless:NO];
                return NO;
            }
        }
        [self loadInBackgroungRequest:request animated:YES seamless:NO];
        return NO;
    }

    __block NSString *absoluteURL = request.URL.absoluteString;
    NSString *javascript = [NSString stringWithFormat:@"app.client.rewriteURL('%@')", absoluteURL];
    [contentCtl evaluateJavaScript:javascript completionHandler:^(id newAbsoluteURL, NSError *error) {
        if (newAbsoluteURL != nil && ([newAbsoluteURL hasPrefix:@"http://"] || [newAbsoluteURL hasPrefix:@"https://"]))
            absoluteURL = newAbsoluteURL;
        NSURL *newURL = [NSURL URLWithString:absoluteURL];
        
        if (self.isPopUp)
        {
            [self.loader closePopUp:nil];
            if (self.parent != nil)
                [self.parent load:absoluteURL];
            else
                [self.loader loadRootPage:absoluteURL];
            return;
        }
        if ([newURL.host isEqualToString:self.url.host])
        {
            [self.loader loadPage:absoluteURL];
            return;
        }
        [self.loader loadPage:absoluteURL];
    }];

    return NO;
}

#pragma mark - UIScrollViewDelegate

-(void)restoreCleanPullToRefreshState:(ManagedWebView *)webView
{
    if ([pullTorefreshArrow isDescendantOfView:webView.scrollView])
    {
        pullTorefreshArrow.hidden = YES;
        pullTorefreshArrow.alpha = 0;
    }
    if ([pullTorefreshLoading isDescendantOfView:webView.scrollView])
    {
        [pullTorefreshLoading stopSpin];
        pullTorefreshLoading.hidden = YES;
        pullTorefreshLoading.alpha = 0;
    }
    [UIView animateWithDuration:0.125
                     animations:^{
                         webView.scrollView.contentInset = [self getPageContentInset];
                     }
                     completion:^(BOOL finished){
                         if ([pullTorefreshArrow isDescendantOfView:webView.scrollView])
                             pullTorefreshArrow.hidden = NO;
                         if ([pullTorefreshLoading isDescendantOfView:webView.scrollView])
                             pullTorefreshLoading.hidden = NO;
                     }];
}

-(void)disablePullToRefresh:(ManagedWebView *)webView
{
    if ([pullTorefreshArrow isDescendantOfView:webView.scrollView])
        [pullTorefreshArrow removeFromSuperview];
    if ([pullTorefreshLoading isDescendantOfView:webView.scrollView])
        [pullTorefreshLoading removeFromSuperview];
    if (_rectangleAd && [_rectangleAd.view isDescendantOfView:webView.scrollView])
    {
        [_rectangleAd removeFromParentViewController];
        [_rectangleAd.view removeFromSuperview];
    }
    webView.scrollView.delegate = nil;
    webView.scrollView.contentInset = [self getPageContentInset];
    //pullTorefreshArrow = nil;
    //pullTorefreshLoading = nil;
}

-(void)adjustRefreshFrame
{
    UIEdgeInsets defaultInsets = [self getDefaultContentInset];
    UIEdgeInsets pageInsets = [self getPageContentInset];

/*    pullTorefreshArrow.frame = CGRectMake(self.view.frame.size.width / 2 - pullTorefreshArrow.frame.size.width / 2,
                                          -(pageInsets.top - defaultInsets.top) - 1.25 * pullTorefreshArrow.frame.size.height,
                                          pullTorefreshArrow.frame.size.width, pullTorefreshArrow.frame.size.height);*/
    
    pullTorefreshArrow.frame = CGRectMake(self.view.frame.size.width / 2 - pullTorefreshArrow.frame.size.width / 2,
                                          -(pageInsets.top - defaultInsets.top) - 1.25 * pullTorefreshArrow.frame.size.height,
                                          pullTorefreshArrow.frame.size.width, pullTorefreshArrow.frame.size.height);
    pullTorefreshLoading.frame = pullTorefreshArrow.frame;
}

- (void)enablePullToRefresh:(ManagedWebView *)webView
{
    if (pullTorefreshArrow == nil || pullTorefreshLoading == nil)
    {
        pullTorefreshArrow = [[UIImageView alloc] initWithImage:self.loader.conf.image_pull_arrow.image];
        
        pullTorefreshLoading = [[UIImageView alloc] initWithImage:self.loader.conf.image_loader.image];;
        pullLoadingPercent = 0.0;

        // we divide image size by 2 for retina
        pullTorefreshArrow.frame = CGRectMake(0, 0, pullTorefreshArrow.frame.size.width / 2, pullTorefreshArrow.frame.size.height / 2);
        [self adjustRefreshFrame];
        
    }
    webView.scrollView.delegate = self;
    [pullTorefreshArrow removeFromSuperview];
    [pullTorefreshLoading removeFromSuperview];
    [webView.scrollView addSubview:pullTorefreshArrow];
    [webView.scrollView addSubview:pullTorefreshLoading];
    
    if (_rectangleAd)
    {
        if (webView == contentCtl)
            [self configureRectangleAdViewForManagedWebView:contentCtl adjustInset:NO];
        else if (webView == refreshCtl)
            [self configureRectangleAdViewForManagedWebView:refreshCtl adjustInset:NO];
    }

    pullTorefreshArrow.hidden = YES;
    pullTorefreshLoading.hidden = YES;
    pullTorefreshArrow.alpha = 0;
    pullTorefreshLoading.alpha = 0;

    //[webView.layer removeAllAnimations];
    //[webView.scrollView.layer removeAllAnimations];
    [pullTorefreshArrow.layer removeAllAnimations];
    [pullTorefreshLoading.layer removeAllAnimations];

    [pullTorefreshArrow layer].transform = CATransform3DIdentity;
    
    [UIView animateWithDuration:0.125
                     animations:^{
                         webView.scrollView.contentInset = [self getPageContentInset];
                     }
                     completion:^(BOOL finished){
                         if ([pullTorefreshArrow isDescendantOfView:webView.scrollView])
                             pullTorefreshArrow.hidden = NO;
                         if ([pullTorefreshLoading isDescendantOfView:webView.scrollView])
                             pullTorefreshLoading.hidden = NO;
                     }];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll: contentOffset.y: %f contentSize.height: %f", scrollView.contentOffset.y, scrollView.contentSize.height);
   
    
    float content_height = scrollView.contentSize.height;
    int content_height_limit = content_height - scrollView.frame.size.height - scrollView.frame.size.height / 2;
    if (true)
    {
        if (scrollView.contentOffset.y > content_height_limit && content_height_limit > 0)
        {
            NSTimeInterval scrollToBottomEventTime = [[NSDate date] timeIntervalSince1970];;
            NSTimeInterval scrollEventTimeDiff = scrollToBottomEventTime - lastScrollToBottomEventTime;
            
            if (scrollEventTimeDiff > scrollToBottomEventTimeInterval && lastScrollToBottomEventContentHeight != content_height)
            {
                NSLog(@"scrollToBottom");
                lastScrollToBottomEventTime = scrollToBottomEventTime;
                lastScrollToBottomEventContentHeight = content_height;
                [contentCtl sendJSEvent:@"scrollToBottom" withJsonData:nil];
            }
        }
    }
    
/*
    CFRunLoopStop(CFRunLoopGetMain());
    
    NSLog(@"mode: %@", CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent()));
    NSLog(@"scrollViewDidScroll");
    
    id app = [UIApplication sharedApplication];
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [app performSelector:NSSelectorFromString(@"pushRunLoopMode:") withObject:kCFRunLoopDefaultMode];
#pragma clang diagnostic pop

    SInt32 result = 0;
    do {
        NSLog(@"run loop %d", (int)result);
        result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.000002, TRUE);
    } while (result == kCFRunLoopRunHandledSource);

    
    ///kCFRunLoopDefaultMode
//    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, NO);

//    CFRunLoopRun();

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [app performSelector:NSSelectorFromString(@"popRunLoopMode:") withObject:kCFRunLoopDefaultMode];
#pragma clang diagnostic pop
    */

    UIEdgeInsets defaultInsets = [self getDefaultContentInset];
    UIEdgeInsets pageInsets = [self getPageContentInset];

    float position = (pageInsets.top - defaultInsets.top) + scrollView.contentOffset.y + defaultInsets.top;
    
    // ajust rectangleAdView if exist
    if (_rectangleAd)
        [self adjustRectangleAdView];
    
    // pull To refresh
    if (position >= 0)
    {

    }
    else if (-position > pullTorefreshArrow.frame.size.height * 1.5)
    {
        pullTorefreshArrow.alpha = 1;
        if (CATransform3DIsIdentity(pullTorefreshArrow.layer.transform) == YES)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            [pullTorefreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            [UIView commitAnimations];
        }
    }
    else
    {
        pullTorefreshArrow.alpha = (-position) / (pullTorefreshArrow.frame.size.height * 1.5);
        if (CATransform3DIsIdentity(pullTorefreshArrow.layer.transform) == NO)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            [pullTorefreshArrow layer].transform = CATransform3DIdentity;
            [UIView commitAnimations];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self scrollViewWillBegin:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    UIEdgeInsets defaultInsets = [self getPageContentInset];
    UIEdgeInsets pageInsets = [self getPageContentInset];
    
    float position = (pageInsets.top - defaultInsets.top) + scrollView.contentOffset.y + defaultInsets.top;
    
    if (scrollView.isDecelerating == NO)
    {
        [self scrollViewDidEnd:scrollView];        
    }
    if (-position > pullTorefreshArrow.frame.size.height * 1.5)
    {
        pullTorefreshArrow.hidden = YES;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        pullTorefreshLoading.alpha = 1;
        showLoading = YES;
        UIEdgeInsets contentInsets = [self getPageContentInset];
        scrollView.contentInset = contentInsets;
        [UIView commitAnimations];
        [pullTorefreshLoading startSpin];
        [self reLoadContent];
    }
}

#pragma mark ScrollView Helper

- (void)scrollViewWillBegin:(UIScrollView *)scrollView
{
    [contentCtl executeJS:@"if (typeof(fastclick) != 'undefined' && typeof(fastclick.trackingDisabled) != 'undefined') fastclick.trackingDisabled = true;"];
    //[contentCtl.webView stringByEvaluatingJavaScriptFromString:@"if (typeof(fastclick) != 'undefined' && typeof(fastclick.globalDisable) != 'undefined') fastclick.globalDisable = true;"];
}

- (void)scrollViewDidEnd:(UIScrollView *)scrollView
{
    [contentCtl executeJS:@"if (typeof(fastclick) != 'undefined' && typeof(fastclick.trackingDisabled) != 'undefined') fastclick.trackingDisabled = false;"];
    //[contentCtl.webView stringByEvaluatingJavaScriptFromString:@"if (typeof(fastclick) != 'undefined' && typeof(fastclick.globalDisable) != 'undefined') fastclick.globalDisable = false;"];
}


#pragma mark - AdView

-(void)setBannerAd:(AppDeckAdViewController *)bannerAd
{
    if (_bannerAd)
    {
        AppDeckAdViewController *old = _bannerAd;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^(){
            old.view.alpha = 0.0;
        } completion:^(BOOL finished) {
/*            if (old.state == AppDeckAdStateAppear)
                old.state = AppDeckAdStateClose;*/
            
            [old removeFromParentViewController];
            [old.view removeFromSuperview];
            old.page = nil;
            old.state = AppDeckAdStateClose;
            
        }];
    }
    
    _bannerAd = bannerAd;
    _bannerAd.page = self;
    
    if (_bannerAd == nil)
    {
        [self viewWillLayoutSubviews];
        self.adRequest = nil;
        return;
    }

    [self addChildViewController:_bannerAd];
    [self.view addSubview:_bannerAd.view];
    
    [self animateBannerAd];
    
    _bannerAd.state = AppDeckAdStateLoad;
    if (self.isMain)
        _bannerAd.state = AppDeckAdStateAppear;
    
}

/*
-(void)setInterstitialAd:(AppDeckAdViewController *)interstitialAd
{
    if (_interstitialAd)
    {
        AppDeckAdViewController *old = _interstitialAd;
        old.page = nil;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^(){
            old.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        //if (old.state == AppDeckAdStateAppear)
        //        old.state = AppDeckAdStateDisappear;
            
            [old removeFromParentViewController];
            [old.view removeFromSuperview];
            old.page = nil;
            old.state = AppDeckAdStateClose;
        }];
    }
    
    _interstitialAd = interstitialAd;
   
    if (_interstitialAd == nil)
    {
        self.swipeContainer.swipeEnabled = YES;
        self.isFullScreen = NO;
        self.adRequest = nil;
        return;
    }

    _interstitialAd.page = self;    
    
    self.swipeContainer.swipeEnabled = NO;
    self.isFullScreen = YES;
    
    _interstitialAd.page = self;
    
    [self addChildViewController:_interstitialAd];
    [self.view addSubview:_interstitialAd.view];
    
    _interstitialAd.view.alpha = 0.0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^(){
        
        _interstitialAd.view.alpha = 1.0;
        
    } completion:^(BOOL finished) {

    }];

    _interstitialAd.state = AppDeckAdStateLoad;
    
    //[contentCtl addChildViewController:_interstitialAd];
    //[contentCtl.webView.scrollView addSubview:_interstitialAd.view];
    
    if (self.isMain)
        _interstitialAd.state = AppDeckAdStateAppear;
    
}
*/
-(void)setRectangleAd:(AppDeckAdViewController *)rectangleAd
{
    if (_rectangleAd)
    {
        AppDeckAdViewController *old = _rectangleAd;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^(){
            //old.view.alpha = 0.0;
            //old.view.frame = CGRectZero;
            UIEdgeInsets defaultInsets = [self getDefaultContentInset];
            contentCtl.scrollView.contentInset = defaultInsets;
            //[self adjustRectangleAdView];
        } completion:^(BOOL finished) {
/*            if (old.state == AppDeckAdStateAppear)
                old.state = AppDeckAdStateDisappear;*/
            
            [old removeFromParentViewController];
            [old.view removeFromSuperview];
            old.page = nil;
            old.state = AppDeckAdStateClose;
        }];
    }
    
    _rectangleAd = rectangleAd;
    _rectangleAd.page = self;
    
    if (_rectangleAd == nil)
    {
        contentCtl.scrollView.contentInset = [self getPageContentInset];
        [self viewWillLayoutSubviews];
        self.adRequest = nil;
        return;
    }
    
    if (contentCtl)
    {
        [contentCtl addChildViewController:_rectangleAd];
        [contentCtl.scrollView addSubview:_rectangleAd.view];
        [self configureRectangleAdViewForManagedWebView:contentCtl adjustInset:YES];
    } else {
        [self addChildViewController:_rectangleAd];
        [self.view addSubview:_rectangleAd.view];
        
    }
    
    _rectangleAd.state = AppDeckAdStateLoad;
    if (self.isMain)
        _rectangleAd.state = AppDeckAdStateAppear;
    
    [_rectangleAd.view setNeedsDisplay];
    
    [self viewWillLayoutSubviews];
    
}

-(void)animateBannerAd
{
    bannerAdAnimating = YES;

//    [bannerAd.view setEasingFunction:ElasticEaseInOut forKeyPath:@"frame"];
//    [bannerAd.view setEasingFunction:ElasticEaseInOut forKeyPath:@"alpha"];
//    [bannerAd.view setEasingFunction:BounceEaseOut forKeyPath:@"transform"];
    
    _bannerAd.view.alpha = 0.0;
    
    _bannerAd.view.transform = CGAffineTransformRotate(_bannerAd.view.transform, -M_PI/128);
    _bannerAd.view.transform = CGAffineTransformTranslate(_bannerAd.view.transform, -10, _bannerAd.height);
    _bannerAd.view.transform = CGAffineTransformScale(_bannerAd.view.transform, 0.9, 0.9);
    
    [UIView animateWithDuration:1.0 delay:0.25 options:UIViewAnimationOptionLayoutSubviews animations:^(){
        
        _bannerAd.view.alpha = 1.0;
        _bannerAd.view.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        bannerAdAnimating = NO;
        [self viewWillLayoutSubviews];
    }];
    
    [self viewWillLayoutSubviews];
    
    return;
    
    // add perspective to appView  
    CATransform3D perspective = CATransform3DIdentity;
    if (self.loader.appDeck.iosVersion >= 4.2)
    {
        perspective.m34 = -1.0/400;
        self.view.layer.transform = perspective;
        _bannerAd.view.layer.transform = perspective;
    }
    
/*    CGPoint anchorPoint = bannerAd.view.layer.anchorPoint;
    anchorPoint.x = 1.0;
    bannerAd.view.layer.anchorPoint = anchorPoint;*/
    
    {
        // create animation group
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = 1.0;
        group.removedOnCompletion = NO;
        group.fillMode = kCAFillModeForwards;
        // add a rotation animation
        CABasicAnimation *appViewRotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        appViewRotateAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(_bannerAd.view.layer.transform, M_PI/2, 0.0 , -1.0 ,0.0)];
        // add a translation animation
        CABasicAnimation *appViewTranslateXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        [appViewTranslateXAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
        // add a translation animation
        CABasicAnimation *appViewTranslateZAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
        [appViewTranslateZAnimation setToValue:[NSNumber numberWithFloat:0.0f]];
        // add a blur effect
        /*        CABasicAnimation* appViewBlurAnimation = [CABasicAnimation animationWithKeyPath:@"filters.blur.inputRadius"];
         appViewBlurAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
         appViewBlurAnimation.toValue = [NSNumber numberWithFloat:50.0f];*/
        // set up animation group
        group.animations = [NSArray arrayWithObjects: appViewRotateAnimation, appViewTranslateXAnimation, appViewTranslateZAnimation, /*appViewBlurAnimation,*/ nil];
        //group.animations = [NSArray arrayWithObjects: appViewRotateAnimation, nil];
        
        // apply it to appView
        if (self.loader.appDeck.iosVersion >= 4.2)
        {
            [_bannerAd.view.layer addAnimation:group forKey:@"appViewAddAnimation"];
        }
        //    CATransform3D transform = CATransform3DRotate(perspective, DegreesToRadians(60), 0, 1, 0);
        //    self.appView.layer.transform = transform;
    }
    return;
    
    

}



#pragma mark - Rectangle Ad View

-(void)configureRectangleAdViewForManagedWebView:(ManagedWebView *)ctl adjustInset:(BOOL)adjustInset
{
    [ctl addChildViewController:_rectangleAd];
    [ctl.scrollView addSubview:_rectangleAd.view];
//    [ctl.view bringSubviewToFront:ctl.webView];
    
    if (adjustInset)
    {
        CGRect frame = CGRectMake(0, 0, _rectangleAd.width, 0/*_rectangleAd.height*/);
        _rectangleAd.view.frame = frame;
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             

                             
                             ctl.scrollView.contentInset = [self getPageContentInset];
                             CGPoint offset = ctl.scrollView.contentOffset;
                             if (-offset.y < ctl.scrollView.contentInset.top)
                             {
                                 offset.y = -ctl.scrollView.contentInset.top;
                                 ctl.scrollView.contentOffset = offset;
                             }
                             [self adjustRectangleAdView];
                         }
                         completion:^(BOOL finished){
                                 [_rectangleAd.view setNeedsDisplay];
                                 [self.view setNeedsDisplay];
                         }];
        
    } else {
            [self adjustRectangleAdView];
    }

}

-(void)adjustRectangleAdView
{
    if (_rectangleAd == nil)
        return;
    
    CGRect frame = CGRectMake(self.view.frame.size.width / 2 - _rectangleAd.width / 2, 0, _rectangleAd.width, _rectangleAd.height);

    UIEdgeInsets defaultInsets = [self getDefaultContentInset];
    UIEdgeInsets pageInsets = [self getPageContentInset];
    
    if (self.view.frame.size.width > self.view.frame.size.height || self.loader.appDeck.keyboardStateListener.isVisible == YES)
    {
//        contentCtl.webView.scrollView.contentInset = defaultInsets;
        _rectangleAd.view.hidden = YES;
        
        [contentCtl.scrollView setContentInset:defaultInsets];
        [contentCtl.scrollView setScrollIndicatorInsets:defaultInsets];
        
        [self.view bringSubviewToFront:contentCtl.view];
    }
    else if ([_rectangleAd.view isDescendantOfView:contentCtl.scrollView])
    {
        _rectangleAd.view.hidden = NO;
        contentCtl.scrollView.contentInset = [self getPageContentInset];
        
        float position = (pageInsets.top - defaultInsets.top) + contentCtl.scrollView.contentOffset.y + defaultInsets.top;
        
        // ios7 topbar adjust if needed
        //frame.origin.y += defaultInsets.top;
        
        // put ad on top of webview
        //frame.origin.x += self.view.frame.size.width / 2 - _rectangleAd.width / 2;
        frame.origin.y += -_rectangleAd.height;
        
        // scroll adjust
        {
            // adjust print
            if (position >= _rectangleAd.height)
            {
                _rectangleAd.view.hidden = YES;
            }
            else if (position >= 0)
            {
                _rectangleAd.view.hidden = NO;
                frame.origin.y += position / 2;
                frame.size.height = _rectangleAd.height - position / 2;
            } else { // print all
                _rectangleAd.view.hidden = NO;
                //frame.origin.y += -rectangleAd.height + y / 2;
                frame.size.height = _rectangleAd.height;
            }
        }
    }
    else
    {
//        [self.view bringSubviewToFront:_rectangleAd.view];
        [self.view bringSubviewToFront:refreshCtl.view];
        [self.view bringSubviewToFront:contentCtl.view];
        _rectangleAd.view.hidden = NO;
        frame.origin.y = defaultInsets.top;
    }
    
    _rectangleAd.view.frame = frame;
}

#pragma mark - Rotate

-(void)updateWebViewOrientation
{
    
    //changed by hanine
   // BOOL isLandscape = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);  --> UIInterfaceOrientation
    
    BOOL isLandscape = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]); //  --> UIDeviceOrientation

    if (isLandscape)
        [contentCtl executeJS:@"app.helper.removeClass(document.documentElement, 'appdeck_portrait'); app.helper.addClass(document.documentElement, 'appdeck_landscape');"];
    else
        [contentCtl executeJS:@"app.helper.removeClass(document.documentElement, 'appdeck_landscape'); app.helper.addClass(document.documentElement, 'appdeck_portrait');"];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

#ifdef DEBUG_OUTPUT
    NSLog(@"PageViewController: %f - %f - %f", self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"PageViewController: %f - %f - %f", self.view.bounds.origin.x, self.view.bounds.size.width, self.view.bounds.size.height);
#endif
    
    errorView.frame = self.view.bounds;

    CGRect frame = self.view.frame;

    if (self.loader.appDeck.keyboardStateListener.isVisible)
    {
        // fix: rectangle ad make keyboard not move at the right place
        if (_rectangleAd != nil && keyboardWasVisible == NO && self.isMain && self.loader.leftMenuOpen == NO && self.loader.rightMenuOpen == NO)
        {
            CGSize keyboardSize = self.loader.appDeck.keyboardStateListener.keyboardSize;
            frame.size.height -= keyboardSize.height;
            
            CGPoint contentOffset = contentCtl.scrollView.contentOffset;
            contentOffset.y += keyboardSize.height;
            [contentCtl.scrollView setContentOffset:contentOffset animated:YES];
        }
        
        keyboardWasVisible = YES;
    } else
        keyboardWasVisible = NO;
/*    BOOL showAd = (self.loader.appDeck.keyboardStateListener.isVisible == NO) // hide if keyboard is visible
                  && (frame.size.width <  frame.size.height); // hide in paysage*/
    
    if (_bannerAd)
    {
        // show banner only in portrait
        if (frame.size.width <  frame.size.height)
        {
            _bannerAd.view.hidden = NO;
            _bannerAd.view.frame = CGRectMake((frame.size.width - _bannerAd.width) / 2, frame.size.height - _bannerAd.height, _bannerAd.width, _bannerAd.height);
            [self.view bringSubviewToFront:_bannerAd.view];
            if (bannerAdAnimating == NO)
                frame.size.height -= _bannerAd.height;
        } else {
            _bannerAd.view.hidden = YES;
        }
        [self.view bringSubviewToFront:_bannerAd.view];
    }

    // rotate ?
  //  BOOL isLandscape = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    BOOL isLandscape = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
    if (isLandscape != wasLandscape)
    {
        UIEdgeInsets defaultInsets = [self getPageContentInset];
        UIEdgeInsets pageInsets = [self getPageContentInset];
        contentCtl.scrollView.contentInset = defaultInsets;
        contentCtl.scrollView.scrollIndicatorInsets = defaultInsets;
        refreshCtl.scrollView.contentInset = pageInsets;
        refreshCtl.scrollView.scrollIndicatorInsets = defaultInsets;

        if (wasLandscape)
        {
            CGPoint contentOffset = contentCtl.scrollView.contentOffset;
            contentOffset.y -= 12;
            contentCtl.scrollView.contentOffset = contentOffset;
        }

        wasLandscape = isLandscape;
        
        [self updateWebViewOrientation];
    }
    float offset=0;
    if(imageBanner)
        offset=imageBanner.height;
        //offset=200;
    frame=CGRectMake(0, offset, frame.size.width, frame.size.height-offset);
    contentCtl.view.frame = frame;
    refreshCtl.view.frame = frame;
    
    [self adjustRefreshFrame];
    
/*    if (player)
        [self.view bringSubviewToFront:player.view];*/
    
    if (_rectangleAd)
    {
        [self adjustRectangleAdView];
        //[self.view bringSubviewToFront:rectangleAd.view];
        // show banner only in portrait
    }
    
    /*if (_interstitialAd)
    {
        //_interstitialAd.view.frame = self.view.bounds;
        _interstitialAd.view.frame = CGRectMake((frame.size.width - _interstitialAd.width) / 2,
                                                (frame.size.height - _interstitialAd.height) / 2,
                                                _interstitialAd.width,
                                                _interstitialAd.height);
        [self.view bringSubviewToFront:_interstitialAd.view];
        if (frame.size.width <  frame.size.height)
            _interstitialAd.view.hidden = NO;
        else
            _interstitialAd.view.hidden = YES;
    }*/

    
}

-(UIView *)webView
{
    return contentCtl.webView;
}

@end
