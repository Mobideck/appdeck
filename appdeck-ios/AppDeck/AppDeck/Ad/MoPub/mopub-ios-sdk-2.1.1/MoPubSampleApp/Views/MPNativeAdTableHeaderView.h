//
//  MPNativeAdTableHeaderView.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPNativeAdTableHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
