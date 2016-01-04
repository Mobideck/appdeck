//
//  FakeBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "HTMLChunkAdViewController.h"
#import "../../AdManager.h"
#import "../../AdRation.h"
#import "../../AdScenario.h"
#import "../../AdPlacement.h"
#import "../../LoaderViewController.h"
#import "../../AppDeck.h"
#import "../../LoaderConfiguration.h"
#import <QuartzCore/QuartzCore.h>

@interface HTMLChunkAdViewController ()

@end

@implementation HTMLChunkAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(HTMLChunkAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
        self.code = [config objectForKey:@"code"];
        self.passbackable = [config objectForKey:@"passbackable"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.width = self.adRation.formatWidth;
    self.height = self.adRation.formatHeight;
    
    if ([self.adType isEqualToString:@"interstitial"])
    {
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    // init managed webview
    contentCtl = [[ManagedUIWebViewController alloc] initWithNibName:nil bundle:nil];
    contentCtl.delegate = self;
    [self.view addSubview:contentCtl.view];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.adRation.adRequest.page.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><style> html, body { height:100%%; width:100%%; margin:0; border:0; padding:0; }</style></head><body>%@</body></html>", self.code];
    
    [contentCtl loadHTMLString:html baseRequest:request progess:^(float progress) {
        if (progress == 0)
            self.state = AppDeckAdStateLoad;
    } completed:^(NSError *error) {
        if (error != nil)
            self.state = AppDeckAdStateFailed;
        else
            self.state = AppDeckAdStateReady;
    }];
    
    close = [[UIImageView alloc] initWithImage:self.adManager.loader.conf.icon_close.image];
    close.frame = CGRectMake(0, 0, 16, 16);
    if (self.adManager.loader.conf.icon_theme == IconThemeDark)
        close.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    else
        close.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    close.layer.cornerRadius = close.frame.size.width / 2;
    close.clipsToBounds = YES;
    [self.view addSubview:close];
    
    // attach gesture recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adClose:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [close addGestureRecognizer:singleTap];
    [close setUserInteractionEnabled:YES];
    
}

-(void)cancel
{
    if (timer)
        [timer invalidate];
    timer = nil;
}

-(void)adClose:(id)sender
{
    [timer invalidate];
    timer = nil;
    
    self.state = AppDeckAdStateClose;
}

#pragma mark - click
- (BOOL)managedUIWebViewController:(ManagedUIWebViewController *)managedUIWebViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self.adManager handleActionURL:request.URL.absoluteString withTarget:nil];
    return NO;
}



#pragma mark - discard

-(void)viewDidLayoutSubviews
{
    contentCtl.view.frame = self.view.bounds;
    
    CGRect frame = CGRectMake(self.view.frame.size.width  - close.frame.size.width,
                             0,
                             close.frame.size.width, close.frame.size.height);
    close.frame = frame;
    [self.view bringSubviewToFront:close];
}

-(void)adWillLoadInViewController:(LoaderChildViewController *)ctl
{
    if ([self.adType isEqualToString:@"interstitial"])
        timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(adClose:) userInfo:nil repeats:NO];
}

@end
