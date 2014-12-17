//
//  WebViewFactory.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 30/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomUIWebView.h"

@interface CustomWebViewFactory : NSObject
{
    NSMutableArray  *webViews;
    NSMutableArray  *webViewsToDelete;
}

-(void)addReusableWebView:(UIWebView *)webView;

-(CustomUIWebView *)getReusableWebView;

@end
