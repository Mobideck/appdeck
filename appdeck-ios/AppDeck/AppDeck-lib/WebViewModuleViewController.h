//
//  WebViewModuleViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 19/06/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDeckApiCall.h"

@interface WebViewModuleViewController : UIViewController
{
    UIView *container;
    
    UIViewController *childViewController;
    
    UIView *redView;
    UIView *greenView;
    UIView *blueView;
    UIView *blackView;
    
    BOOL childReady;
}

@property (nonatomic, weak) UIWebView *webview;
@property (nonatomic, retain) AppDeckApiCall *apicall;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ChildViewController:(UIViewController *)_childViewController  apiCall:(AppDeckApiCall *)call;

@end
