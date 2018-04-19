//
//  CustomECSlidingViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 28/11/2015.
//  Copyright © 2015 Mathieu De Kermadec. All rights reserved.
//

#import "CustomECSlidingViewController.h"

#import "LoaderViewController.h"

NSString *const ECSlidingViewUnderRightWillAppear    = @"ECSlidingViewUnderRightWillAppear";
NSString *const ECSlidingViewUnderLeftWillAppear     = @"ECSlidingViewUnderLeftWillAppear";
NSString *const ECSlidingViewUnderLeftWillDisappear  = @"ECSlidingViewUnderLeftWillDisappear";
NSString *const ECSlidingViewUnderRightWillDisappear = @"ECSlidingViewUnderRightWillDisappear";
NSString *const ECSlidingViewTopDidAnchorLeft        = @"ECSlidingViewTopDidAnchorLeft";
NSString *const ECSlidingViewTopDidAnchorRight       = @"ECSlidingViewTopDidAnchorRight";
NSString *const ECSlidingViewTopWillReset            = @"ECSlidingViewTopWillReset";
NSString *const ECSlidingViewTopDidReset             = @"ECSlidingViewTopDidReset";

@interface CustomECSlidingViewController ()

@end

@implementation CustomECSlidingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    shouldSendNotification = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [super updateInteractiveTransition:percentComplete];

    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered)
    {
        //NSLog(@"from center to border: %f", percentComplete);
        [self.loader topViewCenterMoved:percentComplete];
    }
    else
    {
        //NSLog(@"from border to center: %f", percentComplete);
        [self.loader topViewCenterMoved:(1 - percentComplete)];
    }
    
    if (shouldSendNotification)
    {
        shouldSendNotification = NO;
        
        if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight)
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderRightWillDisappear object:self userInfo:nil];
            });
        if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft)
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderLeftWillDisappear object:self userInfo:nil];
            });
        
    }
    
//    if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered)
/*    if (self.loader != nil)
    {
        if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered)
            [self.loader topViewCenterMoved:(1 - percentComplete)];
        else
            [self.loader topViewCenterMoved:percentComplete];
    }*/
}

- (void)completeTransition:(BOOL)didComplete
{
    [super completeTransition:didComplete];

    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered)
    {
        [self.loader topViewCenterMoved:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewUnderRightWillAppear object:self userInfo:nil];
        });
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuClosed object:nil];
    } else {
        [self.loader topViewCenterMoved:1];
    }
    
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight)
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopDidAnchorRight object:self userInfo:nil];
        });
    
    if (self.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredLeft)
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ECSlidingViewTopDidAnchorLeft object:self userInfo:nil];
        });
    
    shouldSendNotification = YES;
}

@end
