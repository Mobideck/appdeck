//
//  AppDeck.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 12/04/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeck.h"
#import "AppURLCache.h"
#import "CustomWebViewFactory.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
#import "LoaderChildViewController.h"
#import "JRSwizzle.h"
#import "RNCachingURLProtocol.h"
#import "ManagedUIWebViewURLProtocol.h"
#import "CookieStorage.h"
#import "WebViewHistory.h"
#import "CacheMonitoringURLProtocol.h"
#import "CustomWebViewFactory.h"
#import "LoaderURLProtocol.h"
#import "LogViewController.h"
#import "WebViewHistory.h"
//#import "TestFlight.h"
#import "MMPickerView/CustomMMPickerView.h"
#import "CustomDatePicker.h"
#import <KAProgressLabel/KAProgressLabel.h>
#import "MySlider.h"
#import "SelectActionSheet.h"  //unused

#import "SwipeViewController.h"
#import "UIScrollView+ScrollsToTop.h"
#import "irate/iRate-1.11.3/iRate/iRate.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "AppDeckPluginManager.h"

#import "CacheURLProtocol.h"

#import "KeyboardStateListener.h"

#import <AudioToolbox/AudioServices.h>

#import <MaterialComponents/MaterialSnackbar.h>
#import "VCFloatingActionButton.h"


@import MessageUI;
@import SafariServices;

@implementation AppDeck

+(AppDeck *)sharedInstance
{
    static AppDeck *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[AppDeck alloc] init];
    });

    return sharedInstance;
}

-(id)init
{
    self.isTestApp = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] isEqualToString:@"net.mobideck.appdeck.test"];

//#warning remove this
//    self.isTestApp = NO;

    shouldConfigureApp = YES;
    
    //configure iRate
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    
    self.iosVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    self.keyboardStateListener = [[KeyboardStateListener alloc] init];
    
    NSError *error = nil;

#ifdef DEBUG
    //NSLog(@"This is only printed when debugging!");
#endif
    
    //[TestFlight takeOff:@"60d6e4be-a67b-471d-9d1f-10a378b3f3dc"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
	[UIWebView jr_swizzleMethod:NSSelectorFromString(@"webView:identifierForInitialRequest:fromDataSource:)") withMethod:NSSelectorFromString(@"@selector(altwebView:identifierForInitialRequest:fromDataSource:)") error:&error];
	[UIWebView jr_swizzleMethod:NSSelectorFromString(@"webView:resource:didFinishLoadingFromDataSource:") withMethod:NSSelectorFromString(@"altwebView:resource:didFinishLoadingFromDataSource:") error:&error];
  	[UIWebView jr_swizzleMethod:NSSelectorFromString(@"webView:resource:didFailLoadingWithError:fromDataSource:") withMethod:NSSelectorFromString(@"altwebView:resource:didFailLoadingWithError:fromDataSource:") error:&error];
    
   	[UIWebView jr_swizzleMethod:NSSelectorFromString(@"webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:") withMethod:NSSelectorFromString(@"altwebView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:") error:&error];
    
    
   	[UIWebView jr_swizzleMethod:NSSelectorFromString(@"webView:decidePolicyForNavigationAction:request:frame:decisionListener:") withMethod:NSSelectorFromString(@"altwebView:decidePolicyForNavigationAction:request:frame:decisionListener:") error:&error];
    
    
    /*
    
	[UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:animated:) withMethod:@selector(altSetStatusBarHidden:animated:) error:&error];
  	[UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:) withMethod:@selector(altSetStatusBarHidden:) error:&error];
	[UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:withAnimation:) withMethod:@selector(altSetStatusBarHidden:withAnimation:) error:&error];
*/
  	[UIScrollView jr_swizzleMethod:NSSelectorFromString(@"initWithFrame:") withMethod:NSSelectorFromString(@"altInitWithFrame:") error:&error];
    

/*
 [UIWebView jr_swizzleMethod:@selector(webView:identifierForInitialRequest:fromDataSource:) withMethod:@selector(altwebView:identifierForInitialRequest:fromDataSource:) error:&error];
 [UIWebView jr_swizzleMethod:@selector(webView:resource:didFinishLoadingFromDataSource:) withMethod:@selector(altwebView:resource:didFinishLoadingFromDataSource:) error:&error];
 [UIWebView jr_swizzleMethod:@selector(webView:resource:didFailLoadingWithError:fromDataSource:) withMethod:@selector(altwebView:resource:didFailLoadingWithError:fromDataSource:) error:&error];
 
 [UIWebView jr_swizzleMethod:NSSelectorFromString(@"webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:") withMethod:NSSelectorFromString(@"altwebView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:") error:&error];
 
 [UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:animated:) withMethod:@selector(altSetStatusBarHidden:animated:) error:&error];
 [UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:) withMethod:@selector(altSetStatusBarHidden:) error:&error];
 [UIApplication jr_swizzleMethod:@selector(setStatusBarHidden:withAnimation:) withMethod:@selector(altSetStatusBarHidden:withAnimation:) error:&error];
 */
 
#pragma clang diagnostic pop
    
    
    // init UIWebView engine ASAP: this way we can also start webhistory
//[UIWebView new];
    firstWebView = [[UIWebView alloc] init];
    // set User-Agent for tablet
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.userAgent = [[firstWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] stringByAppendingString:@" AppDeck-ios AppDeck-tablet"];
    else
        self.userAgent = [[firstWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] stringByAppendingString:@" AppDeck-ios AppDeck-phone"];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.userAgentWebView = [[firstWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] stringByAppendingString:@" WebView AppDeck-ios AppDeck-tablet"];
    else
        self.userAgentWebView = [[firstWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] stringByAppendingString:@" WebView AppDeck-ios AppDeck-phone"];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.userAgentChunk = @" WebView AppDeck-ios AppDeck-tablet";
    else
        self.userAgentChunk = @" WebView AppDeck-ios AppDeck-phone";
    
    // force user agent system wide
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    [CookieStorage loadCookies];
    [WebViewHistory sharedInstance];
    
    self.customWebViewFactory = [[CustomWebViewFactory alloc] init];

    self.cache = [[AppURLCache alloc] init];
    
    [NSURLProtocol registerClass:[CacheURLProtocol class]];
    
    [NSURLCache setSharedURLCache:self.cache];
    
    //[NSURLProtocol registerClass:[ManagedUIWebViewURLProtocol class]];
/*    [NSURLProtocol registerClass:[MobilizeUIWebViewURLProtocol class]];*/
    //[NSURLProtocol registerClass:[CacheMonitoringURLProtocol class]];

//    [NSURLProtocol registerClass:[LoaderURLProtocol class]]; // load another
    

    //[NSURLCache setSharedURLCache:self.cache];
    
    __block AppDeck *me = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[UIDevice currentDevice] systemVersion];
        me.userProfile = [[AppDeckUserProfile alloc] initWithKey:self.loader.conf.app_api_key];
    });
    
    return self;
}

+(LoaderViewController *)open:(NSString *)url withLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /*
    
    // create navigation controller
    UINavigationController *navController = [[UINavigationController alloc] init];//initWithRootViewController:centerController];
    navController.automaticallyAdjustsScrollViewInsets = NO;
//    navController.view.frame = self.window.bounds;//CGRectMake(0, 0, self.width, self.height);
    //    navController.view.frame = CGRectMake(0, 0, self.width, self.height);
    //    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    //    navController.navigationBar.backgroundColor = [UIColor redColor];
    //    navController.navigationBar.translucent = YES;
    //    UINavigationBar
    //    navController.delegate = self;
    //    [self addChildViewController:navController];
    //    [self.view addSubview:navController.view];
//    self.window.rootViewController = navController;
    //    [self loadRootPage:self.conf.bootstrapUrl.absoluteString];
    //    return;
    
    LoaderChildViewController* page = [[LoaderChildViewController alloc] initWithNibName:nil bundle:nil URL:nil content:nil header:nil footer:nil loader:nil];
    page.view.backgroundColor = [UIColor redColor];

//    UIViewController* page = [[UIViewController alloc] initWithNibName:nil bundle:nil];
//    page.view.backgroundColor = [UIColor redColor];
    
    
    SwipeViewController *container = [[SwipeViewController alloc] initWithNibName:nil bundle:nil];
    container.current = (LoaderChildViewController *) page;
    
    
    NSArray *ctls = [NSArray arrayWithObject:container];
    //        NSArray *ctls = [NSArray arrayWithObject:page];
    [navController setViewControllers:ctls];
    
    return (LoaderViewController *)navController;*/
    
    
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    appDeck.url = url;
    appDeck.loader = [[LoaderViewController alloc] initWithNibName:nil bundle:nil];
    appDeck.loader.appDeck = [AppDeck sharedInstance];
    appDeck.loader.jsonUrl = [NSURL URLWithString:url];
//    appDeck.loader.baseUrl = [NSURL URLWithString:@"/" relativeToURL:appDeck.loader.url];
    appDeck.loader.launchOptions = launchOptions;
    [appDeck.loader loadConf];
    return appDeck.loader;
}

+(void)reloadFrom:(NSString *)url
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    glLog = nil;
    appDeck.loader.jsonUrl = [NSURL URLWithString:url];
//    appDeck.loader.baseUrl = [NSURL URLWithString:@"/" relativeToURL:appDeck.loader.url];
    appDeck.loader.syncEmbedResource = YES;
    [appDeck.loader loadConf];
}

+(void)restart
{
    AppDeck *appDeck = [AppDeck sharedInstance];
    
    appDeck.loader.jsonUrl = [NSURL URLWithString:appDeck.url];
//    appDeck.loader.baseUrl = [NSURL URLWithString:@"/" relativeToURL:appDeck.loader.url];
    
    [appDeck.loader loadConf];
}

#pragma mark API

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    call.app = self;

    
    if ([call.command isEqualToString:@"menu"] || [call.command isEqualToString:@"previousnext"])
        return YES;
    
    if ([call.command isEqualToString:@"loadextern"])
    {
        NSString *urlstring = [NSString stringWithFormat:@"%@", call.param];
        __block NSURL *externurl = [NSURL URLWithString:urlstring relativeToURL:call.child.url];
        if (externurl == nil)
            externurl = [NSURL URLWithString:urlstring];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:externurl options:@{} completionHandler:nil];
        });
        return YES;
    }
    
    if ([call.command isEqualToString:@"ping"])
    {
        //call.result = call.param;
        __block AppDeckApiCall *mycall = call;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [mycall sendCallbackWithResult:@[mycall.param]];
            });
        });
        return YES;
    }
    if ([call.command isEqualToString:@"debug"])
    {
        [call.loader.log debug:@"%@", call.param];
        return YES;
    }
    if ([call.command isEqualToString:@"info"])
    {
        
        
        [self.loader.log info:@"%@", call.param];
        return YES;
    }
    if ([call.command isEqualToString:@"warning"])
    {
        [self.loader.log warning:@"%@", call.param];
        return YES;
    }
    if ([call.command isEqualToString:@"error"])
    {
        [self.loader.log error:@"%@", call.param];
        return YES;
    }
    
    if ([call.command isEqualToString:@"inhistory"])
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", call.param] relativeToURL:call.child.url];
        NSTimeInterval lastVisited = -1;
        BOOL inHistory = [WebViewHistory inHistory:url lastVisited:&lastVisited];

        if (inHistory == YES)
        {
            lastVisited = -[[NSDate dateWithTimeIntervalSinceReferenceDate:lastVisited] timeIntervalSinceNow];
            call.result = [NSNumber numberWithDouble:lastVisited];
        }
        else
            call.result = [NSNumber numberWithBool:NO];
        
        return YES;
    }
    
    if ([call.command isEqualToString:@"preferencesget"])
    {
        NSString *name = [call.param objectForKey:@"name"];
        NSObject *defaultValue = [call.param objectForKey:@"value"];
        
        NSObject *value = [[NSUserDefaults standardUserDefaults] objectForKey:name];
        
        if (value == nil)
            value = defaultValue;
        
        call.result = value;
        
        return YES;
    }
    
    if ([call.command isEqualToString:@"preferencesset"])
    {        
        NSString *name = [call.param objectForKey:@"name"];
        NSObject *value = [call.param objectForKey:@"value"];
        
        if (![value isKindOfClass:[NSNull class]])
        {
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:name];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:name];
        }
        
        call.result = value;

        return YES;
    }

    if ([call.command isEqualToString:@"demography"])
    {
        id key = [call.param objectForKey:@"name"];
        id value = [call.param objectForKey:@"value"];
        
        [self.userProfile setValue:value forKey:key];
        
        //if (glLog)
        //    [glLog debug:@"demography %@ = %@", key, value];
        
        return YES;
    }
    
    if ([call.command isEqualToString:@"select"])
    {

        NSArray *values = [call.param objectForKey:@"values"];
        
        __block AppDeck *me = self;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIColor *myMMbackgroundColor = [UIColor whiteColor];
                UIColor *myMMtextColor = [UIColor blackColor];
                UIColor *myMMtoolbarColor = [UIColor darkGrayColor];
                UIColor *myMMbuttonColor = [UIColor darkGrayColor];
                if (me.loader.conf.icon_theme == IconThemeDark)
                {
                    myMMbuttonColor = [UIColor whiteColor];
                }
                if (me.loader.conf.app_color)
                {
                    myMMtoolbarColor = me.loader.conf.app_color;
                }
                if (me.loader.conf.app_topbar_color1)
                {
                    myMMtoolbarColor = me.loader.conf.app_topbar_color1;
                }
                if (me.loader.conf.app_topbar_text_color)
                {
                    myMMbuttonColor = me.loader.conf.app_topbar_text_color;
                }

                /*if (me.loader.conf.topbar_color1 && me.loader.conf.topbar_color2)
                {
                    CALayer * bgGradientLayer = [me.loader gradientBGLayerForBounds:CGRectMake(0, 0, 320, 64) colors:@[ (id)[me.loader.conf.topbar_color1 CGColor], (id)[me.loader.conf.topbar_color2 CGColor] ]];
                    UIGraphicsBeginImageContext(bgGradientLayer.bounds.size);
                    [bgGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
                    UIImage * bgAsImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    [[UINavigationBar appearance] setBackgroundImage:bgAsImage forBarMetrics:UIBarMetricsDefault];
                }*/
                
                NSDictionary *options = @{MMbackgroundColor: myMMbackgroundColor,
                                          MMtextColor: myMMtextColor,
                                          MMtoolbarColor: myMMtoolbarColor,
                                          MMbuttonColor: myMMbuttonColor,
                                          MMshowsSelectionIndicator: [NSNumber numberWithBool:(me.iosVersion < 7.0)]};
        [CustomMMPickerView showPickerViewInView:me.loader.view
                               withStrings:values
                               withOptions:options
                                completion:^(NSString *selectedString) {
                                    [call performSelectorOnMainThread:@selector(sendCallbackWithResult:) withObject:@[selectedString] waitUntilDone:NO];
                                }];
            });
        });

        return YES;
    }
    
    if ([call.command isEqualToString:@"selectdate"])
    {
        
        WWCalendarTimeSelector*selector=[WWCalendarTimeSelector instantiate];
        selector.delegate=self;
        
        [self.loader presentViewController:selector animated:YES completion:nil];
        
        //   [CustomDatePicker PresentInVC:self.loader fromCall:call];

        return YES;
    }
    
    if ([call.command isEqualToString:@"snackbar"])
    {
        NSLog(@"param %@", call.param);
        MDCSnackbarMessage*message = [[MDCSnackbarMessage alloc] init];
        message.text = [call.param objectForKey:@"message"];
        message.action=[[MDCSnackbarMessageAction alloc]init];
        message.action.title=[call.param objectForKey:@"action"];
        message.action.handler = ^{
             [call performSelectorOnMainThread:@selector(sendCallbackWithResult:) withObject:@[] waitUntilDone:NO];
        };
        
        [MDCSnackbarManager showMessage:message];
        return YES;
    }
    
    if ([call.command isEqualToString:@"progress"])
    {
        NSLog(@"param %@", call.param);
        MySlider*slider=[[MySlider alloc]init];
        [slider showInController:self.loader fromCall:call];
            
        return YES;
        
    }

    if ([call.command isEqualToString:@"clearcache"])
    {
        [self.cache cleanall];
/*        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        self.cache = [[AppURLCache alloc] init];
        [NSURLCache setSharedURLCache:self.cache];        */
        return YES;
    }
    
    // api key
    if ([call.command isEqualToString:@"apikey"])
    {
        call.result = self.loader.conf.app_api_key;
        return YES;
    }
    // device check
    
    if ([call.command hasPrefix:@"is"])
    {
        if ([call.command isEqualToString:@"istablet"])
            call.result = [NSNumber numberWithBool:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad];
        if ([call.command isEqualToString:@"isphone"])
            call.result = [NSNumber numberWithBool:UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad];
        if ([call.command isEqualToString:@"isios"])
            call.result = [NSNumber numberWithBool:YES];
        if ([call.command isEqualToString:@"isandroid"])
            call.result = [NSNumber numberWithBool:NO];
        if ([call.command isEqualToString:@"islandscape"])
            call.result = [NSNumber numberWithBool:self.loader.view.bounds.size.width > self.loader.view.bounds.size.height];
        if ([call.command isEqualToString:@"isportrait"])
            call.result = [NSNumber numberWithBool:self.loader.view.bounds.size.width < self.loader.view.bounds.size.height];
        return YES;
    }

    if ([call.command isEqualToString:@"loadapp"])
    {
        NSString *jsonurl = [call.param objectForKey:@"url"];
        NSString *clearcache = [call.param objectForKey:@"cache"];
        
        if ([clearcache isEqualToString:@"1"])
            [self.cache cleanall];
        
        [AppDeck reloadFrom:jsonurl];
        return YES;
    }
    
    if ([call.command isEqualToString:@"facebooklogin"])
    {
        NSArray *permissions = [call.param objectForKey:@"permissions"];
        if (permissions == nil || [[permissions class] isSubclassOfClass:[NSArray class]] == false)
            permissions = @[@"public_profile"];
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithReadPermissions:permissions
                     fromViewController:call.loader
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                    if (error) {
                                        NSLog(@"Facebook: Process error");
                                        [call sendCallbackWithResult:@[[NSNumber numberWithBool:NO]]];
                                    } else if (result.isCancelled) {
                                        NSLog(@"Facebook: Cancelled");
                                        [call sendCallbackWithResult:@[[NSNumber numberWithBool:NO]]];
                                    } else {
                                        NSLog(@"Facebook: Logged in");
                                        NSDictionary *result_cb = @{
                                                                 @"appID": result.token.appID,
//                                                                 @"tokenExpirationDate": result.token.expirationDate,
//                                                                 @"tokenRefreshDate": result.token.refreshDate,
                                                                 @"token": result.token.tokenString,
                                                                 @"userID": result.token.userID
                                                                 };

                                        [call sendCallbackWithResult:@[result_cb]];
                                    }
                                }];
        return YES;
    }
    
    if ([call.command isEqualToString:@"twitterlogin"])
    {
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                NSLog(@"signed in as %@", [session userName]);
                NSDictionary *result_cb = @{
                                            @"userName": session.userName,
                                            @"authToken": session.authToken,
                                            @"authTokenSecret": session.authTokenSecret,
                                            @"userID": session.userID
                                            };
                [call sendCallbackWithResult:@[result_cb]];
            } else {
                NSLog(@"error: %@", [error localizedDescription]);
                [call sendCallbackWithResult:@[[NSNumber numberWithBool:NO]]];
            }
        }];
        return YES;
    }
    
    if ([call.command isEqualToString:@"sendsms"])
    {
        NSString *address = [call.param objectForKey:@"address"];
        NSString *body = [call.param objectForKey:@"body"];
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = body;
            controller.recipients = [NSArray arrayWithObjects:address, nil];
            controller.messageComposeDelegate = self;
            [self.loader presentViewController:controller animated:YES completion:nil];
        }
        
        return YES;
    }
    
    if ([call.command isEqualToString:@"sendemail"])
    {
        NSString *to = [call.param objectForKey:@"to"];
        NSString *subject = [call.param objectForKey:@"subject"];
        NSString *message = [call.param objectForKey:@"message"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:subject];
        [mc setMessageBody:message isHTML:NO];
        [mc setToRecipients:@[to]];
        
        // Present mail view controller on screen
        [self.loader presentViewController:mc animated:YES completion:nil];

        
        return YES;
    }
    
    if ([call.command isEqualToString:@"openlink"])
    {
        NSString *url = [call.param objectForKey:@"url"];
        
        if (self.iosVersion >= 9.0)
        {
            SFSafariViewController *ctl = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
            ctl.view.tintColor = self.loader.conf.app_color;
            ctl.delegate = self;
            [self.loader presentViewController:ctl animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
        }
        return YES;
    }
    
    if ([call.command isEqualToString:@"getuserid"])
    {
        call.result = [CacheMonitoringURLProtocol getUserId];
        
        return YES;
    }
    
    if ([call.command isEqualToString:@"vibrate"])
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return YES;
    }
    
    return [AppDeckPluginManager handleAPICall:call];
}

// call after json config is loaded

-(void)configureApp
{
    if (shouldConfigureApp == YES)
    {
        if (self.loader.conf.twitter_consumer_key && self.loader.conf.twitter_consumer_secret &&
            self.loader.conf.twitter_consumer_key.length > 0 && self.loader.conf.twitter_consumer_secret.length > 0)
        {
            [[Twitter sharedInstance] startWithConsumerKey:self.loader.conf.twitter_consumer_key consumerSecret:self.loader.conf.twitter_consumer_secret];
            [Fabric with:@[CrashlyticsKit, [Twitter sharedInstance]]];
        } else {
            [Fabric with:@[CrashlyticsKit, [Twitter sharedInstance]]];
        }
    }
    shouldConfigureApp = NO;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"SMS cancelled");
            break;
        case MessageComposeResultSent:
            NSLog(@"SMS sent");
            break;
        case MessageComposeResultFailed:
            NSLog(@"SMS sent failure");
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self.loader dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self.loader dismissViewControllerAnimated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Close Safari browser
    [self.loader dismissViewControllerAnimated:YES completion:nil];
}

@end
