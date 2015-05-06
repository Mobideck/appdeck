//
//  PageContentViewController.m
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 17/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import "PageContentViewController.h"


@implementation PageContentViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	//Setting the title of the content controller (you should put your own views here).
	[self.titleLabel setText:[NSString stringWithFormat:@"Page %ld", (long)self.index]];
}

@end
