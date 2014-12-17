//
//  IndexedContentViewController.h
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 17/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IndexedContentViewController : UIViewController

//The index is used by the page view controller data source to retrieve the correct page.
@property (nonatomic) NSInteger index;

@end
