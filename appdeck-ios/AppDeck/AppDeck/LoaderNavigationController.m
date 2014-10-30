//
//  LoaderNavigationController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 07/01/2014.
//  Copyright (c) 2014 Mathieu De Kermadec. All rights reserved.
//

#import "LoaderNavigationController.h"
#import "LoaderViewController.h"

@interface LoaderNavigationController ()

@end

@implementation LoaderNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return [self.loader prefersStatusBarHidden];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.loader preferredStatusBarStyle];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.isAnimating = animated;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.isAnimating = NO;
/*    NSLog(@"didShowViewController:%@", viewController);
    
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = nil;
    }*/
}

@end
