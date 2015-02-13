//
//  ManagedUIWebViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 28/02/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "CustomUIWebView.h"
#import "AppDeckApiCall.h"

@class ManagedUIWebViewController;
@class WebViewModuleViewController;

@protocol ManagedUIWebViewDelegate <NSObject>

- (BOOL)managedUIWebViewController:(ManagedUIWebViewController *)managedUIWebViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@optional
- (NSString *)webView:(UIWebView *)webView runPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame;


@end

typedef void ( ^ManagedUIWebViewProgressCallBack )( float progress ) ;
typedef void ( ^ManagedUIWebViewCompletedCallBack )( NSError *error ) ;

@interface ManagedUIWebViewController : UIViewController <UIWebViewDelegate, CustomUIWebViewProgressDelegate, AppDeckApiCallDelegate>
{
    BOOL dead;
    
    NSMutableArray *me;
    
    NSTimer *webViewTimer;
    
    float loadingProgress;
    
    ManagedUIWebViewProgressCallBack progressCallback;
    ManagedUIWebViewCompletedCallBack completedCallback;
    
    float       completedDelay;
    NSInteger   webViewLoadCount;
    
    dispatch_queue_t backgroundQueue;
    
    BOOL    first;

//    NSMutableURLRequest *currentRequest;
    
    BOOL showProgress;

    UIView  *topView;
    
    NSString *appdeckapijs;
//    UIView  *bottomView;
    
    UIView  *mask;
    
    // modules
    WebViewModuleViewController *viewController;
    
    NSMutableArray *modules;
    
    NSMutableArray *frames;
    NSString *urlForNextFrameRequest;
    
    NSDate  *webviewProgressFinish;
}

@property (strong, nonatomic) CustomUIWebView *webView;

@property (strong, nonatomic) NSMutableURLRequest *currentRequest;

-(void)loadRequest:(NSURLRequest *)request progess:(ManagedUIWebViewProgressCallBack)progressCallback completed:(ManagedUIWebViewCompletedCallBack)completedCallback;
-(void)loadHTMLString:(NSString *)html baseRequest:(NSURLRequest *)_request progess:(ManagedUIWebViewProgressCallBack)_progressCallback completed:(ManagedUIWebViewCompletedCallBack)_completedCallback;
/*-(void)loadRequest:(NSURLRequest *)_request withCachedResponse:(NSCachedURLResponse*)cachedResponse progess:(ManagedUIWebViewProgressCallBack)_progressCallback completed:(ManagedUIWebViewCompletedCallBack)_completedCallback;*/

-(void)setChromeless:(BOOL)hidden;

-(void)clean;

+(void)addURLInHistory:(NSString *)manual_url;
-(void)manualAddURLInHistory:(NSString *)manual_url;
-(void)addURLInOtherHistory:(NSString *)manual_url;

- (void)initialRequestDidReceiveResponse:(NSHTTPURLResponse *)response;
- (void)initialRequestDidReceiveData:(NSData *)mydata offset:(NSUInteger)offset total:(NSUInteger)total;
- (void)initialRequestDidFinishLoading;
- (void)initialRequestDidFailWithError:(NSError *)error;

-(id)JSonObjectByEvaluatingJavascriptFromString:(NSString *)js error:(NSError **)error;

-(NSString *)executeJS:(NSString *)js;
-(void)sendJSEvent:(NSString *)name withJsonData:(NSString *)dataJson;
-(void)setBackgroundColor1:(UIColor *)color1 color2:(UIColor *)color2;
-(void)setMaskColor:(UIColor *)color opcacity:(CGFloat)opacity anim:(CGFloat)anim userInteractionEnabled:(BOOL)interaction;
-(void)disableMask;

/*
+(NSData *)dataWithInjectedAppDeckJS:(NSData *)data;
+(BOOL)shouldInjectAppDeckJSInResponse:(NSURLResponse *)response;
+(BOOL)shouldInjectAppDeckJSInData:(NSData *)data;
*/


@property (strong, nonatomic) UIColor *backgroundColor1;
@property (strong, nonatomic) UIColor *backgroundColor2;

@property (nonatomic, weak) IBOutlet id<ManagedUIWebViewDelegate, AppDeckApiCallDelegate> delegate;

@property (nonatomic, weak, readonly) id  browser;
@property (nonatomic, weak, readonly) id  coreWebView;

@property (nonatomic, assign)       BOOL ready;
@property (nonatomic, assign)       float progress;

@property (nonatomic, assign)       BOOL catch_link;
@property (nonatomic, assign)       BOOL enable_api;

@end


