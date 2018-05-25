//
//  myCell.h
//  AppDeck
//
//  Created by hanine ben saad on 24/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCustomTableViewController.h"

@class GradientView;

@protocol celldelegate <NSObject>

@end

@interface myCell : UITableViewCell{
    
    CAGradientLayer * bgGradientLayer;
    
}

@property (weak, nonatomic) IBOutlet UIImageView*imageView;
@property (nonatomic, retain) NSDictionary*dataa;
@property (nonatomic, retain) NSDictionary*globalData;
@property (weak, nonatomic) IBOutlet GradientView*paddingView;
@property (weak, nonatomic) IBOutlet UIView*containerView;
@property (nonatomic, retain) NSURL*relativeUrl;
@property (weak, nonatomic) IBOutlet UILabel*titleLabel;
@property (weak, nonatomic) IBOutlet UILabel*dateLabel;
@property (nonatomic, retain) MyCustomTableViewController*delegate;

@end
