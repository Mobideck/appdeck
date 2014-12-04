//
//  IMNewsViewController.h
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMNativeDelegate.h"
#import "IMBaseViewController.h"

@interface IMNewsViewController : IMBaseViewController <UITableViewDataSource, UITableViewDelegate, IMNativeDelegate>

@property NSUInteger numRowsInTableView;
@property (nonatomic , strong) UITableView* newsTableView;

-(void)reloadData;
-(void)attachNativeAdToView:(UIView*)view; //NEED TO BE OVERRIDDEN BY SUBCLASSES. THIS WILL WORK WITH ITS ORIGINAL IMPLEMENTATION IN THE BASE CLASS ONLY

@end
