//
//  ViewController.m
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 11/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import "PageViewController.h"
#import "PageAdViewController.h"

#define kNumberOfPages		10
#define kAdPageIndex		4


@implementation PageViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Setting the delegate & the data source.
	self.dataSource = self;
	self.delegate = self;
	
	//Configuring the first page of the page view controller.
    NSArray *viewControllers = @[[self viewControllerAtIndex:0]];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - Page view controller data source

- (IndexedContentViewController *)viewControllerAtIndex:(NSUInteger)index {
	IndexedContentViewController *controller = nil;
	
	// Instanciating the right view controller depending on the index
	if (kAdPageIndex == index) {
		controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PageAdViewController"];
	} else {
		controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
	}
	
	// The current index is stored into the controller for future use and the controller is returned
	controller.index = index;
	return controller;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	// Computing the previous index and returning nil if on first page
    NSUInteger index = ((IndexedContentViewController*) viewController).index;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
	
	// Returning the previous controller.
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	// Computing the next index and returning nil if on last page
    NSUInteger index = ((IndexedContentViewController*) viewController).index;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index >= kNumberOfPages) {
        return nil;
    }
	
	// Returning the next controller
    return [self viewControllerAtIndex:index];
}

#pragma mark - Page view controller delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
	
	// Retrieving the currently displayed controller
	IndexedContentViewController *controller = (IndexedContentViewController *)[pageViewController.viewControllers objectAtIndex:0];
	
	// If the controller is an ad controller the visibility status should be set to YES so that the video can start. The last ad controller being found
	// is stored to put the visibility status back to NO the next time.
	if ([controller isKindOfClass:[PageAdViewController class]]) {
		self.currentAdController = (PageAdViewController *)controller;
		self.currentAdController.visibleInPageViewController = YES;
	} else {
		self.currentAdController.visibleInPageViewController = NO;
		self.currentAdController = nil;
	}
}

@end
