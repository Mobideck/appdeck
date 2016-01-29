//
//  ManagedWKWebViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/01/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import "ManagedWebView.h"
@import WebKit;

@interface ManagedWKWebViewController : ManagedWebView <WKNavigationDelegate, WKUIDelegate>
{
    WKNavigation *currentNavigation;
    
    BOOL first;
    
    float loadingProgress;
}
@property (strong, nonatomic) WKWebView *webView;

@end
