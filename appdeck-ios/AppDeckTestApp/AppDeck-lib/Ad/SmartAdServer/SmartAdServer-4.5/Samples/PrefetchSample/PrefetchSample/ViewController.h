//
//  ViewController.h
//  Prefetch
//
//  Created by Julien Stoeffler on 14/03/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASAdView.h"


@class SASBannerView, SASInterstitialView;
@interface ViewController : UIViewController <SASAdViewDelegate> {
    BOOL _statusBarHidden;
}

@property (nonatomic, retain) SASInterstitialView *prefetchedStartupInterstitial;
@property (nonatomic, retain) SASBannerView *banner;

- (void)loadBanner;
- (void)loadInterstitial;

@end
