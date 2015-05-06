//
//  ViewController.h
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 11/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"


@class PageAdViewController;
@interface PageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

//Used to temporary store the current ad controller in order to set its visibility status.
@property (strong, nonatomic) PageAdViewController *currentAdController;

@end
