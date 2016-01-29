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
#import "ManagedWebView.h"

@class ManagedUIWebViewController;
@class WebViewModuleViewController;

/*
@protocol ManagedUIWebViewDelegate <NSObject>

@optional
- (NSString *)webView:(UIWebView *)webView runPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame;

@end*/


@interface ManagedUIWebViewController : ManagedWebView <UIWebViewDelegate, CustomUIWebViewProgressDelegate>
{
    
    NSMutableArray *me;
    
    NSTimer *webViewTimer;
    
    float loadingProgress;
    
    
    float       completedDelay;
    NSInteger   webViewLoadCount;
    
    dispatch_queue_t backgroundQueue;
    
    BOOL    first;

//    NSMutableURLRequest *currentRequest;
    
    BOOL showProgress;


    
    NSString *appdeckapijs;
//    UIView  *bottomView;
    

    
    // modules
    WebViewModuleViewController *viewController;
    
    NSMutableArray *modules;
    
    NSMutableArray *frames;
    NSString *urlForNextFrameRequest;
    
    NSDate  *webviewProgressFinish;
}

@property (strong, nonatomic) CustomUIWebView *webView;


/*-(void)loadRequest:(NSURLRequest *)_request withCachedResponse:(NSCachedURLResponse*)cachedResponse progess:(ManagedUIWebViewProgressCallBack)_progressCallback completed:(ManagedUIWebViewCompletedCallBack)_completedCallback;*/


- (void)initialRequestDidReceiveResponse:(NSHTTPURLResponse *)response;
- (void)initialRequestDidReceiveData:(NSData *)mydata offset:(NSUInteger)offset total:(NSUInteger)total;
- (void)initialRequestDidFinishLoading;
- (void)initialRequestDidFailWithError:(NSError *)error;

-(id)JSonObjectByEvaluatingJavascriptFromString:(NSString *)js error:(NSError **)error;



/*
+(NSData *)dataWithInjectedAppDeckJS:(NSData *)data;
+(BOOL)shouldInjectAppDeckJSInResponse:(NSURLResponse *)response;
+(BOOL)shouldInjectAppDeckJSInData:(NSData *)data;
*/


@property (strong, nonatomic) UIColor *backgroundColor1;
@property (strong, nonatomic) UIColor *backgroundColor2;

@property (nonatomic, weak) id<ManagedWebViewDelegate, AppDeckApiCallDelegate> delegate;

//@property (nonatomic, weak) id<MManagedUIWebViewDelegate> webViewDelegate;

@property (nonatomic, weak, readonly) id  browser;
@property (nonatomic, weak, readonly) id  coreWebView;

@property (nonatomic, assign)       BOOL ready;
@property (nonatomic, assign)       float progress;


@end


