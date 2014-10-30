//
//  WebViewFactory.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 30/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "CustomWebViewFactory.h"


@implementation CustomWebViewFactory

-(id)init
{
    self = [super init];
    
    if (self)
    {
        webViews = [[NSMutableArray alloc] init];
        webViewsToDelete = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)realAddReusableWebView:(NSTimer *)timer
{
    [webViewsToDelete removeObject:timer.userInfo];
    //[webViews addObject:timer.userInfo];
}

-(void)addReusableWebView:(UIWebView *)webView
{
    webView.delegate = nil;
    webView.scrollView.delegate = nil;
    [webView loadHTMLString:@"" baseURL:nil];
    [webView stopLoading];
    [webViewsToDelete addObject:webView];
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(realAddReusableWebView:) userInfo:webView repeats:NO];
}

-(CustomUIWebView *)getReusableWebView
{
    if ([webViews count] != 0)
    {
        CustomUIWebView *webView = [webViews objectAtIndex:0];
        if (webView != nil)
        {
            [webViews removeObjectAtIndex:0];
            NSLog(@"reuse webview %p", webView);
            return webView;
        }
    }
    return [(CustomUIWebView *)[UIWebView alloc] init];
}

@end
