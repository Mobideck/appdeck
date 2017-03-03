//
//  FakeMPWebView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPWebView.h"
#import "UIWebView+Spec.h"
#import "MPHTMLInterstitialViewController.h"

@implementation FakeMPWebView

// As an interstitial/banner
- (void)simulateLoadingAd
{
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"mopub://finishLoad"]]];
}

- (void)simulateFailingToLoad
{
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"mopub://failLoad"]]];
}

// As a banner
- (MPAdWebViewAgent *)agent {
    MPAdWebViewAgent *agent = (MPAdWebViewAgent *)self.delegate;
    return agent;
}
- (void)simulateUserBringingUpModal
{
    [self.agent displayAgentWillPresentModal];
}

- (void)simulateUserDismissingModal
{
    [self.agent displayAgentDidDismissModal];
}

- (void)simulateUserLeavingApplication
{
    [self.agent displayAgentWillLeaveApplication];
}

// As an interstitial
- (BOOL)didAppear
{
    // return [[self executedJavaScripts] indexOfObject:@"webviewDidAppear();"] != NSNotFound;
    return YES;
}

- (void)simulateUserDismissingAd
{
    [self.interstitialController.closeButton tap];
}

- (UIViewController *)presentingViewController
{
    return self.interstitialController.presentingViewController;
}

- (MPHTMLInterstitialViewController *)interstitialController
{
    //Ugly hack...
    return [self.delegate performSelector:@selector(delegate)];
}

@end
