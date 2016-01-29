//
//  ManagedWKWebViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/01/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import "ManagedWKWebViewController.h"
#import "AppDeck.h"
#import "SIAlertView.h"

@interface ManagedWKWebViewController ()

@end

@implementation ManagedWKWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //AppDeck *appDeck = [AppDeck sharedInstance];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.requiresUserActionForMediaPlayback = NO;
    configuration.processPool = [ManagedWKWebViewController sharedWKProcessPool];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    [self.view addSubview:self.webView];    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.scrollView.showsHorizontalScrollIndicator = YES;
    self.webView.scrollView.showsVerticalScrollIndicator = YES;
    [self.webView.scrollView setDelaysContentTouches:NO];


    // http://stackoverflow.com/questions/25977764/wkwebkit-no-datadetectortypes-parameter
    //self.webview.dataDetectorTypes = UIDataDetectorTypeNone;
    // https://github.com/Telerik-Verified-Plugins/WKWebView/issues/184
    //self.webView.keyboardDisplayRequiresUserAction = NO;
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.view.opaque = NO;
    self.webView.opaque = NO;
    

    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressMonitoring:) name:@"WebProgressEstimateChangedNotification" object:self.coreWebView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

}

+(WKProcessPool *)sharedWKProcessPool
{
    static WKProcessPool *pool = nil;
    if (pool == nil)
        pool = [[WKProcessPool alloc] init];
    return pool;
}

-(UIScrollView *)scrollView
{
    return self.webView.scrollView;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        [self updateProgress:self.webView.estimatedProgress*100];
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    if (self == nil || self.webView == nil || dead == YES)
        return;
/*    if (webViewTimer)
    {
        [webViewTimer invalidate];
        webViewTimer = nil;
    }*/
//    self.ready = YES;
    if (error != nil)
        loadingProgress = -1;
    if (progressCallback)
        progressCallback(100);
    if (completedCallback)
        completedCallback(error);
    progressCallback = nil;
    completedCallback = nil;
    
/*    if (self.webView && self.webView.delegate)
    {
        [WebViewHistory saveWebViewHistory:self.webView];
        [CookieStorage saveCookies];
    }*/
}

#pragma mark - WKNavigationDelegate


/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // try to auto detect
    if (first)
    {
        first = NO;
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    if (self.catch_link == YES && navigationAction.sourceFrame.isMainFrame && navigationAction.targetFrame.isMainFrame)
    {
        int ret = [self.delegate managedWebView:self shouldStartLoadWithRequest:navigationAction.request navigationType:0];
        
        if (ret == NO)
        {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

/*! @abstract Decides whether to allow or cancel a navigation after its
 response is known.
 @param webView The web view invoking the delegate method.
 @param navigationResponse Descriptive information about the navigation
 response.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
 @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{

}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self completed:error];
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self completed:nil];
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self completed:error];
}

/*! @abstract Invoked when the web view needs to respond to an authentication challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to the challenge. The
 disposition argument is one of the constants of the enumerated type
 NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
 the credential argument is the credential to use, or nil to indicate continuing without a
 credential.
 @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
/*- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{

}*/

/*! @abstract Invoked when the web view's web content process is terminated.
 @param webView The web view whose underlying web content process was terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0)
{
    
}

#pragma mark - WKUIDelegate


/*! @abstract Creates a new web view.
 @param webView The web view invoking the delegate method.
 @param configuration The configuration to use when creating the new web
 view.
 @param navigationAction The navigation action causing the new web view to
 be created.
 @param windowFeatures Window features requested by the webpage.
 @result A new web view or nil.
 @discussion The web view returned must be created with the specified configuration. WebKit will load the request in the returned web view.
 
 If you do not implement this method, the web view will cancel the navigation.
 */
/*- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    
}*/

/*! @abstract Notifies your app that the DOM window object's close() method completed successfully.
 @param webView The web view invoking the delegate method.
 @discussion Your app should remove the web view from the view hierarchy and update
 the UI as needed, such as by closing the containing browser tab or window.
 */
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0)
{
    
}

/*! @abstract Displays a JavaScript alert panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this
 call.
 @param completionHandler The completion handler to call after the alert
 panel has been dismissed.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have a single OK button.
 
 If you do not implement this method, the web view will behave as if the user selected the OK button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
    
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Button1 Clicked");
                          }];
/*    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Button2 Clicked");
                          }];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Button3 Clicked");
                              //completionHandler();
                          }];*/
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
        completionHandler();
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

/*! @abstract Displays a JavaScript confirm panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the confirm
 panel has been dismissed. Pass YES if the user chose OK, NO if the user
 chose Cancel.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

/*! @abstract Displays a JavaScript text input panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param defaultText The initial text to display in the text entry field.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the text
 input panel has been dismissed. Pass the entered text if the user chose
 OK, otherwise nil.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel, and a field in
 which to enter text.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    if ([prompt hasPrefix:@"appdeckapi:"])
    {
        if (self.delegate!= nil && [self.delegate respondsToSelector:@selector(apiCall:)])
        {
            AppDeckApiCall *call = [[AppDeckApiCall alloc] init];
            call.app = [AppDeck sharedInstance];
            call.command = [prompt substringFromIndex:11];
            call.inputJSON = defaultText;
            
            BOOL success = [self apiCall:call];
            
            if (success == NO)
                NSLog(@"API unsuported command: %@", call.command);
            
            NSString *ret = [NSString stringWithFormat:@"{\"success\": \"%d\", \"result\": %@}", success, call.resultJSON];
            completionHandler(ret);
        }
        else
        {
            NSLog(@"lost API CALL: %@", prompt);
            completionHandler(@"");
        }
        return;
    }
/*    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(managedWebView:runPrompt:defaultText:initiatedByFrame:)])
        result = [self.delegate managedWebView:self runPrompt:prompt defaultText:defaultText initiatedByFrame:frame];
    completionHandler(result);*/
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        //textField.placeholder = defaultText;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark - Managed WebView API


-(void)loadRequest:(NSURLRequest *)request progess:(ManagedWebViewProgressCallBack)myProgressCallback completed:(ManagedWebViewCompletedCallBack)myCompletedCallback
{
    first = YES;
    loadingProgress = 0;
    progressCallback = myProgressCallback;
    completedCallback = myCompletedCallback;
    self.currentRequest = request.mutableCopy;
    currentNavigation = [self.webView loadRequest:request];
}

-(void)loadHTMLString:(NSString *)html baseRequest:(NSURLRequest *)_request progess:(ManagedWebViewProgressCallBack)_progressCallback completed:(ManagedWebViewCompletedCallBack)_completedCallback
{
    
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

/*- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    
}

-(NSString *)executeJS:(NSString *)js
{
    
}*/

-(void)sendJSEvent:(NSString *)name withJsonData:(NSString *)dataJson{
    if (dataJson == nil)
        dataJson = @"''";
    NSString *js = [NSString stringWithFormat:@"document.dispatchEvent(new CustomEvent('%@', { 'detail': %@ }));", name, dataJson];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}

/* history API */
+(void)addURLInHistory:(NSString *)manual_url
{
    
}

-(void)manualAddURLInHistory:(NSString *)manual_url
{
    
}

-(void)addURLInOtherHistory:(NSString *)manual_url
{
    
}

-(void)clean
{
    if (self.webView)
    {
        self.webView.scrollView.delegate = nil;
        [self.webView removeFromSuperview];
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        
        // if you have set either WKWebView delegate also set these to nil here
        [self.webView setNavigationDelegate:nil];
        [self.webView setUIDelegate:nil];
        self.webView = nil;
    }
    self.delegate = nil;
    [super clean];    
}

- (void)dealloc
{
    [self clean];
}

/* webview API */
-(BOOL)canGoBack
{
    return self.webView.canGoBack;
}

-(BOOL)canGoForward
{
    return self.webView.canGoForward;
}

-(BOOL)isLoading
{
    return self.webView.isLoading;
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
