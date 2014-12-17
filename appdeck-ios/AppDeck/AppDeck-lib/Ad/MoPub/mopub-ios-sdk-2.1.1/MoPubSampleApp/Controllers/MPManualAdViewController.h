//
//  MPManualAdViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPInterstitialAdController.h"
#import "MPAdView.h"

@interface MPManualAdViewController : UIViewController <MPAdViewDelegate, MPInterstitialAdControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstInterstitialTextField;
@property (weak, nonatomic) IBOutlet UIButton *firstInterstitialLoadButton;
@property (weak, nonatomic) IBOutlet UIButton *firstInterstitialShowButton;
@property (weak, nonatomic) IBOutlet UILabel *firstInterstitialStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *firstInterstitialActivityIndicator;

@property (weak, nonatomic) IBOutlet UITextField *secondInterstitialTextField;
@property (weak, nonatomic) IBOutlet UIButton *secondInterstitialLoadButton;
@property (weak, nonatomic) IBOutlet UIButton *secondInterstitialShowButton;
@property (weak, nonatomic) IBOutlet UILabel *secondInterstitialStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *secondInterstitialActivityIndicator;

@property (weak, nonatomic) IBOutlet UITextField *bannerTextField;
@property (weak, nonatomic) IBOutlet UIButton *bannerLoadButton;
@property (weak, nonatomic) IBOutlet UIButton *bannerMRectLoadButton;
@property (weak, nonatomic) IBOutlet UILabel *bannerStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *bannerContainer;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
