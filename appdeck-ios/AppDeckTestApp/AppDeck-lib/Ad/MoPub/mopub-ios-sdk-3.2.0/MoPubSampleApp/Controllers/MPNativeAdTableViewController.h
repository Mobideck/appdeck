//
//  MPNativeAdTableViewController.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MPAdInfo;

extern NSString *const kNativeAdTableViewAccessibilityLabel;
extern NSString *const kDefaultCellIdentifier;
extern NSInteger const kRowForAdCell;

@interface MPNativeAdTableViewController : UITableViewController

- (id)initWithAdInfo:(MPAdInfo *)info;

@end
