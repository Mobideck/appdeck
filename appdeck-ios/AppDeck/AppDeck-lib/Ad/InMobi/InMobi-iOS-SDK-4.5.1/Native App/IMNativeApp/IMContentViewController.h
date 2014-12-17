//
//  IMWebViewController.h
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMContentViewController : UIViewController

@property (nonatomic, strong) UIWebView* webview;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* headerTitle;

@end
