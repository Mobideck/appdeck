//
//  MPHTMLInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPAdWebViewAgentMF.h"
#import "MPInterstitialViewControllerMF.h"

@class MPAdConfigurationMF;

@interface MPHTMLInterstitialViewControllerMF : MPInterstitialViewControllerMF <MPAdWebViewAgentDelegateMF>

@property (nonatomic, retain) MPAdWebViewAgentMF *backingViewAgent;
@property (nonatomic, assign) id customMethodDelegate;

- (void)loadConfiguration:(MPAdConfigurationMF *)configuration;

@end
