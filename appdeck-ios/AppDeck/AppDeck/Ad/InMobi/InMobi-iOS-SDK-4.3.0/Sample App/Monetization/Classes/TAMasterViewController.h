//
//  TAMasterViewController.h
//  Test Application
//
//  Copyright (c) 2012 InMobi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TADetailViewController;

@interface TAMasterViewController : UITableViewController

@property (strong, nonatomic) TADetailViewController *detailViewController;

@end
