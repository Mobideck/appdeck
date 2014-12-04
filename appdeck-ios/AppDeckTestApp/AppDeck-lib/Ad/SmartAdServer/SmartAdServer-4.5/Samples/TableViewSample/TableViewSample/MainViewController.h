//
//  ViewController.h
//  TableViewSample
//
//  Created by Loïc GIRON DIT METAZ on 08/07/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASAdView.h"


@class SASBannerView;
@interface MainViewController : UITableViewController <SASAdViewDelegate>

@property (nonatomic, retain) SASBannerView *headerCellBanner;
@property (nonatomic, retain) SASBannerView *contentCellBanner;
@property (nonatomic, retain) SASBannerView *footerCellBanner;

@end
