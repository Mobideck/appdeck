//
//  MPHTMLInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPHTMLInterstitialViewControllerMF.h"
#import "MPAdWebViewMF.h"
#import "MPAdDestinationDisplayAgentMF.h"
#import "MPInstanceProviderMF.h"

@interface MPHTMLInterstitialViewControllerMF ()

@property (nonatomic, retain) MPAdWebViewMF *backingView;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPHTMLInterstitialViewControllerMF

@synthesize delegate = _delegate;
@synthesize backingViewAgent = _backingViewAgent;
@synthesize customMethodDelegate = _customMethodDelegate;
@synthesize backingView = _backingView;

- (void)dealloc
{
    self.backingViewAgent.delegate = nil;
    self.backingViewAgent.customMethodDelegate = nil;
    self.backingViewAgent = nil;

    self.backingView.delegate = nil;
    self.backingView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.backingViewAgent = [[MPInstanceProviderMF sharedProvider] buildMPAdWebViewAgentWithAdWebViewFrame:self.view.bounds
                                                                                                delegate:self
                                                                                    customMethodDelegate:self.customMethodDelegate];
    self.backingView = self.backingViewAgent.view;
    self.backingView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backingView];
}

#pragma mark - Public

- (void)loadConfiguration:(MPAdConfigurationMF *)configuration
{
    [self view];
    [self.backingViewAgent loadConfiguration:configuration];
}

- (void)willPresentInterstitial
{
    self.backingView.alpha = 0.0;
    [self.delegate interstitialWillAppear:self];
}

- (void)didPresentInterstitial
{
    [self.backingViewAgent continueHandlingRequests];
    [self.backingViewAgent invokeJavaScriptForEvent:MPAdWebViewEventAdDidAppear];

    // XXX: In certain cases, UIWebView's content appears off-center due to rotation / auto-
    // resizing while off-screen. -forceRedraw corrects this issue, but there is always a brief
    // instant when the old content is visible. We mask this using a short fade animation.
    [self.backingViewAgent forceRedraw];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.backingView.alpha = 1.0;
    [UIView commitAnimations];

    [self.delegate interstitialDidAppear:self];
}

- (void)willDismissInterstitial
{
    [self.backingViewAgent stopHandlingRequests];
    [self.delegate interstitialWillDisappear:self];
}

- (void)didDismissInterstitial
{
    [self.backingViewAgent invokeJavaScriptForEvent:MPAdWebViewEventAdDidDisappear];
    [self.delegate interstitialDidDisappear:self];
}

#pragma mark - Autorotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.backingViewAgent rotateToOrientation:self.interfaceOrientation];
}

#pragma mark - MPAdWebViewAgentDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adDidFinishLoadingAd:(MPAdWebViewMF *)ad
{
    [self.delegate interstitialDidLoadAd:self];
}

- (void)adDidFailToLoadAd:(MPAdWebViewMF *)ad
{
    [self.delegate interstitialDidFailToLoadAd:self];
}

- (void)adActionWillBegin:(MPAdWebViewMF *)ad
{
    // No need to tell anyone.
}

- (void)adActionWillLeaveApplication:(MPAdWebViewMF *)ad
{
    [self.delegate interstitialWillLeaveApplication:self];
    [self dismissInterstitialAnimated:NO];
}

- (void)adActionDidFinish:(MPAdWebViewMF *)ad
{
    //NOOP: the landing page is going away, but not the interstitial.
}

- (void)adDidClose:(MPAdWebViewMF *)ad
{
    //NOOP: the ad is going away, but not the interstitial.
}

@end
