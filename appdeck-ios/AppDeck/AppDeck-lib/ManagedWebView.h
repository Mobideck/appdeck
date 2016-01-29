//
//  ManagedWebView.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/01/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDeckApiCall.h"

@class ManagedWebView;

typedef void ( ^ManagedWebViewProgressCallBack )( float progress ) ;
typedef void ( ^ManagedWebViewCompletedCallBack )( NSError *error ) ;

@protocol ManagedWebViewDelegate <NSObject>

- (BOOL)managedWebView:(ManagedWebView *)managedWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@optional
- (NSString *)managedWebView:(ManagedWebView *)managedWebView runPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(id)frame;


@end

@interface ManagedWebView : UIViewController <AppDeckApiCallDelegate>
{
    UIView  *mask;
    
    BOOL dead;
    
    ManagedWebViewProgressCallBack progressCallback;
    ManagedWebViewCompletedCallBack completedCallback;

}

+(ManagedWebView *)createManagedWebView;

-(void)setChromeless:(BOOL)hidden;
-(void)setBackgroundColor1:(UIColor *)color1 color2:(UIColor *)color2;

-(void)loadRequest:(NSURLRequest *)request progess:(ManagedWebViewProgressCallBack)progressCallback completed:(ManagedWebViewCompletedCallBack)completedCallback;
-(void)loadHTMLString:(NSString *)html baseRequest:(NSURLRequest *)_request progess:(ManagedWebViewProgressCallBack)_progressCallback completed:(ManagedWebViewCompletedCallBack)_completedCallback;

-(void)setMaskColor:(UIColor *)color opcacity:(CGFloat)opacity anim:(CGFloat)anim userInteractionEnabled:(BOOL)interaction;
-(void)disableMask;


- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler;

//- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

-(void)executeJS:(NSString *)js;

-(void)sendJSEvent:(NSString *)name withJsonData:(NSString *)dataJson;


/* history API */
+(void)addURLInHistory:(NSString *)manual_url;
-(void)manualAddURLInHistory:(NSString *)manual_url;
-(void)addURLInOtherHistory:(NSString *)manual_url;


-(void)clean;

/* webview API */
-(BOOL)canGoBack;
-(BOOL)canGoForward;
-(BOOL)isLoading;
-(void)goBack;
-(void)goForward;
-(void)stopLoading;

@property (strong, nonatomic) NSMutableURLRequest *currentRequest;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (strong, nonatomic) UIView *webView;

@property (nonatomic, weak) id<ManagedWebViewDelegate, AppDeckApiCallDelegate> delegate;

@property (nonatomic, assign)       BOOL catch_link;
@property (nonatomic, assign)       BOOL enable_api;

@end
