//
//  MenuViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 24/02/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedUIWebViewController.h"

@class LoaderViewController;

typedef enum {
    MenuAlignLeft,
    MenuAlignRight
} MenuAlign;

@interface MenuViewController : UIViewController <ManagedUIWebViewDelegate, AppDeckApiCallDelegate>
{
//    UIWebView *webView;
    
    UIView *fakeStatusBar;
    
    ManagedUIWebViewController *content;
    UIView                      *container;
    CGFloat                     width;
    MenuAlign                   align;
    
    BOOL hasReload;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url content:(UIWebView *)content header:(UIWebView *)headerOrNil footer:(UIWebView *)footerOrNil loader:(LoaderViewController *)loader width:(CGFloat)width align:(MenuAlign)align;

-(void)reload;

-(void)isMain:(BOOL)isMain;

-(NSString *)executeJS:(NSString *)js;

@property (strong, nonatomic) NSURL *url;

@property (nonatomic)     LoaderViewController *loader;

@property (strong, nonatomic) UIColor *backgroundColor1;
@property (strong, nonatomic) UIColor *backgroundColor2;

@end
