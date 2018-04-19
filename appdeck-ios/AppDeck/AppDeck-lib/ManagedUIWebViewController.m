//
//  ManagedUIWebViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 28/02/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "ManagedUIWebViewController.h"
#import "AppDeck.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
#import "WebViewHistory.h"
#import "CookieStorage.h"
#import "CustomWebViewFactory.h"
#import "AppURLCache.h"
#import "UIColor+Gradient.h"
#import "IOSVersion.h"
#import "LoaderViewController.h"

#import "iCarousel.h"

@interface ManagedUIWebViewController ()

@end

const char appdeck_inject_js[] = "javascript:if (typeof(appDeckAPICall)  === 'undefined') { appDeckAPICall = ''; var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = '//appdata.static.appdeck.mobi/js/fastclick.js'; document.getElementsByTagName('head')[0].appendChild(scr); var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = '//appdata.static.appdeck.mobi/js/appdeck.js'; document.getElementsByTagName('head')[0].appendChild(scr);}";
const long sizeof_appdeck_inject_js = sizeof(appdeck_inject_js);

@implementation ManagedUIWebViewController

+(NSMutableArray *)sharedInstanceList
{
    static NSMutableArray *array = nil;
    
    if (array == nil)
        array = [[NSMutableArray alloc] init];
    return array;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSMutableArray *sharedInstanceList = [ManagedUIWebViewController sharedInstanceList];
        [sharedInstanceList addObject:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.catch_link = YES;
    self.enable_api = YES;
/*    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;*/
    
    modules = [[NSMutableArray alloc] init];
    
//    appdeckapijs = @"var appdeckapi = function(command, param) { return JSON.parse(window.prompt('appdeckapi:' + command, JSON.stringify({param: param}))).param };";
    appdeckapijs = @"var appdeckapi = function(command, param) { return JSON.parse(window.prompt('appdeckapi:' + command, JSON.stringify(param))) };";
    appdeckapijs = @"document.write(\"<script src='http://appdata.static.appdeck.mobi/js/appdeck.js'><\\/script>\");";
    appdeckapijs = @"var appdeckapi = function(command, param) { return JSON.parse(window.prompt('appdeckapi:' + command, JSON.stringify(param))) };\
    document.addEventListener('DOMContentLoaded', function() {\
        var oScript= document.createElement('script');\
        oScript.type = 'text/javascript';\
        oScript.src = 'appdeck.js';\
        document.getElementsByTagName('HEAD').item(0).appendChild( oScript);\
        app.load();\
    });";
    
    appdeckapijs = @"";
    
    NSLog(@"%@",appdeckapijs);
    
    backgroundQueue = dispatch_queue_create("com.mobideck.page.bgqueue", NULL);    

    AppDeck *appDeck = [AppDeck sharedInstance];
    self.webView = [appDeck.customWebViewFactory getReusableWebView];
    [self.view addSubview:self.webView];    
    self.webView.delegate = self;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.scrollView.showsHorizontalScrollIndicator = YES;
    self.webView.scrollView.showsVerticalScrollIndicator = YES;
    [self.webView.scrollView setDelaysContentTouches:NO];
    self.webView.scalesPageToFit = YES;
    self.webView.mediaPlaybackRequiresUserAction = YES;
    
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;//UIDataDetectorTypeLink;//UIDataDetectorTypeAll ^ UIDataDetectorTypePhoneNumber;
    
    if (appDeck.iosVersion >= 6.0)
    {
        self.webView.keyboardDisplayRequiresUserAction = NO;
    }

    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];

    self.view.opaque = NO;
    self.webView.opaque = NO;
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressMonitoring:) name:@"WebProgressEstimateChangedNotification" object:self.coreWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self clean];
    if (webViewTimer)
    {
        [webViewTimer invalidate];
        webViewTimer = nil;
    }
    progressCallback = nil;
    completedCallback = nil;
    backgroundQueue = nil;
    AppDeck *appDeck = [AppDeck sharedInstance];
    [appDeck.customWebViewFactory addReusableWebView:self.webView];
    self.webView.scrollView.delegate = nil;
    self.webView.delegate = nil;
    self.webView = nil;
}

#pragma mark - internal

- (void)progressMonitoring:(NSNotification*)theNotification;
{
    self.progress = [[theNotification.userInfo objectForKey:@"WebProgressEstimatedProgressKey"] floatValue];
    
    if (self.progress == 1.0)
        webviewProgressFinish = [NSDate date];
    
//    NSLog(@"Progress: %f", self.progress);
}

-(void)checkWebViewLoad:(NSTimer *)timer
{
    BOOL webviewLoading = self.webView.loading;
    if (webviewProgressFinish && [webviewProgressFinish timeIntervalSinceNow] < -1.0)
        webviewLoading = NO;
    if (webviewLoading == NO)
    {
        if (self.resourceCount < self.resourceCompletedCount && completedDelay > 0)
        {
            completedDelay -= timer.timeInterval;
            return;
        }
        [timer invalidate];
        //[self syncCache];
        [self postLoadSetup];
        [self updateProgress:100];
        [self completed:nil];
        webViewTimer = nil;
    }
}

-(void)syncCache
{
    if (backgroundQueue)
    {
        myWebDataSource *dts = (myWebDataSource *)webDataSource;
        if (dts != nil && [dts respondsToSelector:NSSelectorFromString(@"subresources")])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSArray *subresources = [dts performSelector:NSSelectorFromString(@"subresources")];
#pragma clang diagnostic pop            
            //NSArray *subresources = [dts subresources];
//        dispatch_async(backgroundQueue, ^(void) {
            for (id obj in subresources)
            {
                NSURL *rurl = [obj URL];
                NSData *data = [obj data];
                NSString *MIMEType = [obj MIMEType];
                NSString *textEncodingName = [obj textEncodingName];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:rurl];
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:MIMEType expectedContentLength:[data length] textEncodingName:textEncodingName];
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                
                AppDeck *appDeck = [AppDeck sharedInstance];
                [appDeck.cache storeCachedResponse:cachedResponse forRequest:request];
            }
        }
//        });
    }
}

#pragma mark - Progress

- (void)progressEstimateChanged:(NSNotification*)theNotification
{
//    NSLog(@"progressEstimateChanged: %@", theNotification);
    
	// You can get the progress as a float with
	// [[theNotification object] estimatedProgress], and then you
	// can set that to a UIProgressView if you'd like.
	// theProgressView is just an example of what you could do.
    
    float progress = [[theNotification.userInfo objectForKey:@"WebProgressEstimatedProgressKey"] floatValue];
    //    [[theNotification object] performSelector:NSSelectorFromString(@"estimatedProgress")];
    
    if (showProgress == NO)
    {
//        [self.swipeContainer child:self startProgressWithExpectedProgress:progress inTime:60];
        showProgress = YES;
    }
    else
    {
//        [self.swipeContainer child:self updateProgressWithProgress:progress duration:0.125];
    }
    
    if (progress == 1)
    {
//        [self.swipeContainer child:self endProgressDuration:0.125];
        showProgress = NO;
    }
    
    
	//if ((int)[[theNotification object] estimatedProgress] == 1) {
    //		theProgressView.hidden = TRUE;
    // Hide the progress view. This is optional, but depending on where
    // you put it, this may be a good idea.
    // If you wanted to do this, you'd
    // have to set theProgressView to visible in your
    // webViewDidStartLoad delegate method,
    // see Apple's UIWebView documentation.
    //	}
}

-(void)updateProgress:(float)percent
{
    //NSLog(@"Progress: %0.f%% (Load:%d Res:%d/%d)", percent, webViewLoadCount, self.resourceCompletedCount, self.resourceCount);
    if (percent < 0 || percent > 100 || percent < loadingProgress || loadingProgress == -1)
        return;
    loadingProgress = percent;
    if (progressCallback)
        progressCallback(percent);
}

-(void)completed:(NSError *)error
{
    if (self == nil || self.webView == nil || /*self.webView.delegate == nil || self.webView.scrollView.delegate == nil ||*/ dead == YES)
        return;
//    [NSURLProtocol setProperty:nil forKey:@"ManagedUIWebViewController" inRequest:currentRequest];
//    if (self.currentRequest)
//        [NSURLProtocol removePropertyForKey:@"ManagedUIWebViewController" inRequest:self.currentRequest];
    //currentRequest = nil;
    if (webViewTimer)
    {
        [webViewTimer invalidate];
        webViewTimer = nil;
    }
    self.ready = YES;
    if (error != nil)
        loadingProgress = -1;
    if (progressCallback)
        progressCallback(100);
    if (completedCallback)
        completedCallback(error);
    progressCallback = nil;
    completedCallback = nil;
    
    if (self.webView && self.webView.delegate)
    {
        [WebViewHistory saveWebViewHistory:self.webView];
        [CookieStorage saveCookies];
    }
    
/*
    if (backgroundQueue)
        dispatch_async(backgroundQueue, ^(void) {
            if (self.webView && self.webView.delegate)
            {
                [WebViewHistory saveWebViewHistory:self.webView];
                [CookieStorage saveCookies];
            }
        });*/
    /*
    // meka hack
    for (UIView* subView in [self.webView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]])
        {
            for (UIView* shadowView in [subView subviews])
            {
                if ([shadowView isKindOfClass:[NSClassFromString(@"UIWebBrowserView") class]] == NO)
                {
                    [shadowView removeFromSuperview];
                    [self.view addSubview:shadowView];
                    NSLog(@"view: %@", shadowView);
                }
            }
        }
        else
        {
            NSLog(@"???: %@", subView);
        }
    }
    self.webView.hidden = YES;*/

}

#pragma mark - CustomUIWebView

@synthesize resourceCount;
@synthesize resourceCompletedCount;
@synthesize webDataSource;
@synthesize webView;
@synthesize delegate;

- (void)webView:(UIWebView *)_webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources
{
    if (totalResources < 20)
        totalResources = 20;
    
    float newProgress = 0.25 + 0.75 * ((float)resourceNumber) / ((float)totalResources + 1);
    
    [self updateProgress:newProgress*100];
}

- (void) webView:(UIWebView*)webView didFailReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources withError:(id)error
{
    [self webView:webView didReceiveResourceNumber:resourceNumber totalResources:totalResources];
}

- (NSString *)webView:(UIWebView *)webView runPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(managedWebView:runPrompt:defaultText:initiatedByFrame:)])
        return [self.delegate managedWebView:self runPrompt:prompt defaultText:defaultText initiatedByFrame:frame];
    return @"";
}

#pragma mark - UIWebView Delegate

- (void) webView:(UIWebView*)webView willLoadFrameRequest:(NSURLRequest *)request
{
    urlForNextFrameRequest = request.URL.absoluteString;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest: webView: %p method: %@ url: %@ - navigation : %ld - cache: %ld", webView, [request HTTPMethod], [[request URL] absoluteString],
          (long)navigationType, (long)request.cachePolicy);
    
    // try to auto detect
    if (first)
    {
        //[self.webView stringByEvaluatingJavaScriptFromString:appdeckapijs];
        first = NO;
        return YES;
    }

    // API disable catch link
    if (self.catch_link == NO)
        return YES;   
    
    // this URL was previously marked as a frame request
    if ([urlForNextFrameRequest isEqualToString:request.URL.absoluteString] /*&& navigationType != UIWebViewNavigationTypeOther*/)
        return YES;

    if ([request.URL.absoluteString isEqualToString:@"about:blank"])
    {
        return YES;
    }
    
    if ([request.HTTPMethod isEqualToString:@"POST"])
    {
        self.currentRequest = [request mutableCopy];        
        return YES;
    }
    
    /*if (navigationType == UIWebViewNavigationTypeFormSubmitted)
    {
        self.currentRequest = [request mutableCopy];
        return YES;
    }*/
    
/*    if (webViewLoadCount == 0 && navigationType == UIWebViewNavigationTypeOther)
        return YES;*/
    
    if (webViewLoadCount > 0 && navigationType == UIWebViewNavigationTypeOther)
    {
        // we store this frame url for net iframe test
        if (frames == nil)
            frames = [[NSMutableArray alloc] init];
        [frames addObject:request.URL.absoluteString];
        return YES;
    }
    
    // handle famous app
    if ([[[request URL] absoluteString] hasPrefix:@"fb://"])
    {
        [[UIApplication sharedApplication] openURL:[request URL] options:@{} completionHandler:nil];
        return NO;
    }

    // handle facebook
    if ([[[request URL] absoluteString] hasPrefix:@"http://www.facebook.com/"])
        return YES;
    
    // handle dailymotion video
    if ([[[request URL] absoluteString] hasPrefix:@"http://www.dailymotion.com/"])
        return YES;
    if ([[[request URL] host] rangeOfString:@"dailymotion"].location != NSNotFound)
        return YES;
    
    // handle slideshare
    if ([[[request URL] absoluteString] hasPrefix:@"http://www.slideshare.net"])
        return YES;
    
    // handle youtube video
    if ([[[request URL] absoluteString] hasPrefix:@"http://www.youtube.com/"])
        return YES;
    if ([[[request URL] absoluteString] hasPrefix:@"http://mobile.youtube.com/"])
        return YES;
    
    // handle eplayerhtml5 video
    if ([[[request URL] absoluteString] hasPrefix:@"http://www.eplayerhtml5.performgroup.com/"])
        return YES;
    if ([[[request URL] absoluteString] hasPrefix:@"http://cdn-static.liverail.com/"])
        return YES;
    
    // handle brightcove
//    if ([[[request URL] absoluteString] hasPrefix:@"http://c.brightcove.com/"])
//        return YES;
    

    NSRange range = [[[request URL] absoluteString] rangeOfString:@"#"];
//    if (range.location != NSNotFound)
//        return YES;
    if (range.location != NSNotFound)
    {
        NSString *anchor_free_dest_url = [request.URL.absoluteString substringToIndex:range.location];
        NSLog(@"anchor free: %@ <=> %@", anchor_free_dest_url, self.currentRequest.URL.absoluteString);
        if ([self.currentRequest.URL.absoluteString hasPrefix:anchor_free_dest_url])
            return YES;
    }

    
    range = [[[request URL] absoluteString] rangeOfString:@"about:blank"];
    if (range.location != NSNotFound)
        return YES;

    range = [[[request URL] absoluteString] rangeOfString:@"javascript:"];
    if (range.location != NSNotFound)
        return YES;

    /*
    // detect iframe
    NSString *referer = [request.allHTTPHeaderFields objectForKey:@"Referer"];
    NSString *currentPage = [self.webView.request.mainDocumentURL absoluteString];
    BOOL isFrameLoad = [referer isEqualToString:currentPage] == NO;
    if (frames)
        for (NSString *frameURL in frames)
            if ([referer isEqualToString:frameURL])
                isFrameLoad = YES;
    if (isFrameLoad)
    {
        // we store this frame url for net iframe test
        if (frames == nil)
            frames = [[NSMutableArray alloc] init];
        [frames addObject:request.URL.absoluteString];
        return YES;
    }*/
    
    
/*    // handle facebook sharer
    if ([[[request URL] absoluteString] hasPrefix:@"http://m.facebook.com/sharer.php"])
    {
        NSMutableDictionary *params = [ToolBox parseQuery: [[request URL] absoluteString]];
        NSLog(@"FB params: %@", params);
        NSURL *share_url = [NSURL URLWithString:[params objectForKey:@"u"]];
        NSString *share_title = [params objectForKey:@"t"];
        if (share_title == nil)
            share_title = @"Facebook";
        NSString *share_post = [params objectForKey:@"p"];
        if (share_post == nil)
            share_post = @"share";
        SHKItem *item = [SHKItem URL:share_url title:share_title];
        item = [SHKItem URL:share_url title:share_post];
        [SHKFacebook shareItem:item];
        return NO;
    }*/
    
/*    if ([[request HTTPMethod] isEqualToString:@"POST"])
    {
        self.currentRequest = [request mutableCopy];
        return YES;
    }*/
    
    int ret = [self.delegate managedWebView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    
    if (ret == YES)
        self.currentRequest = [request mutableCopy];
    
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
/*    if (webViewLoadCount == 0)
        [webView stringByEvaluatingJavaScriptFromString:appdeckapijs];*/
    webViewLoadCount++;
    //NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [webView stringByEvaluatingJavaScriptFromString:appdeckapijs];
    /*
    [webView stringByEvaluatingJavaScriptFromString:@"document.addEventListener('DOMContentLoaded', function() { appdeckScript = document.createElement('script');\
     appdeckScript.type = 'text/javascript';\
     appdeckScript.src='appdeck.js';\
     document.head.appendChild(appdeckScript);  });"];*/
//    [webView stringByEvaluatingJavaScriptFromString:appdeckapijs];
    webViewLoadCount--;
    //NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    webViewLoadCount--;
    if (webViewLoadCount == 0 && webViewTimer == nil /* loaded not raised */)
        [self completed:error];
}

#pragma mark - initialConnection API

- (void)initialRequestDidReceiveResponse:(NSHTTPURLResponse *)response
{
    [self updateProgress:5];
}

- (void)initialRequestDidReceiveData:(NSData *)mydata offset:(NSUInteger)offset total:(NSUInteger)total
{
    if (total <= 0)
        total = 128 * 1024;
    if (offset > total)
        total = offset;
    [self updateProgress:(5 + (offset / total) * 20)];
}

- (void)initialRequestDidFinishLoading
{
    [self updateProgress:25];
}

- (void)initialRequestDidFailWithError:(NSError *)error
{
    [self postLoadSetup];
    [self completed:error];
}

#pragma mark - API

-(void)sendJSEvent:(NSString *)name withJsonData:(NSString *)dataJson
{
    NSString *js;
    if (dataJson == nil)
        dataJson = @"''";
    AppDeck *appDeck = [AppDeck sharedInstance];
    if (appDeck.iosVersion >= 6.0)
    {
        js = [NSString stringWithFormat:@"document.dispatchEvent(new CustomEvent('%@', { 'detail': %@ }));", name, dataJson];
    } else {
        js = [NSString stringWithFormat:@"var evt = document.createEvent('Event');evt.initEvent('%@',true,true); evt.detail = %@; document.dispatchEvent(evt);", name, dataJson];
    }
    [self executeJS:js];
}





+(void)addURLInHistory:(NSString *)manual_url
{
    for (ManagedUIWebViewController *ctl in [ManagedUIWebViewController sharedInstanceList])
    {
        [ctl manualAddURLInHistory: manual_url];
    }
}

-(void)addURLInOtherHistory:(NSString *)manual_url
{
//    NSURL *url = [NSURL URLWithString:manual_url];
    // check if URL is not already in history
    //if ([WebViewHistory inHistory:url lastVisited:nil])
    //    return;
    for (ManagedUIWebViewController *ctl in [ManagedUIWebViewController sharedInstanceList])
    {
        /*if (ctl == self)
            continue;
        if ([ctl.currentRequest.URL.absoluteString isEqualToString:url.absoluteString])
            continue;*/
        //NSLog(@"add url %@ in %@", manual_url, ctl.currentRequest);
        [ctl manualAddURLInHistory: manual_url];
    }
}

-(void)manualAddURLInHistory:(NSString *)manual_url
{
    if (self.ready == NO)
        return;
    
    NSURL *murl = [NSURL URLWithString:manual_url];
    NSString *host = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.host"];
    
    if ([murl.host isEqualToString:host] == NO)
        return;
    
    //id<UIApplicationDelegate> app = [[UIApplication sharedApplication] delegate];
    //if ([self.view isDescendantOfView:app.window] == NO)
    //  return;
    
    //AppDeck *app = [AppDeck sharedInstance];
//    if ([self.view isDescendantOfView:<#(UIView *)#>])
//    if ([app.window is
    NSString *code = [NSString stringWithFormat:@"var desired_url = '%@'; var current_url = window.location.href; history.replaceState({},'',desired_url); history.replaceState({},'',current_url);", manual_url];
  
    //NSLog(@"add '%@' to history of '%@'", manual_url, self.currentRequest);

    [self.webView stringByEvaluatingJavaScriptFromString:code];
}

-(id)browser
{
    for (UIView* subView in [self.webView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]])
        {
            for (UIView* subSubView in [subView subviews])
            {
                if ([subSubView isKindOfClass:NSClassFromString(@"UIWebBrowserView")])
                {
                    return subSubView;
                }
            }
        }
    }
    return nil;
}

-(id)coreWebView
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id documentView = [self.webView performSelector:NSSelectorFromString(@"_documentView")];
#pragma clang diagnostic pop    
    id coreWebView = [documentView webView];
    return coreWebView;
}



-(void)setChromeless:(BOOL)hidden
{
    for (UIView* subView in [self.webView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]])
        {
            for (UIView* shadowView in [subView subviews])
            {
                if ([shadowView isKindOfClass:[UIImageView class]])
                {
                    [shadowView setHidden:hidden];
                }
            }
        }
    }
}

-(void)loadRequest:(NSURLRequest *)_request progess:(ManagedWebViewProgressCallBack)_progressCallback completed:(ManagedWebViewCompletedCallBack)_completedCallback
{
//    [self cleanModules];
    if (webViewTimer)
    {
        [webViewTimer invalidate];
        webViewTimer = nil;
    }
    self.resourceCount = 0;
    self.resourceCompletedCount = 0;
    loadingProgress = 0;
    completedDelay = 0.5; // we can wait until X seconds for ressources to load until declare page loaded
    progressCallback = _progressCallback;
    completedCallback = _completedCallback;
    self.ready = NO;
    first = YES;
    [self updateProgress:0];
    
    NSMutableURLRequest *mutableRequest = [_request mutableCopy];
    mutableRequest = [mutableRequest mutableCopy];
//    [mutableRequest addValue:@"1" forHTTPHeaderField:@"AppDeck-WebView"];
    me = [@[self] mutableCopy];
    //if (self.enable_api)
    //    [NSURLProtocol setProperty:me forKey:@"ManagedUIWebViewController" inRequest:mutableRequest];
    NSURLRequest *request = mutableRequest;//[mutableRequest copy];

    [self.webView loadRequest:request];
    self.currentRequest = mutableRequest;

    webViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkWebViewLoad:) userInfo:nil repeats:YES];
}

-(void)loadHTMLString:(NSString *)html baseRequest:(NSURLRequest *)_request progess:(ManagedWebViewProgressCallBack)_progressCallback completed:(ManagedWebViewCompletedCallBack)_completedCallback
{
//    [self cleanModules];
    if (webViewTimer)
    {
        [webViewTimer invalidate];
        webViewTimer = nil;
    }
    self.resourceCount = 0;
    self.resourceCompletedCount = 0;
    loadingProgress = 0;
    completedDelay = 0.5; // we can wait until X seconds for ressources to load until declare page loaded
    progressCallback = _progressCallback;
    completedCallback = _completedCallback;
    self.ready = NO;
    first = YES;
    [self updateProgress:0];
    
    NSMutableURLRequest *mutableRequest = [_request mutableCopy];
    mutableRequest = [mutableRequest mutableCopy];
    me = [@[self] mutableCopy];
    //if (self.enable_api)
    //    [NSURLProtocol setProperty:me forKey:@"ManagedUIWebViewController" inRequest:mutableRequest];
    NSURLRequest *request = mutableRequest;//[mutableRequest copy];

    [self.webView loadHTMLString:html baseURL:request.URL];
    
    self.currentRequest = mutableRequest;
    
    webViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkWebViewLoad:) userInfo:nil repeats:YES];
}

/*
-(void)loadRequest:(NSURLRequest *)_request withCachedResponse:(NSCachedURLResponse*)cachedResponse progess:(ManagedUIWebViewProgressCallBack)_progressCallback completed:(ManagedUIWebViewCompletedCallBack)_completedCallback
{
    [self cleanModules];
    if (webViewTimer)
    {
        [webViewTimer invalidate];
        webViewTimer = nil;
    }
    self.currentRequest = [_request mutableCopy];
    
    self.resourceCount = 0;
    self.resourceCompletedCount = 0;
    loadingProgress = 0;
    completedDelay = 0.5; // we can wait until X seconds for ressources to load until declare page loaded
    progressCallback = _progressCallback;
    completedCallback = _completedCallback;
    self.ready = NO;
    first = YES;
    [self updateProgress:0];
    
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)cachedResponse.response;
    
    NSLog(@"Enconding: %@", httpResponse.textEncodingName);
    NSLog(@"data: %@", cachedResponse.data);
    
    [self.webView loadData:cachedResponse.data MIMEType:httpResponse.MIMEType textEncodingName:httpResponse.textEncodingName baseURL:_request.URL];

    webViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkWebViewLoad:) userInfo:nil repeats:YES];
}*/

/*
-(void)cleanModules
{
    for (WebViewModuleViewController *module in modules)
    {
        [module.view removeFromSuperview];
        [module removeFromParentViewController];
    }
    modules = [[NSMutableArray alloc] init];
}*/


-(void)clean
{
    [super clean];
    [webViewTimer invalidate];
    webViewTimer = nil;
//    [self cleanModules];
    NSMutableArray *sharedInstanceList = [ManagedUIWebViewController sharedInstanceList];
    [sharedInstanceList removeObject:self];
    //[self syncCache];
    self.delegate = nil;
    [self.webView stopLoading];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//    [self.webView loadHTMLString:@"<html><body></body></html>" baseURL:[NSURL URLWithString:@"http://null/"]];
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
    AppDeck *appDeck = [AppDeck sharedInstance];
    if (appDeck.iosVersion >= 6.0)
        self.webView.suppressesIncrementalRendering = NO;
    [self.webView loadHTMLString:@"" baseURL:nil];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.coreWebView performSelector:NSSelectorFromString(@"setMaintainsBackForwardList:") withObject:nil];
    [self.coreWebView performSelector:NSSelectorFromString(@"setMaintainsBackForwardList:") withObject:self];
#pragma clang diagnostic pop
    
    [self.webView removeFromSuperview];
}

-(id)JSonObjectByEvaluatingJavascriptFromString:(NSString *)js error:(NSError **)error
{
    NSString *result_json = [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSData *result_json_data = [result_json dataUsingEncoding:NSUTF8StringEncoding];
    id result_call = nil;
    @try {
        result_call = [NSJSONSerialization JSONObjectWithData:result_json_data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:error];
    }
    @catch (NSException *exception) {
        return nil;
    }
    return result_call;
}

-(void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
    if (completionHandler)
        completionHandler(result, nil);
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    if (script)
        return [self.webView stringByEvaluatingJavaScriptFromString:script];
    return nil;
}

-(void)postLoadSetup
{
    if (self.enable_api)
    {
        NSString *js = [NSString stringWithCString:appdeck_inject_js encoding:NSUTF8StringEncoding];
        /*
        NSString *js = [NSString stringWithFormat:@"if (typeof(appDeckAPICall)  === 'undefined') { appDeckAPICall = ''; var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/fastclick.js'; document.getElementsByTagName('head')[0].appendChild(scr); var scr = document.createElement('script'); scr.type='text/javascript';  scr.src = 'http://appdata.static.appdeck.mobi/js/appdeck_1.10.js'; document.getElementsByTagName('head')[0].appendChild(scr);}"];*/
        [self.webView stringByEvaluatingJavaScriptFromString:js];
    }
//    [webView stringByEvaluatingJavaScriptFromString:@"$(document).ready(function () {jQuery.ajaxSetup({isLocal:true}); });"];
//    [webView stringByEvaluatingJavaScriptFromString:@"$( document ).on( 'pagechange', function( event, data ){ setTimeout(\"prompt('event:pagechange')\",250); });"];
}

-(UIScrollView *)scrollView
{
    return self.webView.scrollView;
}

-(void)webView:(UIWebView *)webView shouldLoadUrl:(NSURL *)url withHTML:(NSString *)html
{
    //html = nil;
    if (html != nil)
    {
        [webView loadHTMLString:html baseURL:url];
    } else {
        /*
         NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
         [webView loadRequest:request];
         */
        
        [webView stringByEvaluatingJavaScriptFromString:@"$(document).ready(function () {jQuery.ajaxSetup({isLocal:true}); });"];
        NSString *js = [NSString stringWithFormat:@"$.mobile.changePage('%@', { allowSamePageTransition : true, transition: 'none', showLoadMsg: false, reloadPage: true});", [url absoluteString]];
        [webView stringByEvaluatingJavaScriptFromString:js];
        // wait page to be loaded
        //[webView stringByEvaluatingJavaScriptFromString:@"$( document ).on( 'pagechange', function( event, data ){ setTimeout(\"prompt('event:pagechange')\",250); });"];
        
    }
    [webView stringByEvaluatingJavaScriptFromString:@"$( document ).on( 'load', function( event, data ){ setTimeout(\"prompt('event:load')\",250); });"];
    
    [webView stringByEvaluatingJavaScriptFromString:@"$( document ).on( 'pagechange', function( event, data ){ setTimeout(\"prompt('event:pagechange')\",250); });"];
    
    //    [webView stringByEvaluatingJavaScriptFromString:@"    if(document.loaded) { prompt('toto', 'tutu'); } else { window.addEventListener('load', prompt('toto', 'tutu'), false); }"];
    //    [webView stringByEvaluatingJavaScriptFromString:@"window.addEventListener('load', prompt('toto', 'tutu'), false);"];
    //    [webView stringByEvaluatingJavaScriptFromString:@"$(document).ready(function() { prompt('toto', 'tutu');  });"];
    
}

-(BOOL)canGoBack
{
    return [self.webView canGoBack];
}
-(BOOL)canGoForward
{
    return [self.webView canGoForward];
}

-(BOOL)isLoading
{
    return [self.webView isLoading];
}

-(void)goBack
{
    [self.webView goBack];
}

-(void)goForward
{
    [self.webView goForward];
}

-(void)stopLoading
{
    [self.webView stopLoading];
}

@end
