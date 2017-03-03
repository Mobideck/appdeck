//
//  MPRewardedVideoAdDetailViewController.h
//  MoPubSampleApp
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPAdInfo;

@interface MPRewardedVideoAdDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;
@property (weak, nonatomic) IBOutlet UILabel *expireLabel;
@property (weak, nonatomic) IBOutlet UILabel *willAppearLabel;
@property (weak, nonatomic) IBOutlet UILabel *didAppearLabel;
@property (weak, nonatomic) IBOutlet UILabel *willDisappearLabel;
@property (weak, nonatomic) IBOutlet UILabel *didDisappearLabel;
@property (weak, nonatomic) IBOutlet UILabel *didReceiveTapLabel;
@property (weak, nonatomic) IBOutlet UILabel *shouldRewardLabel;

- (id)initWithAdInfo:(MPAdInfo *)adInfo;

@end
