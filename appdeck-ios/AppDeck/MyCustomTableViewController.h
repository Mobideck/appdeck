//
//  MyCustomTableViewController.h
//  AppDeck
//
//  Created by hanine ben saad on 21/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderChildViewController.h"


@interface MyCustomTableViewController : LoaderChildViewController <UITableViewDelegate, UITableViewDataSource>


@property(nonatomic, retain) UITableView*tableview;
@property(nonatomic, retain) NSURL*url;
@property (nonatomic, strong) AppDeckApiCall *origin;
@end
