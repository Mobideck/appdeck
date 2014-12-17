//
//  RootViewController.h
//  Sample
//
//  Created by Julien Stoeffler on 07/07/11.
//  Copyright 2011 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASAdViewDelegate.h"

@class SASBannerView;
@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SASAdViewDelegate> {
	BOOL _statusBarHidden;
	BOOL _isToaster;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) SASBannerView *topBanner;

- (void)displayTopBanner;

@end
