//
//  SwipeViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDeckApiCall.h"
#import "AppDeckProgressHUD.h"

@class LoaderChildViewController;

@interface SwipeViewController : UIViewController <UIScrollViewDelegate, MBProgressHUDDelegate, AppDeckApiCallDelegate, UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *panGesture;
    NSTimeInterval          panDuration;

}

//@property (nonatomic, strong)   UIScrollView    *scrollView;

@property (nonatomic, strong)               LoaderChildViewController   *next;
@property (nonatomic, strong)               LoaderChildViewController   *previous;
@property (nonatomic, strong)               LoaderChildViewController   *current;

@property (nonatomic, assign)               BOOL    swipeEnabled;

-(void)child:(LoaderChildViewController *)childViewController startProgressWithExpectedProgress:(float)expectedProgress inTime:(float)secconds;
-(void)child:(LoaderChildViewController *)childViewController updateProgressWithProgress:(float)progress duration:(float)duration;
-(void)child:(LoaderChildViewController *)childViewController endProgressDuration:(float)secconds;

-(void)reload;

-(void)insertNextChildView;
-(void)insertPreviousChildView;

-(void)gotoPrevious:(CGFloat)velocity;
-(void)gotoNext:(CGFloat)velocity;
-(void)gotoCurrent:(CGFloat)velocity;

-(BOOL)apiCall:(AppDeckApiCall *)call;

-(void)adjustFullScreen;

@end
