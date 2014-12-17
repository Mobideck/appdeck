//
//  TADetailViewController.h
//  Test Application
//
//  Copyright (c) 2012 InMobi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InMobi.h"
#import "IMBanner.h"
#import "IMBannerDelegate.h"
#import "IMInterstitial.h"
#import "IMInterstitialDelegate.h"

@interface TADetailViewController : UIViewController <UISplitViewControllerDelegate,IMBannerDelegate,IMInterstitialDelegate> {
    IMBanner *adView;
    IMInterstitial *adInterstitial;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UIView *statusView;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
