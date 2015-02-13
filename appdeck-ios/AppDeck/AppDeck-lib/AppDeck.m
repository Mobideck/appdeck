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
#import "MobilizeUIWebViewURLProtocol.h"
#import "CacheMonitoringURLProtocol.h"
#import "CustomWebViewFactory.h"
#import "LoaderURLProtocol.h"
#import "LogViewController.h"
#import "JSONKit.h"
#import "WebViewHistory.h"
//#import "TestFlight.h"
#import "MMPickerView/CustomMMPickerView.h"

#import "SelectActionSheet.h"

#import "SwipeViewController.h"
#import "UIScrollView+ScrollsToTop.h"
#import "iRate/iRate-1.11.3/iRate/iRate.h"

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
        self.userAgent = [[firstWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] stringByAppendingString:@" AppDeck-tablet"];
    else
        self.userAgent = [[firstWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] stringByAppendingString:@" AppDeck-phone"];
    
    // force user agent system wide
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    [CookieStorage loadCookies];
    [WebViewHistory sharedInstance];
    
    self.customWebViewFactory = [[CustomWebViewFactory alloc] init];
    
    [NSURLProtocol registerClass:[ManagedUIWebViewURLProtocol class]];
/*    [NSURLProtocol registerClass:[MobilizeUIWebViewURLProtocol class]];*/
    [NSURLProtocol registerClass:[CacheMonitoringURLProtocol class]];

//    [NSURLProtocol registerClass:[LoaderURLProtocol class]]; // load another
    
    self.cache = [[AppURLCache alloc] init];
    [NSURLCache setSharedURLCache:self.cache];
    
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
    
/*    if ([call.command isEqualToString:@"menu"])
    {

        
        return @"";
    }*/
    
    if ([call.command isEqualToString:@"loadextern"])
    {
        NSString *urlstring = [NSString stringWithFormat:@"%@", call.param];
        __block NSURL *externurl = [NSURL URLWithString:urlstring relativeToURL:call.child.url];
        if (externurl == nil)
            externurl = [NSURL URLWithString:urlstring];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:externurl];
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
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:name];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
        //NSString *title = [call.param objectForKey:@"title"];
        NSArray *values = [call.param objectForKey:@"values"];
        
        __block AppDeck *me = self;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *options = @{MMbackgroundColor: [UIColor whiteColor],
                                          MMtextColor: [UIColor blackColor],
                                          MMtoolbarColor: [UIColor darkGrayColor],
                                          MMbuttonColor: [UIColor darkGrayColor],
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
        id year = [call.param objectForKey:@"year"];
        id month = [call.param objectForKey:@"month"];
        id day = [call.param objectForKey:@"day"];
        
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"AppDeck" delegate:nil cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles: nil];
        
        // init the date
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];

        if (day != nil && day != [NSNull null])
            [components setDay:[day intValue]];
        if (month != nil && month != [NSNull null])
            [components setMonth:[month intValue]];
        if (year != nil&& year != [NSNull null])
            [components setYear:[year intValue]];

        NSDate *date = [calendar dateFromComponents:components];

        
        // Add the picker
        UIDatePicker *pickerView = [[UIDatePicker alloc] init];
        pickerView.date = date;
        pickerView.datePickerMode = UIDatePickerModeDate;
        [action addSubview:pickerView];
        
        [action showInView:self.loader.view];

        [action setBounds:CGRectMake(0,0,320, 500)];
        
        CGRect pickerRect = pickerView.bounds;
        pickerRect.origin.y = -100;
        pickerView.bounds = pickerRect;
        
        NSRunLoop *rl = [NSRunLoop currentRunLoop];
        NSDate *d;
        while ([action isVisible]) {
            d = [[NSDate alloc] init];
            [rl runUntilDate:d];
        }
        
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:pickerView.date]; // Get necessary date components
        call.result = @{@"year": [NSNumber numberWithInteger:[components year]], @"month" : [NSNumber numberWithInteger:[components month]], @"day" : [NSNumber numberWithInteger:[components day]]};
/*
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"O rlly?" message:nil delegate:nil
                              cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        NSRunLoop *rl = [NSRunLoop currentRunLoop];
        NSDate *d;
        while ([alert isVisible]) {
            d = [[NSDate alloc] init];
            [rl runUntilDate:d];
        }
 
         call.result = @"OK";
 */
        

        
        return YES;
    }
    
    if ([call.command isEqualToString:@"clearcache"])
    {
        [self.cache cleanall];
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        self.cache = [[AppURLCache alloc] init];
        [NSURLCache setSharedURLCache:self.cache];        
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
    
    
    return NO;
}

/*
-(id)api:(NSString *)command param:(id)param
{
    NSLog(@"API %@: %@", command, param);
    if ([command isEqualToString:@"menu"])
    {
        LoaderChildViewController * child = [self.loader getCurrentChild];
        
        return @"";
    }
    if ([command isEqualToString:@"ping"])
    {
        return param;
    }
    if ([command isEqualToString:@"debug"])
    {
        [self.loader.log debug:@"%@", param];
        return @"";
    }
    if ([command isEqualToString:@"info"])
    {
        [self.loader.log info:@"%@", param];
        return @"";
    }
    if ([command isEqualToString:@"warning"])
    {
        [self.loader.log warning:@"%@", param];
        return @"";
    }
    if ([command isEqualToString:@"error"])
    {
        [self.loader.log error:@"%@", param];
        return @"";
    }
    if ([command isEqualToString:@"test"])
    {
        return [NSString stringWithFormat:@" --- %@ ---", param];
    }

    return @"";
}

-(NSString *)JSapi:(NSString *)command param:(NSString *)paramJSON
{
    NSError *error = nil;
    
    NSData *paramJSONData = [paramJSON dataUsingEncoding:NSUTF8StringEncoding];
    id param = nil;
    @try {
        param = [NSJSONSerialization JSONObjectWithData:paramJSONData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        //param = [paramJSONData objectFromJSONDataWithParseOptions:JKParseOptionComments|JKParseOptionUnicodeNewlines|JKParseOptionLooseUnicode|JKParseOptionPermitTextAfterValidJSON error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"JSAPI: Exception while reading JSon: %@: %@", exception, paramJSON);
        return @"false";
    }

    if (error != nil)
    {
        NSLog(@"JSAPI: Error while reading JSon: %@: %@", error, paramJSON);
        return @"false";
    }
    
    id realparam = [param objectForKey:@"param"];
    
    id ret = [self api:command param:realparam];
    NSDictionary *retDic = @{@"param" : ret};
    
    NSData *retData = nil;
    @try {
        retData = [NSJSONSerialization dataWithJSONObject:retDic options:NSJSONWritingPrettyPrinted error:&error];
        //retData = [retArray JSONDataWithOptions:JKSerializeOptionPretty|JKSerializeOptionEscapeUnicode error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"JSAPI: Exception while writing JSon: %@: %@", exception, ret);
        return @"false";
    }

    if (error != nil)
    {
        NSLog(@"JSAPI: Error while writing JSon: %@: %@", error, ret);
        return @"false";
    }
    
    NSString *retJson = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
    return retJson;
}
*/
@end
