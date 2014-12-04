//
//  PageContentViewController.h
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 17/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexedContentViewController.h"


@interface PageContentViewController : IndexedContentViewController

//Title of the content controller
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
