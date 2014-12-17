//
//  UIView+forceSetScrollTop.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 29/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIView+forceSetScrollTop.h"

@implementation UIView (forceSetScrollTop)

-(void)forceSetScrollTop:(BOOL)scrollToTop
{
    if ([self isKindOfClass:[UIWebView class]])
    {
        UIWebView *webView = (UIWebView *)self;
        webView.scrollView.scrollsToTop = scrollToTop;
    }
    if ([self isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scroll = (UIScrollView *)self;
        scroll.scrollsToTop = scrollToTop;
    }
    for (UIView* subView in [self subviews])
    {
        [subView forceSetScrollTop:scrollToTop];
    }
}

@end
