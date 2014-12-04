//
//  IMWebViewController.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import "IMContentViewController.h"

@interface IMContentViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIActivityIndicatorView* activityView;
@end

@implementation IMContentViewController

-(id)initWithUrl:(NSString*)url {
    if (self=[super init]) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if (self.headerTitle) {
        self.navigationItem.title = self.headerTitle;
    }
    else
        self.navigationItem.title = @"Content";
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURL* urlToLoad = [NSURL URLWithString:self.url];
    [self.webview loadRequest:[NSURLRequest requestWithURL:urlToLoad]];
    self.webview.delegate = self;
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView.frame = self.view.frame;
    [self.view addSubview:self.activityView];
    [self.activityView startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.view addSubview:self.webview];
    [self.activityView stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityView stopAnimating];
}

@end
