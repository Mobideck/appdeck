//
//  ManagedWebView.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/01/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import "ManagedWebView.h"
#import "ManagedUIWebViewController.h"
#import "ManagedWKWebViewController.h"
#import "AppDeck.h"
#import "LoaderViewController.h"

@implementation ManagedWebView
{
    UIView  *topView;
}

+(ManagedWebView *)createManagedWebView;
{
    //return [[ManagedWKWebViewController alloc] initWithNibName:nil bundle:nil];
    return [[ManagedUIWebViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.catch_link = YES;
    self.enable_api = YES;

}

-(void)disableMask
{
    if (mask)
    {
        [mask removeFromSuperview];
        mask = nil;
    }
}

-(void)setMaskColor:(UIColor *)color opcacity:(CGFloat)opacity anim:(CGFloat)anim userInteractionEnabled:(BOOL)interaction
{
    mask = [[UIView alloc] initWithFrame:self.view.bounds];
    [mask setBackgroundColor:[color colorWithAlphaComponent:opacity]];
    mask.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    mask.userInteractionEnabled = !interaction;
    [self.view addSubview:mask];
    mask.alpha = 0;
    [UIView animateWithDuration:anim animations:^(){
        mask.alpha = 1.0;
    }];
}

-(void)setChromeless:(BOOL)hidden
{
    
}

-(void)setBackgroundColor1:(UIColor *)color1 color2:(UIColor *)color2
{
    if (color1 == nil)
        color1 = [UIColor whiteColor];
    
    topView.backgroundColor = color1;
    
    //    self.webView.backgroundColor = [UIColor colorWithGradientHeight:self.view.bounds.size.height startColor:color1 endColor:color2];
    //self.webView.backgroundColor = [UIColor colorWithGradientHeight:self.webView.bounds.size.height startColor:topView.backgroundColor endColor:self.view.backgroundColor];
    self.view.backgroundColor = color2;
    
    [self viewWillLayoutSubviews];
}


-(void)setScrollView:(UIScrollView *)scrollView
{
    if (topView)
    {
        [topView removeFromSuperview];
        topView = nil;
    }
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)];
    topView.backgroundColor = [UIColor clearColor];
    
    [scrollView addSubview:topView];
    
}

-(void)executeJS:(NSString *)js
{
    [self evaluateJavaScript:js completionHandler:nil];
}

- (BOOL) apiCall:(AppDeckApiCall *)call
{
    call.managedWebView = self;
    call.baseURL = self.currentRequest.URL;
    
    BOOL ret;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(apiCall:)])
        ret = [self.delegate apiCall:call];
    else
        ret = [[AppDeck sharedInstance].loader apiCall:call];
    
    if (ret)
        return ret;
    
    if ([call.command isEqualToString:@"disable_catch_link"])
    {
        NSString *value = [NSString stringWithFormat:@"%@", call.param];
        
        if ([value isEqualToString:@"1"] || [value isEqualToString:@"true"])
            self.catch_link = NO;
        else if ([value isEqualToString:@"0"] || [value isEqualToString:@"false"])
            self.catch_link = YES;
        if (glLog)
            [glLog debug:@"catch link is %@", (self.catch_link ? @"enabled" : @"disabled")];
        return YES;
    }
    /*
     if ([call.command isEqualToString:@"webviewmobule"])
     {
     NSString *name = [call.param objectForKey:@"name"];
     NSDictionary *options = [call.param objectForKey:@"options"];
     
     if ([name isEqualToString:@"carousel"])
     {
     //iCarouselExampleViewController *child = [[iCarouselExampleViewController alloc] init];
     iCarouselWebViewModuleViewController *child = [[iCarouselWebViewModuleViewController alloc] initWithNibName:nil bundle:nil];
     child.apicall = call;
     child.name = name;
     child.options = options;
     
     viewController = [[WebViewModuleViewController alloc] initWithNibName:nil bundle:nil ChildViewController:child apiCall:call];
     //viewController.view.frame = CGRectMake(50, 50, 200, 300);
     viewController.webview = self.webView;
     
     [modules addObject:viewController];
     
     [self addChildViewController:viewController];
     [self.webView.scrollView addSubview:viewController.view];
     }
     return YES;
     }*/
    /*    if ([call.command isEqualToString:@"DOMLoad"])
     {
     if (webViewTimer)
     {
     [webViewTimer invalidate];
     //[self syncCache];
     [self updateProgress:100];
     [self completed:nil];
     webViewTimer = nil;
     }
     return YES;
     }*/
    
    /*
     if ([call.command isEqualToString:@"DOMContentLoaded"])
     {
     [webViewTimer invalidate];
     //[self syncCache];
     [self updateProgress:100];
     [self completed:nil];
     webViewTimer = nil;
     
     return YES;
     }*/
    
    return NO;
}

#pragma mark - Rotate

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.webView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    topView.frame = CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);

}

-(void)clean
{
    dead = YES;
    if (topView)
    {
        [topView removeFromSuperview];
        topView = nil;
    }
    //    bottomView = nil;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    progressCallback = nil;
    completedCallback = nil;
}

@end
