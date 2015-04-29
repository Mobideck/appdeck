//
//  loaderViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 15/12/12.
//  Copyright (c) 2012 Mathieu De Kermadec. All rights reserved.
//

#import "LoaderViewController.h"
#import "ECSlidingViewController/ECSlidingViewController.h"
#import "MenuViewController.h"
#import "LoaderChildViewController.h"
#import "RemoteAppCache.h"
#import "GoogleAnalytics/GAI.h"
#import "GoogleAnalytics/GAIFields.h"
#import "GoogleAnalytics/GAIDictionaryBuilder.h"
#import "JSonHTTPApi.h"
#import "NSDictionary+query.h"
#import "PageViewController.h"
#import "MobilizeViewController.h"
#import "WebBrowserViewController.h"
//#import <QuartzCore/QuartzCore.h>
#import "AppURLCache.h"
#import "NSString+UIColor.h"
#import "NSString+URLEncoding.h"
#import "UIImage+Resize.h"
//#import "AppDelegate.h"
#import "SwipeViewController.h"
#import "ScreenConfiguration.h"
#import "UIApplication+setStatusBarHidden.h"
#import "EmbedResources.h"
#import "LoaderConfiguration.h"
#import "UIColor+Gradient.h"
#import "IOSVersion.h"
#import "UIImageView+fromURL.h"
#import "UIButton+fromURL.h"
#import "PhotoBrowserViewController.h"
#import "OpenUDID.h"
#import "CRNavigationController/CRNavigationBar.h"
#import "CRNavigationController/CRNavigationController.h"
#import "GoogleAnalytics/GAI.h"
#import "UIAlertView+Blocks.h"
#import "AdManager.h"
#import "LoaderNavigationController.h"
#import "AppDeckUserProfile.h"
#import "JSONKit.h"
#import "NSDictionary+query.h"

@interface LoaderViewController ()

@end

@implementation LoaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.appDeck = [AppDeck sharedInstance];
        self.view.contentMode = UIViewContentModeScaleToFill;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
/*    if (HACK_PUB_FULLSCREEN)
        [self setFullScreen:YES animation:NO];*/

    [NSThread setThreadPriority:1.0];
    
    [self setupBackgroundMonitoring];
    
    // Determine which launch image file
    NSString * launchImageName = @"Default.png";
    CGRect frame = self.view.bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.view.bounds.size.width < self.view.bounds.size.height) {//UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            launchImageName = @"Default-Portrait.png";
        } else {
            launchImageName = @"Default-Landscape.png";
        }
        if (self.appDeck.iosVersion < 7.0)
        {
            frame.origin.y -= [[UIApplication sharedApplication] statusBarFrame].size.height;
            frame.size.height += [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
    } else {
        if (self.appDeck.iosVersion < 7.0)
        {
            frame.origin.y -= [[UIApplication sharedApplication] statusBarFrame].size.height;
            frame.size.height += [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
    }

    backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    //backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    //backgroundImageView.autoresizesSubviews = YES;
    backgroundImageView.image = [UIImage imageNamed:launchImageName];
    
    [self.view addSubview:backgroundImageView];

    overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = 0.5f;
    [self.view addSubview:overlay];
    
    loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingView.frame = CGRectMake(self.view.bounds.size.width / 2 - loadingView.bounds.size.width / 2, self.view.frame.size.height * 0.75, loadingView.frame.size.width, loadingView.frame.size.height);
//    loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    //    loadingView.frame = CGRectMake(0, 0, loadingView.frame.size.width, loadingView.frame.size.height);
    

    
    
    [loadingView startAnimating];
    [self.view addSubview:loadingView];

    {
        statusBarInfo = [[UIView alloc] initWithFrame:CGRectMake(0, -[[UIApplication sharedApplication] statusBarFrame].size.height, self.view.bounds.size.width, [[UIApplication sharedApplication] statusBarFrame].size.height)];
        statusBarInfo.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarInfo];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    
    /*if (backgroundImageView != nil)
        return;*/
       
    if (self.conf == nil)
        [self loadConf];
}

-(void)loadConf
{
    //self.appDeck.cache.alwaysCache = YES;
    NSURLRequest *request = nil;
    
    if (self.appDeck.isTestApp)
        request = [[NSURLRequest alloc] initWithURL:self.jsonUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    else
        request = [[NSURLRequest alloc] initWithURL:self.jsonUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];

    appJson = [JSonHTTPApi apiWithRequest:request callback:^(NSDictionary *result, NSError *error)
     {
         //NSLog(@"AppConf: %@ - %@", result, error);
         
         if (error != nil)
         {
             
             UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"App Conf Error"
                                                               message:[NSString stringWithFormat:@"%@", error]
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
             [message show];
         }
         [self loadAppConf:result];
     }];    
}

/*-(void)loadAppWithURL:(NSString *)base_url andConf:(NSString *)conf_url
{
    app_base_url = base_url;
    app_conf_url = conf_url;
    
    self.baseUrl = [NSURL URLWithString:app_base_url];
    self.url = [NSURL URLWithString:app_conf_url relativeToURL:self.baseUrl];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.appDeck.cache didReceiveMemoryWarning];
}

- (CALayer *)gradientBGLayerForBounds:(CGRect)bounds colors:(NSArray *)colors
{
    CAGradientLayer * gradientBG = [CAGradientLayer layer];
    gradientBG.frame = bounds;
    gradientBG.colors = colors;
    return gradientBG;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(void)clean
{
    if (navController)
    {
        [navController.view removeFromSuperview];
        [navController removeFromParentViewController];
        navController = nil;
    }
    if (popUp)
    {
        [popUp.view removeFromSuperview];
        [popUp removeFromParentViewController];
        popUp = nil;
    }
    
    if (leftController)
    {
        [leftController.view removeFromSuperview];
        [leftController removeFromParentViewController];
        leftController = nil;
    }
    
    if (rightController)
    {
        [rightController.view removeFromSuperview];
        [rightController removeFromParentViewController];
        rightController = nil;
    }
    
    if (centerController)
    {
        [centerController.view removeFromSuperview];
        [centerController removeFromParentViewController];
        centerController = nil;
    }
    
    if (self.slidingViewController)
    {
        [self.slidingViewController.view removeFromSuperview];
        [self.slidingViewController removeFromParentViewController];
        self.slidingViewController = nil;
    }
    
    self.conf = nil;
    
    remoteAppCache = nil;
    
    self.appIsBusy = NO;
    
    if (embed_compilation)
    {
        [embed_compilation cancel];
        embed_compilation = nil;
    }
    if (embed_runtime)
    {
        [embed_runtime cancel];
        embed_runtime = nil;
    }
    
    glLog = nil;
    if (self.log)
    {
        [self.log.view removeFromSuperview];
        [self.log removeFromParentViewController];
        self.log = nil;

    }
    [self.appDeck.cache removeAllRegularExpression];
    
    if (debug_timer)
    {
        [debug_timer invalidate];
        debug_timer = nil;
    }

    [self.adManager clean];
    self.adManager = nil;
    
    [debugJson cancel];
}

- (BOOL)prefersStatusBarHidden
{
    if (self.forceStatusBarHidden)
        return YES;
    
/*    if (self.slidingViewController.underLeftShowing || self.slidingViewController.underRightShowing)
        return YES;*/
    if (self.conf == nil)
        return YES;

    if (popUp != nil)
        return YES;
    
    // if topview is not Loader (ie it's an ad
    /*UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    if (topView != self.view)
        return YES;*/
    if (navController && navController.viewControllers && navController.viewControllers.count > 0)
    {
        SwipeViewController *swipe = (SwipeViewController *)[navController.viewControllers lastObject];
        LoaderChildViewController *child = swipe.current;
        if (child && child.isFullScreen == YES)
        {
            return YES;
        }
    }
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
/*    if (popUp == nil)
    {
        if (self.slidingViewController.underLeftShowing || self.slidingViewController.underRightShowing)
            return UIStatusBarStyleLightContent;
    }*/
    if (self.conf.icon_theme == IconThemeLight)
        return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
    //return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return nil;
}

-(void)loadAppConf:(NSDictionary *)result
{
    [self clean];
    //self.appDeck.cache.alwaysCache = NO;
    @try {
        // store conf
        
        self.conf = [[LoaderConfiguration alloc] init];
        [self.conf loadWithURL:self.jsonUrl result:result loader:self];

        // debug
        if (self.conf.enable_debug)
            self.appDeck.enable_debug = YES;
        if (self.appDeck.enable_debug)
            self.conf.enable_debug = YES;
        
        if (self.conf.enable_clear_cache)
        {
            [self.appDeck.cache cleanall];
        }
        
        if (self.conf.prefetch_url != nil)
        {
            remoteAppCache = [[RemoteAppCache alloc] initWithURL:self.conf.prefetch_url andTTL:self.conf.prefetch_ttl];
        }
        
        // GA
//        if (self.appDeck.isTestApp == YES)
//            [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
//        [GAI sharedInstance].debug = NO;
        [GAI sharedInstance].dispatchInterval = 20;
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        if (self.conf.ga)
            self.tracker = [[GAI sharedInstance] trackerWithTrackingId:self.conf.ga];
        self.globalTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-39746493-1"];
        NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        [self.globalTracker set:[GAIFields customDimensionForIndex:1] value:appId];

        //[self.globalTracker setCustom:1 dimension:appId];
        if (self.conf.app_api_key)
            [self.globalTracker set:[GAIFields customDimensionForIndex:2] value:self.conf.app_api_key];
            //[self.globalTracker setCustom:2 dimension:self.conf.app_api_key];
        else
            [self.globalTracker set:[GAIFields customDimensionForIndex:2] value:@"none"];
//            [self.globalTracker setCustom:2 dimension:@"none"];
        
        /*if ((self.conf.enable_debug || self.syncEmbedResource) && self.conf.embed_url)
        {
            embed_compilation = [[EmbedResources alloc] initWithURL:self.conf.embed_url shouldOverrideEmbedResource:NO downloadInBackground:NO];
            [embed_compilation sync];
        }*/
        if (self.conf.embed_runtime_url)
        {
            embed_runtime = [[EmbedResources alloc] initWithURL:self.conf.embed_runtime_url shouldOverrideEmbedResource:YES downloadInBackground:YES];
            [embed_compilation sync];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return;
    }

    // disabled as it make keyboard not easily readable
    if (self.appDeck.iosVersion >= 5.0 && NO)
    {
        if (self.conf.icon_theme == IconThemeDark)
        {
            NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIColor blackColor],UITextAttributeTextColor,
                                                      [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                      [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
            [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
        } else {
            NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor],UITextAttributeTextColor,
                                                       [UIColor blackColor], UITextAttributeTextShadowColor,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
            [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
        }
    }
    if (self.conf.app_color1)
    {
        //[[UINavigationBar appearance] setTintColor:self.conf.app_color1];
        [[UITabBar appearance] setTintColor:self.conf.app_color1];
        [[UIToolbar appearance] setTintColor:self.conf.app_color1];
    }
    if (self.conf.topbar_color1 && self.conf.topbar_color2)
    {
        if (self.appDeck.iosVersion < 7.0)
        {
            CALayer * bgGradientLayer = [self gradientBGLayerForBounds:CGRectMake(0, 0, 320, 44) colors:@[ (id)[self.conf.topbar_color1 CGColor], (id)[self.conf.topbar_color2 CGColor] ]];
            UIGraphicsBeginImageContext(bgGradientLayer.bounds.size);
            [bgGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage * bgAsImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [[UINavigationBar appearance] setBackgroundImage:bgAsImage forBarMetrics:UIBarMetricsDefault];
        } else {
            CALayer * bgGradientLayer = [self gradientBGLayerForBounds:CGRectMake(0, 0, 320, 64) colors:@[ (id)[self.conf.topbar_color1 CGColor], (id)[self.conf.topbar_color2 CGColor] ]];
            UIGraphicsBeginImageContext(bgGradientLayer.bounds.size);
            [bgGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage * bgAsImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [[UINavigationBar appearance] setBackgroundImage:bgAsImage forBarMetrics:UIBarMetricsDefault];
        }
        //[[UINavigationBar appearance] setBarTintColor:self.conf.topbar_color1];
    }
    if (self.conf.app_background_color1)
    {
        self.view.backgroundColor = [UIColor colorWithGradientHeight:self.view.frame.size.height startColor:self.conf.app_background_color1 endColor:self.conf.app_background_color2];//self.conf.app_background_color;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }
    if (self.conf.control_color)
    {
        [[UIToolbar appearance] setTintColor:self.conf.control_color];
        [[UITabBar appearance] setTintColor:self.conf.control_color];
    }
    if (self.conf.button_color)
    {
        [[UIBarButtonItem appearance] setTintColor:self.conf.button_color];
        [[UISegmentedControl appearance] setTintColor:self.conf.button_color];
    }
    
//    bootstrapUrl = [[NSURL URLWithString:bootstrapUrl relativeToURL:self.url] absoluteString];
    
    // download logo
/*    if (self.conf.logo)
    {
        NSInteger maxLogoHeight = 44 * [[UIScreen mainScreen] scale];
        if (self.conf.logo.size.height > maxLogoHeight) {
            self.conf.logo = [self.conf.logo scaleToSize:CGSizeMake(self.conf.logo.size.width * maxLogoHeight / self.conf.logo.size.height, maxLogoHeight)];
        }
        if ([[UIScreen mainScreen] scale] == 2)
            self.conf.logo = [UIImage imageWithCGImage:self.conf.logo.CGImage scale:2.0 orientation:UIImageOrientationUp];
    }*/
    // done !
    
    if (self.conf.enable_debug)
    {
        [self enableAutoReloadConf:5.0];
        self.log = [[LogViewController alloc] initWithNibName:nil bundle:nil loader:self];
        glLog = self.log;
        [self.view addSubview:self.log.view];
        [self addChildViewController:self.log];
    }

    // enable background fetch
    if (self.appDeck.iosVersion >= 7.0 && self.conf.prefetch_url)
    {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    
    NSLog(@"Loader Ready !");
    
    [self loadUI];
    
    // call postLoadUI after a small delay
    // this allow UI to be fully ready and loaded
    // before start postload stuff
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(postLoadUI:)
                                   userInfo:nil
                                    repeats:NO];
}

-(LoaderNavigationController *)createNavigationController
{
    // create popup navigation controller
    //CRNavigationController *navCtl = [[CRNavigationController alloc] init];//initWithRootViewController:centerController];
    LoaderNavigationController *navCtl = [[LoaderNavigationController alloc] initWithNibName:nil bundle:nil];
    //    popUp = [[UINavigationController alloc] init];
    navCtl.view.frame = self.view.bounds;
    navCtl.navigationBar.barStyle = UIBarStyleBlackOpaque;
    //navCtl.view.backgroundColor = [UIColor whiteColor];
    if (self.appDeck.iosVersion >= 7.0)
    {
        navCtl.navigationBar.translucent = NO;
        //[navCtl.navigationBar setBarTintColor:[self.conf.topbar_color1 colorWithAlphaComponent:0.6]];
        [navCtl.navigationBar setBarTintColor:self.conf.topbar_color1];
        navCtl.navigationBar.tintColor = (self.conf.icon_theme == IconThemeLight ? [UIColor whiteColor] : [UIColor blackColor]);
    }
    
    /*
    CRNavigationBar *navigationBar = (CRNavigationBar *)navCtl.navigationBar;

    navigationBar.tintColor = (self.conf.icon_theme == IconThemeLight ? [UIColor whiteColor] : [UIColor blackColor]);

    if (self.conf.topbar_color1 && self.conf.topbar_color2)
        [navigationBar setBarTintColor1:self.conf.topbar_color1 color2:self.conf.topbar_color2];
    else if (self.conf.app_color1)
        [navigationBar setBarTintColor:self.conf.topbar_color1];
    else
        [navigationBar setBarTintColor:self.conf.topbar_color1];*/

     //[navigationBar displayColorLayer:true];
 
    /*
    
    {
        CALayer * bgGradientLayer = [self gradientBGLayerForBounds:CGRectMake(0, 0, 320, 64) colors:@[ (id)[self.conf.topbar_color1 CGColor], (id)[self.conf.topbar_color2 CGColor] ]];
        UIGraphicsBeginImageContext(bgGradientLayer.bounds.size);
        [bgGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * bgAsImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIColor *bgcolor = [UIColor colorWithPatternImage:bgAsImage];
  
//        navCtl.navigationBar.barTintColor = bgcolor;
  
        [[UINavigationBar appearance] setBarTintColor:bgcolor];
        
//        [[UINavigationBar appearance] setBackgroundImage:bgAsImage forBarMetrics:UIBarMetricsDefault];
    }*/
    
    return navCtl;
}

-(void)loadUI
{
    if (self.appDeck.iosVersion >= 7.0)
        [self setNeedsStatusBarAppearanceUpdate];

    self.width = self.view.bounds.size.width - self.view.bounds.origin.x;
    self.height = self.view.bounds.size.height;// - self.view.frame.origin.y;
    
    /*
    // create navigation controller
    navController = [[UINavigationController alloc] init];//initWithRootViewController:centerController];
    navController.automaticallyAdjustsScrollViewInsets = NO;
    navController.view.frame = self.view.bounds;//CGRectMake(0, 0, self.width, self.height);
    //    navController.view.frame = CGRectMake(0, 0, self.width, self.height);
    //    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    //    navController.navigationBar.backgroundColor = [UIColor redColor];
    //    navController.navigationBar.translucent = YES;
    //    UINavigationBar
    navController.delegate = self;
    [self addChildViewController:navController];
    [self.view addSubview:navController.view];

//    [self loadRootPage:self.conf.bootstrapUrl.absoluteString];
//    return;
    
    LoaderChildViewController* page = [[LoaderChildViewController alloc] initWithNibName:nil bundle:nil URL:nil content:nil header:nil footer:nil loader:self];
    page.view.backgroundColor = [UIColor redColor];
    
    SwipeViewController *container = [[SwipeViewController alloc] initWithNibName:nil bundle:nil];
    container.current = page;
    
    
    NSArray *ctls = [NSArray arrayWithObject:container];
    //        NSArray *ctls = [NSArray arrayWithObject:page];
    [navController setViewControllers:ctls];
    
    return;
    
    */
    
    // add left menu
    if (self.conf.leftMenuUrl != nil)
    {
        leftController = [[MenuViewController alloc] initWithNibName:nil bundle:nil URL:self.conf.leftMenuUrl content:nil header:nil footer:nil loader:self width:self.conf.leftMenuWidth align:MenuAlignLeft];
        leftController.backgroundColor1 = self.conf.leftmenu_background_color1;
        leftController.backgroundColor2 = self.conf.leftmenu_background_color2;
    }
    // add right menu
    if (self.conf.rightMenuUrl != nil)
    {
        rightController = [[MenuViewController alloc] initWithNibName:nil bundle:nil URL:self.conf.rightMenuUrl content:nil header:nil footer:nil loader:self  width:self.conf.rightMenuWidth align:MenuAlignRight];
        rightController.backgroundColor1 = self.conf.rightmenu_background_color1;
        rightController.backgroundColor2 = self.conf.rightmenu_background_color2;
    }
    centerController = [[UIViewController alloc] init];
    centerController.view.frame = self.view.bounds;//CGRectMake(0, 0, self.width, self.height);
    centerController.view.backgroundColor = self.view.backgroundColor;
    
    // create navigation controller
    navController = [self createNavigationController];
    
    /*
    navController = [[CRNavigationController alloc] init];//initWithRootViewController:centerController];
    navController.view.frame = self.view.bounds;//CGRectMake(0, 0, self.width, self.height);
//    navController.view.frame = CGRectMake(0, 0, self.width, self.height);
//    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
//    navController.navigationBar.backgroundColor = [UIColor redColor];
//    navController.navigationBar.translucent = YES;
//    UINavigationBar
    navController.delegate = self;
    
//    CRNavigationController *navigationController = (CRNavigationController *)self.navigationController;
    CRNavigationBar *navigationBar = (CRNavigationBar *)navController.navigationBar;
    
    if (self.conf.icon_theme == IconThemeLight)
        navigationBar.tintColor = [UIColor whiteColor];
    else
        navigationBar.tintColor = [UIColor blackColor];
    
    if (self.conf.topbar_color1 && self.conf.topbar_color2)
    {
        [navigationBar setBarTintColor1:self.conf.topbar_color1 color2:self.conf.topbar_color2];
    }
    else if (self.conf.app_color1)
    {
        [navigationBar setBarTintColor:self.conf.topbar_color1];
    }
    else
    {
        [navigationBar setBarTintColor:self.conf.topbar_color1];
    }
    
    [navigationBar displayColorLayer:true];*/
    
    
/*    navController.edgesForExtendedLayout = UIRectEdgeNone;
    navController.extendedLayoutIncludesOpaqueBars = NO;
    navController.automaticallyAdjustsScrollViewInsets = NO;*/
    
//    [navigationBar setBarTintColor:self.conf.topbar_color1];
    
  
//    navController.extendedLayoutIncludesOpaqueBars = YES;
//    navController.automaticallyAdjustsScrollViewInsets = NO;

//    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
//        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
//    [centerController.view addSubview:navController.view];
    [centerController addChildViewController:navController];
    [navController didMoveToParentViewController:self];
    [centerController.view addSubview:navController.view];
        //navController.view.backgroundColor = self.view.backgroundColor;
    //
    self.slidingViewController = [[ECSlidingViewController alloc] init];
    __weak LoaderViewController *self_ = self;
    self.slidingViewController.topViewCenterMoved = ^(float x){
        [self_ topViewCenterMoved:x];
    };
    [self registerECSlidingViewControllerNotification];
    self.slidingViewController.view.frame = self.view.bounds;//CGRectMake(0, 0, self.width, self.height);
    //    self.slidingViewController.anchorLeftPeekAmount = 40.0;
    //    self.slidingViewController.anchorRightPeekAmount = 40.0;
    self.slidingViewController.anchorRightRevealAmount = (self.conf.leftMenuWidth > 280 ? 280 : self.conf.leftMenuWidth);
    self.slidingViewController.anchorLeftRevealAmount = (self.conf.rightMenuWidth > 280 ? 280 : self.conf.rightMenuWidth);

    self.slidingViewController.shouldAddPanGestureRecognizerToTopViewSnapshot = YES;
    self.slidingViewController.shouldAllowPanningPastAnchor = NO;
    if (self.appDeck.iosVersion >= 6.0)
        self.slidingViewController.shouldAllowUserInteractionsWhenAnchored = NO;
    else
        self.slidingViewController.shouldAllowUserInteractionsWhenAnchored = YES;
    //self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;
    //self.slidingViewController.underRightWidthLayout = ECFixedRevealWidth;

    //self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    //self.slidingViewController.underRightWidthLayout = ECFullWidth;
    self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;
    self.slidingViewController.underRightWidthLayout = ECFixedRevealWidth;


    //    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    
    self.slidingViewController.underLeftViewController = leftController;
    self.slidingViewController.underRightViewController = rightController;
    self.slidingViewController.topViewController = centerController;
   
    UIGestureRecognizer *panGesture = [self.slidingViewController panGesture];
    panGesture.delegate = self;
    [self.slidingViewController.view addGestureRecognizer:panGesture];

    // add shadow to menu
    centerController.view.layer.shadowOpacity = 0.75f;
    centerController.view.layer.shadowRadius = 10.0f;
    centerController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    //centerController.view.layer.shouldRasterize = YES;
    //centerController.view.layer.rasterizationScale = [UIScreen mainScreen].scale;

    [self addChildViewController:self.slidingViewController];
    [self.slidingViewController didMoveToParentViewController:self];
    [self.view addSubview:self.slidingViewController.view];
    
    self.slidingViewController.view.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.slidingViewController.view.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    // create popup navigation controller
    //popUp = [self createNavigationController];
/*    popUp = [[CRNavigationController alloc] init];//initWithRootViewController:centerController];
    navigationBar = (CRNavigationBar *)popUp.navigationBar;
//    popUp = [[UINavigationController alloc] init];
    popUp.view.frame = self.view.bounds;
    popUp.navigationBar.barStyle = UIBarStyleBlackOpaque;
    popUp.delegate = self;
    popUp.view.backgroundColor = [UIColor whiteColor];
    
    popUp.tintColor = (self.conf.icon_theme == IconThemeLight ? [UIColor whiteColor] : [UIColor blackColor]);
    
    if (self.conf.topbar_color1 && self.conf.topbar_color2)
        [popUp setBarTintColor1:self.conf.topbar_color1 color2:self.conf.topbar_color2];
    else if (self.conf.app_color1)
        [popUp setBarTintColor:self.conf.topbar_color1];
    else
        [popUp setBarTintColor:self.conf.topbar_color1];
    
    [navigationBar displayColorLayer:true];*/

    
    // create fake status bar
    if (self.appDeck.iosVersion >= 7.0)
    {
        fakeStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        if (self.conf.icon_theme == IconThemeLight)
            fakeStatusBar.backgroundColor = [UIColor blackColor];
        else
            fakeStatusBar.backgroundColor = [UIColor whiteColor];
        fakeStatusBar.alpha = 0.0;
        [self.view addSubview:fakeStatusBar];
    }
    
    /*
    [loadingView removeFromSuperview];
    loadingView = nil;*/

    [self setLoadingHidden:YES];
    
    // load bootstrap
//    [self loadRootPage:@"http://testapp.appdeck.mobi/kitchensink_select.php"];
//    [self loadRootPage:@"http://testapp.appdeck.mobi/kitchensink_notice.php"];
//    [self loadRootPage:@"http://testapp.appdeck.mobi/kitchensink_scroll.php"];
//    [self loadRootPage:@"http://testapp.appdeck.mobi/kitchensink_slide2.php"];
    
    LoaderChildViewController    *page = [self getChildViewControllerFromURL:self.conf.bootstrapUrl.absoluteString type:@"default"];
    
    [self loadChild:page root:YES popup:LoaderPopUpNo];
    
    // init ad engine
    self.adManager = [[AdManager alloc] initWithLoader:self];
    
    [self.adManager pageViewController:(PageViewController *)page appearWithEvent:AdManagerEventLaunch];
    
    /*
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:[NSNumber numberWithFloat: 5.0f] forKey:@"inputRadius"];
    [self.view.layer setFilters:@[blurFilter]];
    */
}

-(void)setLoadingHidden:(BOOL)hidden
{
    if (hidden)
        [loadingView stopAnimating];
    else
        [loadingView startAnimating];
    loadingView.hidden = hidden;
    overlay.hidden = hidden;
}

-(void)postLoadUI:(id)sender
{
    // push notification
    [self handlePushNotification];
    // test pub
    /*
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgtest.jpg"]];
    [self.view addSubview:bg];
    [self.view bringSubviewToFront:self.slidingViewController.view];
    
    [UIView animateWithDuration:5.0
                     animations:^{
                        CGAffineTransform transform = CGAffineTransformMakeScale(0.9, 0.9);
                        transform = CGAffineTransformTranslate(transform, 0, self.slidingViewController.view.frame.size.height * 0.9 * 0.1);
                        self.slidingViewController.view.transform = transform;
                     }];
     */
    
    if (self.adManager.fakeCtl)
    {
        [self addChildViewController:self.adManager.fakeCtl];
        [self.view addSubview:self.adManager.fakeCtl.view];
        [self.view sendSubviewToBack:self.adManager.fakeCtl.view];
    }
}

#pragma mark - scroll optimization

-(void)setGlobalUserInteractionEnabled:(BOOL)userInteractionEnabled
{
/*    NSLog(@"setGlobalUserInteractionEnabled: %@", (userInteractionEnabled ? @"YES" : @"NO"));

    centerController.view.userInteractionEnabled = userInteractionEnabled;
    leftController.view.userInteractionEnabled = userInteractionEnabled;
    rightController.view.userInteractionEnabled = userInteractionEnabled;*/
}

#pragma mark - ECSlidingViewController Notification

-(void)topViewCenterMoved:(float)xPos
{
    if (self.appDeck.iosVersion >= 7.0)
    {
        CGFloat offsetX = (xPos - self.view.bounds.size.width/2);
        CGFloat alpha = 0;
        if (offsetX > 0)
            alpha =  offsetX / self.slidingViewController.anchorRightRevealAmount;
        else
            alpha = -offsetX / self.slidingViewController.anchorLeftRevealAmount;
        //NSLog(@"topViewCenterMoved: offset: %f - alpha: %f", offsetX, alpha);
        
        fakeStatusBar.alpha = alpha;

    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"gestureRecognizerShouldBegin: %@", gestureRecognizer.view);
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panRecognizer velocityInView:self.view];
        // denied vertical panning
        if (ABS(velocity.x) < ABS(velocity.y))
            return NO;
        //return ABS(velocity.x) > ABS(velocity.y); // Horizontal panning
        //return ABS(velocity.x) < ABS(velocity.y); // Vertical panning
    }
    
/*    if (currentTouchPoint.x > self.view.frame.size.width * 0.25 && currentTouchPoint.x < self.view.frame.size.width * 0.75)
        return NO;*/
    SwipeViewController *ctl =  (SwipeViewController *)[navController.viewControllers lastObject];
    CGPoint currentTouchPoint     = [gestureRecognizer locationInView:self.view];
    //NSLog(@"currentTouchPoint.x: %f", currentTouchPoint.x);

    if (ctl.swipeEnabled == NO)
        return NO;
    
    if (ctl.previous != nil)
        if (currentTouchPoint.x > self.view.frame.size.width * 0.25 && currentTouchPoint.x < self.view.frame.size.width * 0.75)
            return NO;

    if (ctl.next != nil)
        if (currentTouchPoint.x > self.view.frame.size.width * 0.25 && currentTouchPoint.x < self.view.frame.size.width * 0.75)
            return NO;
    
    [self setGlobalUserInteractionEnabled:NO];
    
    return YES;
}
/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
 NSLog(@"shouldReceiveTouch: %@", touch);
 return YES;
 //    return [self gestureRecognizerShouldBegin:gestureRecognizer];
}
 
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"shouldBeRequiredToFailByGestureRecognizer: %@", gestureRecognizer.view);
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer: %@", gestureRecognizer.view);
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"shouldRequireFailureOfGestureRecognizer: %@", gestureRecognizer.view);
    return NO;
}*/

-(void)registerECSlidingViewControllerNotification
{
/*    NSString *const ECSlidingViewUnderRightWillAppear    = @"ECSlidingViewUnderRightWillAppear";
    NSString *const ECSlidingViewUnderLeftWillAppear     = @"ECSlidingViewUnderLeftWillAppear";
    NSString *const ECSlidingViewUnderLeftWillDisappear  = @"ECSlidingViewUnderLeftWillDisappear";
    NSString *const ECSlidingViewUnderRightWillDisappear = @"ECSlidingViewUnderRightWillDisappear";
    NSString *const ECSlidingViewTopDidAnchorLeft        = @"ECSlidingViewTopDidAnchorLeft";
    NSString *const ECSlidingViewTopDidAnchorRight       = @"ECSlidingViewTopDidAnchorRight";
    NSString *const ECSlidingViewTopWillReset            = @"ECSlidingViewTopWillReset";
    NSString *const ECSlidingViewTopDidReset             = @"ECSlidingViewTopDidReset";*/
    
/*    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewUnderRightWillAppear object:self.slidingViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewUnderLeftWillAppear object:self.slidingViewController];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewUnderLeftWillDisappear object:self.slidingViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewUnderRightWillDisappear object:self.slidingViewController];

    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewTopDidAnchorLeft object:self.slidingViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewTopDidAnchorRight object:self.slidingViewController];
/*    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewTopWillReset object:self.slidingViewController];*/
/*    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ECSlidingViewControllerNotification:)
                                                 name: ECSlidingViewTopDidReset object:self.slidingViewController];*/
    
    
    
}

// When the movie is done, release the controller.
-(void)ECSlidingViewControllerNotification:(NSNotification*)aNotification
{
    BOOL shouldHideFakeStatusBar = NO;

//    NSLog(@"ECSlidingViewControllerNotification: %@ left: %d right: %d", aNotification.name);

    if ([aNotification.name isEqualToString:ECSlidingViewTopDidAnchorRight])
    {
        self.leftMenuOpen = YES;
        [leftController isMain:YES];
    }
    else if ([aNotification.name isEqualToString:ECSlidingViewTopDidAnchorLeft])
    {
        self.rightMenuOpen = YES;
        [rightController isMain:YES];
    }
    else if ([aNotification.name isEqualToString:ECSlidingViewUnderLeftWillDisappear])
    {
        self.leftMenuOpen = NO;
        [leftController isMain:NO];
        return;
    }
    else if ([aNotification.name isEqualToString:ECSlidingViewUnderRightWillDisappear])
    {
        self.rightMenuOpen = NO;
        [rightController isMain:NO];
        return;
    }
    
    [self setGlobalUserInteractionEnabled:YES];
    
    if (self.slidingViewController == nil)
        return;

    if (self.appDeck.iosVersion >= 7.0)
    {
        
        /*if ([aNotification.name isEqualToString:ECSlidingViewUnderLeftWillDisappear] ||
            [aNotification.name isEqualToString:ECSlidingViewUnderRightWillDisappear] ||
            [aNotification.name isEqualToString:ECSlidingViewTopDidReset])
            shouldHideFakeStatusBar = YES;*/

        if (self.slidingViewController.underLeftShowing || self.slidingViewController.underRightShowing)
            shouldHideFakeStatusBar = NO;
        else
            shouldHideFakeStatusBar = YES;
        
        //CGFloat alpha = fakeStatusBar.alpha;
        
        if ((shouldHideFakeStatusBar == YES && fakeStatusBar.alpha != 0.0) ||
            (shouldHideFakeStatusBar == NO && fakeStatusBar.alpha != 1.0))
            {
                [fakeStatusBar.layer removeAllAnimations];
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     fakeStatusBar.alpha = (shouldHideFakeStatusBar ? 0.0 : 1.0);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Page API

-(LoaderChildViewController *)getCurrentChild
{
    return ((SwipeViewController *)navController.topViewController).current;
}

-(void)toggleMenu:(id)origin
{
    //[self showStatusBarNotice:@"2:41 PM"];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)closePopUp:(id)origin
{
    //[self showStatusBarNotice:@"2:41 PM"];
    UINavigationController *p = popUp;
    popUp = nil;
    [navController dismissViewControllerAnimated:YES completion:^{ p.viewControllers = nil; }];
}
/*
-(void)closePopUp:(id)origin andShow:(LoaderChildViewController *)newPage
{
    newPage.isPopUp = YES;
    
    void (^popupcompletion)(void) = ^{
        
        popUp = [self createNavigationController];
        popUp.viewControllers = [NSArray arrayWithObject:container];
        
        UIBarButtonItem* closeButton = [self barButtonItemWithImage:self.conf.icon_close.image andAction:@selector(closePopUp:)];
        
        //UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(closePopUp:)];
        popUp.topViewController.navigationItem.leftBarButtonItem = closeButton;
        [navController presentViewController:popUp animated:YES completion:^{
            if (self.appDeck.iosVersion >= 7.0)
                [self setNeedsStatusBarAppearanceUpdate];
        }];
        
        if (self.appDeck.iosVersion >= 7.0)
            [self setNeedsStatusBarAppearanceUpdate];
    };
    
    [self.slidingViewController resetTopView];
    
    if (popUp != nil)
    {
        [navController dismissViewControllerAnimated:YES completion:popupcompletion];
    }
    else
    {
        popupcompletion();
    }
}*/

-(LoaderChildViewController *)getChildViewControllerFromURL:(NSString *)pageUrlString type:(NSString *)type
{
    LoaderChildViewController    *page = nil;
    

    NSURL *pageUrl = [NSURL URLWithString: [[NSURL URLWithString:pageUrlString relativeToURL:self.conf.baseUrl] absoluteString]];

    // set screen configuration
    ScreenConfiguration *screenConfiguration = nil;
    for (ScreenConfiguration *screen in self.conf.screenConfigurations) {
        if ([screen matchThisConfiguration:pageUrl])
        {
            screenConfiguration = screen;
            break;
        }
    }

    if (type == nil)
    {
        type = @"default";
        if (screenConfiguration != nil && screenConfiguration.type != nil)
        {
            type = screenConfiguration.type;
        }
        else if (screenConfiguration == nil && [pageUrl.host isEqualToString:self.conf.baseUrl.host] == NO)
        {
            screenConfiguration = [ScreenConfiguration defaultConfigurationWitehLoader:self];
            screenConfiguration.isPopUp = YES;
            type = @"browser";
        }
    }
    
    if (false)
    {
        page = [[LoaderChildViewController alloc] initWithNibName:nil bundle:nil URL:pageUrl content:nil header:nil footer:nil loader:self];
        page.view.backgroundColor = [UIColor redColor];        
    }
    else if ([pageUrl.scheme isEqualToString:@"mobilize"] || [screenConfiguration.type isEqualToString:@"mobilize"])
    {
        pageUrlString = [pageUrlString stringByReplacingOccurrencesOfString:@"mobilize://" withString:@"http://"];
        pageUrl = [NSURL URLWithString: [[NSURL URLWithString:pageUrlString relativeToURL:self.conf.baseUrl] absoluteString]];
        
        page = [[MobilizeViewController alloc] initWithNibName:nil bundle:nil URL:pageUrl content:nil header:nil footer:nil loader:self];
    }
    else if ([type isEqualToString:@"browser"])
    {
        page = [[WebBrowserViewController alloc] initWithNibName:nil bundle:nil URL:pageUrl content:nil header:nil footer:nil loader:self];
    }
    else
    {
        page = [[PageViewController alloc] initWithNibName:nil bundle:nil URL:pageUrl content:nil header:nil footer:nil loader:self];
    }
    if (screenConfiguration == nil)
        screenConfiguration = [ScreenConfiguration defaultConfigurationWitehLoader:self];
    page.loader = self;
    page.screenConfiguration = screenConfiguration;
    page.title = screenConfiguration.title;
    return page;
}

-(LoaderChildViewController *)loadPage:(NSString *)pageUrlString root:(BOOL)root popup:(LoaderPopUp)popup
{
    LoaderChildViewController    *page = [self getChildViewControllerFromURL:pageUrlString type:nil];
    return [self loadChild:page root:root popup:popup];
}

-(UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image andAction:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    button.contentMode = UIViewContentModeScaleAspectFit;
    //button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //            [button setBackgroundImage:self.conf.icon_menu.image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    
    [button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(LoaderChildViewController *)loadChild:(LoaderChildViewController *)page root:(BOOL)root popup:(LoaderPopUp)popup
{
    // we can't have two controller animating at same time
    if (navController.isAnimating)
    {
        if (glLog)
            [glLog error:@"Try to load two screen at same time"];
        navController.isAnimating = NO;
        return nil;
    }
    
    navController.isAnimating = YES;
    
    //LoaderChildViewController    *old_page = ((SwipeViewController *)navController.topViewController).current;
    
    // check if there is a loading in progress
    
    
    // if there is a popup, cancel current popup first
    if (popUp != nil)
    {
        __block LoaderChildViewController *p = page;
        [navController dismissViewControllerAnimated:YES completion:^{
        
            popUp = nil;
            [self loadChild:p root:root popup:popup];
    }];
        return p;
    }
    
    if (root == NO)
        page.parent = [self getCurrentChild];//((SwipeViewController *)navController.topViewController).current;
    
    // page already loaded ?
    BOOL animated = NO;
    
    /*if (popup != LoaderPopUpNo && (page.screenConfiguration.isPopUp == YES || popup == LoaderPopUpYes))
    {
        self.forceStatusBarHidden = YES;
    }*/
    
    SwipeViewController *container = [[SwipeViewController alloc] initWithNibName:nil bundle:nil];
    container.current = page;
    //page.swipeContainer = container;
    
    if (page.screenConfiguration.title != nil)
        container.title = page.screenConfiguration.title;
/*    else
        container.title = self.conf.title;*/
    
    if (page.screenConfiguration.logo && ![page.screenConfiguration.logo isEqualToString:@""])
    {
        container.navigationItem.titleView = [UIImageView imageViewFromURL:[NSURL URLWithString:page.screenConfiguration.logo relativeToURL:self.conf.baseUrl] height:44];
    }
    else if (self.conf.logo)
    {
        UIImageView *logoImage = [[UIImageView alloc] initWithImage:self.conf.logo.image];//[UIImageView imageViewFromURL:[NSURL URLWithString:self.conf.logoUrl relativeToURL:self.url] height:44];

        //NSLog(@"view: %fx%f - image %fx%f", logoImage.frame.size.width, logoImage.frame.size.height, self.conf.logo.image.size.width, self.conf.logo.image.size.height);
        logoImage.contentMode = UIViewContentModeScaleAspectFit;
        logoImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        container.navigationItem.titleView = logoImage;
        //[container.navigationItem.titleView.superview setNeedsDisplay];
        //[container.navigationItem.titleView.superview layoutSubviews];
    }
    
    if (glLog && NO)
    {
        if ([page.url.host isEqualToString:self.conf.baseUrl.host])
            [glLog info:@"Load: %@: %@", page.screenConfiguration.title, page.url.relativePath];
        else
            [glLog info:@"Load: %@: %@",page.screenConfiguration.title, page.url.relativeString];
    }
    
    if (popup != LoaderPopUpNo && (page.screenConfiguration.isPopUp == YES || popup == LoaderPopUpYes))
    {
/*        if (popUp)
            [self closePopUp:page];*/
        
        page.isPopUp = YES;
        
        void (^popupcompletion)(void) = ^{

            popUp = [self createNavigationController];
            popUp.viewControllers = [NSArray arrayWithObject:container];
            popUp.view.frame = [UIApplication sharedApplication].keyWindow.frame;
            
            UIBarButtonItem* closeButton = [self barButtonItemWithImage:self.conf.icon_close.image andAction:@selector(closePopUp:)];
            
            //UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(closePopUp:)];
            popUp.topViewController.navigationItem.leftBarButtonItem = closeButton;
            
            [navController presentViewController:popUp animated:YES completion:^{
//                self.forceStatusBarHidden = YES;
                navController.isAnimating = NO;
            }];
  
            if (self.appDeck.iosVersion >= 7.0)
                [UIView animateWithDuration:0.33 animations:^{
                    [self setNeedsStatusBarAppearanceUpdate];
                }];
            
            //if (self.appDeck.iosVersion >= 7.0)
            //    [self setNeedsStatusBarAppearanceUpdate];
        };        
        
        [self.slidingViewController resetTopView];
        
        if (popUp != nil)
        {
            [navController dismissViewControllerAnimated:YES completion:popupcompletion];
        }
        else
        {
            popupcompletion();
        }
        self.forceStatusBarHidden = NO;
        return page;
    }
    
    if (root)
    {
        NSArray *ctls = [NSArray arrayWithObject:container];
//        NSArray *ctls = [NSArray arrayWithObject:page];
        [navController setViewControllers:ctls];
        
        if (leftController)
        {
/*
            //            UIButton *button = [UIButton buttonFromURL:[NSURL URLWithString:self.conf.url_icon_menu relativeToURL:self.url] height:44];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            button.contentMode = UIViewContentModeScaleAspectFit;
            //button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
//            [button setBackgroundImage:self.conf.icon_menu.image forState:UIControlStateNormal];
            [button setImage:self.conf.icon_menu.image forState:UIControlStateNormal];
            
            [button setFrame:CGRectMake(0, 0, self.conf.icon_menu.image.size.width, self.conf.icon_menu.image.size.height)];
            [button setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
            
            [button addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
            navController.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];*/
            
            navController.topViewController.navigationItem.leftBarButtonItem = [self barButtonItemWithImage:self.conf.icon_menu.image andAction:@selector(toggleMenu:)];

        }
        [navController setNavigationBarHidden:NO animated:NO];
        
        
        //[page playPopUpAdVideo];
        if ([page isKindOfClass:[PageViewController class]])
            [self.adManager pageViewController:(PageViewController *)page appearWithEvent:AdManagerEventRoot];
     /*
        UINavigationController *newNavController = [[UINavigationController alloc] init];//initWithRootViewController:centerController];
        newNavController.view.frame = self.view.bounds;//CGRectMake(0, 0, self.width, self.height);
        newNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        newNavController.delegate = self;

        NSArray *ctls = [NSArray arrayWithObject:container];
        [newNavController setViewControllers:ctls];
        
        if (leftController)
        {
//            UIButton *button = [UIButton buttonFromURL:[NSURL URLWithString:self.conf.url_icon_menu relativeToURL:self.url] height:44];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [button setBackgroundImage:self.conf.icon_menu.image forState:UIControlStateNormal];
            [button setFrame:CGRectMake(0, 0, self.conf.icon_menu.image.size.width, self.conf.icon_menu.image.size.height)];

            [button addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
            newNavController.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
        [newNavController setNavigationBarHidden:NO animated:NO];

        [centerController.view addSubview:newNavController.view];
        [centerController addChildViewController:newNavController];
        
        [centerController transitionFromViewController:navController toViewController:newNavController duration:1.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
        } completion:^(BOOL finished) {
            [navController.view removeFromSuperview];
            [navController removeFromParentViewController];
            navController = newNavController;
            //[centerController.view addSubview:navController.view];
            //[centerController addChildViewController:navController];
        }];
        */
        animated = NO;
    } else {
        BOOL same = NO;
/*        if ([old_page.url.host isEqualToString:page.url.host])
        {
            if ([old_page.url.path isEqualToString:page.url.path])
                same = YES;
        }*/
        if (same == YES)
        {
            NSMutableArray *viewControllers = [navController.viewControllers mutableCopy];
            [viewControllers removeLastObject];
            [viewControllers addObject:page];
            [navController setViewControllers:viewControllers animated:YES];
        } else {
            [navController pushViewController:container animated:YES];
            //[page playAdVideo];
            if ([page isKindOfClass:[PageViewController class]])
                [self.adManager pageViewController:(PageViewController *)page appearWithEvent:AdManagerEventPush];
        }
    }
   

    if (animated)
    {
        /*
        [UIView transitionFromView:old_page.view
                            toView:page.view
                          duration:0.125
                           options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve
         | UIViewAnimationOptionAllowUserInteraction
                        completion:^(BOOL finished){

                        }];*/
        page.view.alpha = 0;
        [UIView animateWithDuration:0.5
                         animations:^{
                             page.view.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }

    return page;
}

-(LoaderChildViewController *)loadRootPage:(NSString *)pageUrlString
{
    return [self loadPage:pageUrlString root:YES popup:LoaderPopUpDefault];
}

-(LoaderChildViewController *)loadPage:(NSString *)pageUrlString
{
    return [self loadPage:pageUrlString root:NO popup:LoaderPopUpDefault];
}

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    call.loader = self;
    
    if ([call.command isEqualToString:@"popup"])
    {
        [self loadPage:[NSString stringWithFormat:@"%@",call.param] root:NO popup:LoaderPopUpYes];
        return YES;
    }

    if ([call.command isEqualToString:@"pageroot"])
    {
        [self loadPage:[NSString stringWithFormat:@"%@",call.param] root:YES popup:LoaderPopUpNo];
        if (self.leftMenuOpen || self.rightMenuOpen)
            [self.slidingViewController resetTopView];
        return YES;
    }

    if ([call.command isEqualToString:@"pagerootreload"])
    {
        [self loadPage:[NSString stringWithFormat:@"%@",call.param] root:YES popup:LoaderPopUpDefault];
        if (leftController)
            [leftController reload];
        if (rightController)
            [rightController reload];
        if (self.leftMenuOpen || self.rightMenuOpen)
            [self.slidingViewController resetTopView];
        return YES;
    }
    
    
    if ([call.command isEqualToString:@"pagepush"])
    {
        [self loadPage:[NSString stringWithFormat:@"%@",call.param] root:NO popup:LoaderPopUpDefault];
        if (self.leftMenuOpen || self.rightMenuOpen)
            [self.slidingViewController resetTopView];
        return YES;
    }

    if ([call.command isEqualToString:@"pagepop"])
    {
        if (navController.childViewControllers.count > 1)
            [navController popViewControllerAnimated:YES];
        if (self.leftMenuOpen || self.rightMenuOpen)
            [self.slidingViewController resetTopView];
        return YES;
    }

    if ([call.command isEqualToString:@"pagepoproot"])
    {
//        [navController popToRootViewControllerAnimated:YES];
        NSArray *viewControllers = [NSArray arrayWithObject:navController.viewControllers.firstObject];
        [navController setViewControllers:viewControllers animated:YES];
        if (self.leftMenuOpen || self.rightMenuOpen)
            [self.slidingViewController resetTopView];
        return YES;
    }

    if ([call.command isEqualToString:@"reload"])
    {
        for (SwipeViewController *swipe in navController.viewControllers)
        {
            [swipe reload];
        }
        if (leftController)
            [leftController reload];
        if (rightController)
            [rightController reload];
        return YES;
    }
    
    if ([call.command isEqualToString:@"slidemenu"])
    {
        NSString *command = [NSString stringWithFormat:@"%@", [call.param objectForKey:@"command"]];
        NSString *position = [NSString stringWithFormat:@"%@", [call.param objectForKey:@"position"]];
        
        if ([command isEqualToString:@"open"])
        {
            /*if ([position isEqualToString:@"left"] && self.rightMenuOpen)
                [self.slidingViewController anchorTopViewTo:ECRight];
            else*/ if ([position isEqualToString:@"left"])
                [self.slidingViewController anchorTopViewTo:ECRight];
            else if ([position isEqualToString:@"right"] && self.leftMenuOpen)
            {
/*                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1.0];
//                [UIView setAnimationTransition:<#(UIViewAnimationTransition)#> forView:<#(UIView *)#> cache:<#(BOOL)#>
                [UIView setAnimationTransition:UIViewAnimationCurveLinear forView:self.slidingViewController.view cache:YES];
                [UIView commitAnimations];*/
                
                __block LoaderViewController *me = self;
                [UIView transitionWithView:self.view duration:0.25
                                   options:UIViewAnimationOptionCurveLinear
                                animations:^{
                                    [me.slidingViewController resetTopViewWithAnimations:^{
                                        
                                    } onComplete:^{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [me.slidingViewController anchorTopViewTo:ECLeft];
                                        });
                                    }];
                                }
                                completion:NULL];
                

            }
            else if ([position isEqualToString:@"right"])
                [self.slidingViewController anchorTopViewTo:ECLeft];
            else if ([position isEqualToString:@"main"])
                [self.slidingViewController resetTopView];
        } else if ([command isEqualToString:@"close"]) {
            [self.slidingViewController resetTopView];
        }
        
        //[self loadPage:[NSString stringWithFormat:@"%@",call.param] root:NO forcePopup:YES];
        return YES;
    }
    
    if ([call.command isEqualToString:@"shownotice"])
    {
        [self showStatusBarNotice:[NSString stringWithFormat:@"%@",call.param]];
        return YES;
    }
    if ([call.command isEqualToString:@"showerror"])
    {
        [self showStatusBarError:[NSString stringWithFormat:@"%@",call.param]];
        return YES;
    }

    //photobrowser ?
    if ([call.command isEqualToString:@"photobrowser"])
    {
        NSError *error;
        
        PhotoBrowserViewController *browser = [PhotoBrowserViewController photoBrowserWithConfig:call.param baseURL:self.conf.baseUrl error:&error];
        browser.url = [NSURL URLWithString:[call.child.url.absoluteString stringByAppendingString:@"#PhotoBrowser"]];
        if (browser == nil)
        {
            NSLog(@"browser Error: %@", error);
            return YES;
        }
        
        browser.loader = self;
        browser.screenConfiguration = [ScreenConfiguration defaultConfigurationWitehLoader:self];
        browser.title = browser.screenConfiguration.title;

        [self loadChild:browser root:NO popup:LoaderPopUpDefault];
        
        //        [self presentModalViewController:browser animated:YES];
//        [self.navigationController pushViewController:browser animated:YES];
        /*
         [self.view addSubview:browser.view];
         [self addChildViewController:browser];
         */
        
        return YES;
        
    }
    
    return [self.appDeck apiCall:call];
}

#pragma mark - UIWebView Delegate (for menu)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
//    [self loadRootPage:[[request URL] absoluteString]];
//    [deckController toggleLeftViewAnimated:YES];
//    return NO;
}

#pragma mark - StatusBarInfo

-(void)showStatusBarError:(NSString *)message
{
    [self showStatusBarMessage:message color:[UIColor redColor]];
}

-(void)showStatusBarNotice:(NSString *)message
{
    [self showStatusBarMessage:message color:[UIColor lightGrayColor]];
}

-(void)showStatusBarMessage:(NSString *)message color:(UIColor *)color
{
    if (self.appDeck.iosVersion >= 7.0)
        return;
    
    for (UIView* subView in [statusBarInfo subviews])
    {
        [subView.layer removeAllAnimations];
        [subView removeFromSuperview];
    }
    [[UIApplication sharedApplication] altSetStatusBarHidden:YES withAnimation:YES];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -statusBarInfo.frame.size.height, statusBarInfo.frame.size.width, statusBarInfo.frame.size.height)];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.numberOfLines = 1;
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = color;
    label.shadowColor = color;
    label.shadowOffset = CGSizeMake(0.0, 0.0);

    label.backgroundColor = [UIColor clearColor];
    [statusBarInfo addSubview:label];
    
    label.alpha = 0;
//    label.transform = CGAffineTransformMakeTranslation(0.0, -statusBarInfo.frame.size.height);
    [UIView animateWithDuration:0.5
                     animations:^{
                         label.alpha = 1;
                         label.transform = CGAffineTransformMakeTranslation(0.0, statusBarInfo.frame.size.height - 1);
                     }
                     completion:^(BOOL finished){

                         [UIView animateWithDuration:1.0
                                          animations:^{
                                              label.alpha = 0.99;
                                          }
                                          completion:^(BOOL finished){

                                              if ([label isDescendantOfView:statusBarInfo])
                                                  [self setFullScreen:NO animation:UIStatusBarAnimationFade];
//                                                  [[UIApplication sharedApplication] altSetStatusBarHidden:NO withAnimation:YES];
                                              
                                          }];
                         
                     }];
    
    
    
}

#pragma mark - FullScreen

-(void)setFullScreen:(BOOL)fullScreen animation:(UIStatusBarAnimation)animation
{
//    id<UIApplicationDelegate> app = [[UIApplication sharedApplication] delegate];
    if (fullScreen)
    {
        [[UIApplication sharedApplication] altSetStatusBarHidden:YES withAnimation:animation];
        //self.view.bounds = app.window.bounds;
        //self.view.frame = app.window.bounds;
                
        [UIView animateWithDuration:0.125 animations:^(){
            [self viewWillLayoutSubviews];
        }];
        if (self.appDeck.iosVersion < 7.0)
            statusBarInfo.hidden = YES;
    }
    else
    {
        [[UIApplication sharedApplication] altSetStatusBarHidden:NO withAnimation:animation];
        
        //self.view.frame = CGRectMake(0, statusBarInfo.frame.size.height, app.window.bounds.size.width, app.window.bounds.size.height - statusBarInfo.frame.size.height);
        [UIView animateWithDuration:0.125 animations:^(){
            [self viewWillLayoutSubviews];
        }];
        if (self.appDeck.iosVersion < 7.0)
            statusBarInfo.hidden = NO;

    }
    
    
    if (self.appDeck.iosVersion >= 7.0)
        return;
        
    // Get statusBar's frame
    CGRect statusBarFrame = [UIApplication.sharedApplication statusBarFrame];
    // Establish a baseline frame.
    CGRect newViewFrame = self.view.window.bounds;
    
    // Check if statusBar's frame is worth dodging.
    if (!CGRectEqualToRect(statusBarFrame, CGRectZero)){
        UIInterfaceOrientation currentOrientation = self.interfaceOrientation;
        if (UIInterfaceOrientationIsPortrait(currentOrientation)){
            // If portrait we need to shrink height
            newViewFrame.size.height -= statusBarFrame.size.height;
            if (currentOrientation == UIInterfaceOrientationPortrait){
                // If not upside-down move down the origin.
                newViewFrame.origin.y += statusBarFrame.size.height;
            }
        } else { // Is landscape / Slightly trickier.
            // For portrait we shink width (for status bar on side of window)
            newViewFrame.size.width -= statusBarFrame.size.width;
            if (currentOrientation == UIInterfaceOrientationLandscapeLeft){
                // If the status bar is on the left side of the window we move the origin over.
                newViewFrame.origin.x += statusBarFrame.size.width;
            }
        }
    }
    self.view.frame = newViewFrame;
    
}

#pragma mark - AppIsBusy

-(BOOL)appIsBusy
{
    return appIsBusy;
}

-(void)setAppIsBusy:(BOOL)_appIsBusy
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = _appIsBusy;
    appIsBusy = _appIsBusy;
}

#pragma mark - rotate

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
#ifdef DEBUG_OUTPUT
    NSLog(@"LoaderViewController: %f - %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"LoaderViewController: %f - %f", self.view.bounds.size.width, self.view.bounds.size.height);
#endif
    
    //    NSLog(@"ViewF: %f - %f", self.view.frame.size.width, self.view.frame.size.height);
    //NSLog(@"ViewB: %f - %f", self.view.bounds.size.width, self.view.bounds.size.height);
    // backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/* * backgroundImageView.image.size.width / self.view.frame.size.width*/);
    
    if (fakeStatusBar)
        fakeStatusBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    
    if (self.log)
    {
        // make sure log is in front
        [self.view bringSubviewToFront:self.log.view];
//        CGFloat logHeight = (self.log.isOpen ? self.view.bounds.size.height / 2 : 44);
        //self.log.view.frame = CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, self.view.bounds.size.height / 2);
    }
    
    if (overlay)
    {
        overlay.frame = self.view.bounds;
        [self.view bringSubviewToFront:overlay];
    }
    
    if (loadingView)
    {
        loadingView.frame = CGRectMake(self.view.bounds.size.width / 2 - loadingView.bounds.size.width / 2, self.view.bounds.size.height * 0.75, loadingView.frame.size.width, loadingView.frame.size.height);
        [self.view bringSubviewToFront:loadingView];
    }
    
    
    //self.slidingViewController.view.frame = self.view.bounds;
    //centerController.view.frame = self.view.bounds;
    //navController.view.frame = self.view.bounds;
    self.slidingViewController.view.frame = self.view.bounds;
    popUp.view.frame = self.view.bounds;
    navController.view.frame = self.view.bounds;
    centerController.view.frame = self.view.bounds;//CGRectMake(0, 0, self.width, self.height);

    if (self.adManager.fakeCtl)
    {
        self.adManager.fakeCtl.view.frame = self.view.bounds;
    }
    
    // adjust shadow
    [centerController.view.layer setShadowPath:[[UIBezierPath
                                                 bezierPathWithRect:centerController.view.bounds] CGPath]];    
    return;
    self.slidingViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"View: %f - %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"Image: %f - %f", backgroundImageView.image.size.width, backgroundImageView.image.size.height);
    if (backgroundImageView)
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/* * backgroundImageView.image.size.width / self.view.frame.size.width*/);
    NSLog(@"ImageView: %f - %f", backgroundImageView.frame.size.width, backgroundImageView.frame.size.height);
/*    contentCtl.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    refreshCtl.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    pullTorefreshArrow.frame = CGRectMake(self.view.frame.size.width / 2 - pullTorefreshArrow.frame.size.width / 2,
                                          - 1.25 * pullTorefreshArrow.frame.size.height,
                                          pullTorefreshArrow.frame.size.width, pullTorefreshArrow.frame.size.height);
    //    pullTorefreshArrow.frame = CGRectMake(pullTorefreshArrow.frame.origin.x / 4, pullTorefreshArrow.frame.origin.y / 4,
    //                                          pullTorefreshArrow.frame.size.width / 4, pullTorefreshArrow.frame.size.height / 4);
    
    pullTorefreshLoading.frame = pullTorefreshArrow.frame;*/
}

/*
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Loader: Frame: origin: %fx%f - size: %fx%f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);

//    for (UIViewController *viewController in navController.viewControllers)
//    {
//         [viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    }
}*/

#pragma mark - push notification

-(void)handlePushNotification
{
#if !TARGET_IPHONE_SIMULATOR
    // register push registration
    if (self.conf.push_register_url || self.conf.enable_debug)
    {
        if (self.appDeck.iosVersion >= 8.0)
        {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge
                                                                                                  |UIRemoteNotificationTypeSound
                                                                                                  |UIRemoteNotificationTypeAlert) categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
/*            // iOS 8 Notifications
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];*/
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeNewsstandContentAvailability|
                                                                                   UIRemoteNotificationTypeBadge |
                                                                                   UIRemoteNotificationTypeSound |
                                                                                   UIRemoteNotificationTypeAlert)];
        }
    }
#endif
    // push notification received ?
    NSDictionary *localNotif = [self.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (localNotif)
    {
        NSLog(@"local notif: %@", localNotif);
        [self application:[UIApplication sharedApplication] didReceiveRemoteNotification:localNotif];
    }
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    pushNotificationRegistered = YES;
    
#if !TARGET_IPHONE_SIMULATOR
    
    __block NSURL *url = self.conf.push_register_url;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {

        NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", devToken);

        // Get Bundle Info for Remote Registration (handy if you have more than one app)
        NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
        NSUInteger rntypes;
        if (self.appDeck.iosVersion >= 8.0)
            rntypes = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        else
            rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        
        // Set the defaults to disabled unless we find otherwise...
        NSString *pushBadge = @"disabled";
        NSString *pushAlert = @"disabled";
        NSString *pushSound = @"disabled";
        
        // Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
        // one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
        // single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
        // true if those two notifications are on.  This is why the code is written this way ;)
        if (rntypes == UIRemoteNotificationTypeBadge)
        {
            pushBadge = @"enabled";
        } else if(rntypes == UIRemoteNotificationTypeAlert) {
            pushAlert = @"enabled";
        } else if(rntypes == UIRemoteNotificationTypeSound) {
            pushSound = @"enabled";
        } else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)) {
            pushBadge = @"enabled";
            pushAlert = @"enabled";
        } else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)) {
            pushBadge = @"enabled";
            pushSound = @"enabled";
        } else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)) {
            pushAlert = @"enabled";
            pushSound = @"enabled";
        } else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)) {
            pushBadge = @"enabled";
            pushAlert = @"enabled";
            pushSound = @"enabled";
        }
        
        // Get the users Device Model, Display Name, Unique ID, Token & Version Number
        UIDevice *dev = [UIDevice currentDevice];
        NSString *deviceUuid;
        if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            // This is will run if it is iOS6
            deviceUuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        } else {
            deviceUuid = [OpenUDID value];
        }
        
        NSString *deviceName = dev.name;
        NSString *deviceModel = dev.model;
        NSString *deviceSystemVersion = dev.systemVersion;
        
#ifdef DEBUG
        NSString *app_mode = @"dev";
#else
        NSString *app_mode = @"prod";
#endif
        
        NSString *type = @"iphone";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            type = @"ipad";
        
        // Prepare the Device Token for Registration (remove spaces and < >)
        NSString *deviceToken = [[[[devToken description]
                                   stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                  stringByReplacingOccurrencesOfString:@">" withString:@""]
                                 stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        __block NSString *body = [NSString stringWithFormat:@"apikey=%@&type=%@&mode=%@&version=%ld&task=%@&appid=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@",
                          self.conf.app_api_key, type, app_mode, self.conf.app_version, @"register", appId, appName, appVersion, deviceUuid, deviceToken, [deviceName urlEncodeUsingEncoding:NSASCIIStringEncoding] , deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
        
        NSDictionary *profileData = [self.appDeck.userProfile getComputedData];
        [profileData enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *obj, BOOL *stop) {
            body = [body stringByAppendingFormat:@"&%@=%@", [key urlEncodeUsingEncoding:NSASCIIStringEncoding], [obj urlEncodeUsingEncoding:NSASCIIStringEncoding]];
        }];
        // Register the Device Data


        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
        
        NSError *error;
        NSURLResponse *response;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSString *content = [[NSString alloc]  initWithBytes:[returnData bytes] length:[returnData length] encoding: NSUTF8StringEncoding];
        
        NSLog(@"Register URL: %@", url);
        NSLog(@"Register BODY: %@", body);
        NSLog(@"Return Response: %@", response);
        NSLog(@"Return Error: %@", error);
        NSLog(@"Return Data: %@", content);
    });

#endif
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
    if ([err code] != 3010) // 3010 is for the iPhone Simulator
	{
        // show some alert or otherwise handle the failure to register.
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    NSString *notification_title = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"title"]];
    NSString *notification_title = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    NSString *notification_url = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"url"]];
    NSString *notification_reload_app = [userInfo objectForKey:@"reload_app"];
//    NSString *notification_content = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"content"]];
    NSLog(@"Notification: title: %@ url:%@ reload: %@", notification_title, notification_url, notification_reload_app);
    if ([userInfo objectForKey:@"url"] != nil)
    {
        [[[UIAlertView alloc] initWithTitle:notification_title
                                    message:nil
                           cancelButtonItem:[RIButtonItem itemWithLabel:@"Ok" action:^{
            [self loadPage:notification_url root:NO popup:LoaderPopUpDefault];
        }]
                           otherButtonItems:[RIButtonItem itemWithLabel:@"Cancel" action:^{
            
        }], nil] show];
    }
    
    if (notification_reload_app != nil)
    {
        [[AppDeck sharedInstance].cache cleanall];
        [AppDeck reloadFrom:self.jsonUrl.absoluteString];
    }
}

#pragma mark - Background Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSURL *prefetch_url = self.conf.prefetch_url;
    LoaderConfiguration *tmpConf = nil;
    if (prefetch_url == nil)
    {
        NSLog(@"jsonURL: %@", self.jsonUrl);
        NSLog(@"Cache: %@", self.appDeck.cache);
//        NSData *data = self.app.cache cachedRe
        NSURLRequest *request = [NSURLRequest requestWithURL:self.jsonUrl cachePolicy:NSURLRequestReturnCacheDataDontLoad timeoutInterval:60];
        NSCachedURLResponse *cacheResponse = [self.appDeck.cache getCacheResponseForRequest:request];
        if (cacheResponse == nil)
        {
            completionHandler(UIBackgroundFetchResultNoData);
            return;
        }
        NSError *error = nil;
        NSMutableDictionary *result = [cacheResponse.data objectFromJSONDataWithParseOptions:JKParseOptionComments|JKParseOptionUnicodeNewlines|JKParseOptionLooseUnicode|JKParseOptionPermitTextAfterValidJSON error:&error];
        if (error != nil || result == nil)
        {
            completionHandler(UIBackgroundFetchResultNoData);
            return;
        }
        tmpConf = [[LoaderConfiguration alloc] init];
        [tmpConf loadWithURL:self.jsonUrl result:result loader:self];
        prefetch_url = tmpConf.prefetch_url;
        if (prefetch_url == nil)
        {
            completionHandler(UIBackgroundFetchResultNoData);
            return;
        }
    }
    
    int nbCreate = 0;
    int nbUpdate = 0;
    [RemoteAppCache sync:prefetch_url nbCreate:&nbCreate nbUpdate:&nbUpdate];
    
    
    if (nbCreate > 0)
        completionHandler(UIBackgroundFetchResultNewData);
    else
        completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - auto reload conf

-(void)enableAutoReloadConf:(CGFloat)interval
{
    if (self.appDeck.isTestApp == NO)
    {
        NSLog(@"Auto reload conf not supported because this is not AppDeck Test App");
    }
    else if (![self.conf.jsonUrl.absoluteString isEqualToString:[NSString stringWithFormat:@"http://config.appdeck.mobi/json/%@", self.conf.app_api_key]])
    {
        NSLog(@"Auto reload conf not supported because this app don't use AppDeck Cloud Services");
    }
    else if ([self.conf.app_api_key isEqualToString:@"218hf32d1901627d35131fa83b63f56ae906"])
    {
        NSLog(@"Auto reload conf enabled as this is AppDeck TestApp");
    }
    else
        debug_timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(runAutoReloadConf:) userInfo:nil repeats:NO];
}

-(void)runAutoReloadConf:(id)timer
{
    //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        //self.appDeck.cache.alwaysCache = YES;
        NSString *poll_url = [NSString stringWithFormat:@"http://config.appdeck.mobi/poll/%@?version=%ld", self.conf.app_api_key, (long)self.conf.app_version];
        debugJson = [JSonHTTPApi apiWithURL:poll_url params:nil callback:^(NSDictionary *result, NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"error while fetch poll json: %@", error);
                 [self enableAutoReloadConf:1.0];
                 return;
             }
             if ([result objectForKey:@"error"] != nil)
             {
                 NSLog(@"error while poll json: %@", [result objectForKey:@"value"]);
                 [self enableAutoReloadConf:1.0];
                 return;
             }
             NSString *version = [result objectForKey:@"version"];
             if (version == nil)
             {
                 NSLog(@"error while check poll json: version not found");
                 [self enableAutoReloadConf:1.0];
                 return;
             }
             NSLog(@"New App Conf: %@ <=> %ld ?", version, self.conf.app_version);
             if (version.intValue != self.conf.app_version)
             {
                 [self.appDeck.cache cleanall];
                 [AppDeck reloadFrom:self.conf.jsonUrl.absoluteString];
             }
             else
                 [self enableAutoReloadConf:5.0];
         }];
        
/*        NSURL *url = self.jsonUrl;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        NSError *error;
        NSURLResponse *response;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSString *content = [[NSString alloc]  initWithBytes:[returnData bytes] length:[returnData length] encoding: NSUTF8StringEncoding];
        
        NSLog(@"Register URL: %@", url);
        NSLog(@"Return Response: %@", response);
        NSLog(@"Return Error: %@", error);
        NSLog(@"Return Data: %@", content);
        
        LoaderConfiguration *newConf = [LoaderConfiguration alloc] init*/
   // });
}

#pragma mark - Shake Event

-(BOOL) canBecomeFirstResponder
{
    /* Here, We want our view (not viewcontroller) as first responder
     to receive shake event message  */
    
    return YES;
}

-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake && self.appDeck.isTestApp == YES)
    {
        [AppDeck restart];
    }
}

#pragma mark - Foreground/background handling

-(void)setupBackgroundMonitoring
{
    // UIApplicationDidEnterBackgroundNotification
    // UIApplicationWillEnterForegroundNotification
    // UIApplicationDidBecomeActiveNotification
    // UIApplicationWillResignActiveNotification
    // UIApplicationSignificantTimeChangeNotification
    // UIApplicationBackgroundRefreshStatusDidChangeNotification
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationSignificantTimeChangeNotification:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBackgroundRefreshStatusDidChangeNotification:)
                                                 name:UIApplicationBackgroundRefreshStatusDidChangeNotification
                                               object:nil];
    
    
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    self.appRunInBackground = YES;
    [self setLoadingHidden:NO];
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    self.appRunInBackground = NO;
    [self setLoadingHidden:YES];
}

- (void)applicationDidBecomeActiveNotification:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActiveNotification");
    self.appRunInBackground = NO;
}

- (void)applicationWillResignActiveNotification:(UIApplication *)application
{
    NSLog(@"applicationWillResignActiveNotification");
    self.appRunInBackground = YES;
}

- (void)applicationSignificantTimeChangeNotification:(UIApplication *)application
{
    NSLog(@"applicationSignificantTimeChangeNotification");
    // ask views to refresh itself if needed
}

- (void)applicationBackgroundRefreshStatusDidChangeNotification:(UIApplication *)application
{
    NSLog(@"applicationBackgroundRefreshStatusDidChangeNotification");
}



@end
