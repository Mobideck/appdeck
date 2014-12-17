//
//  PageAdViewController.h
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 17/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexedContentViewController.h"
#import "SASBannerView.h"


@interface PageAdViewController : IndexedContentViewController <SASAdViewDelegate>

@property (strong, nonatomic) SASBannerView *banner;
@property (nonatomic, getter = isVisibleInPageViewController) BOOL visibleInPageViewController;

@end
