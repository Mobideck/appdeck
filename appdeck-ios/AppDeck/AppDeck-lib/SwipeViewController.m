//
//  SwipeViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "SwipeViewController.h"
#import "LoaderViewController.h"
#import "LoaderChildViewController.h"
#import "UINavigationBar+Progress.h"
#import "AppDeckApiCall.h"
#import "AppDeckAnalytics.h"
#import "RSTimingFunction.h"
#import <QuartzCore/QuartzCore.h>
#import "LoaderConfiguration.h"
#import "AdManager.h"

@interface SwipeViewController ()
{
    RSTimingFunction *timing;
    RSTimingFunction *timingBounce;
}
@property (nonatomic, assign) CGFloat initialTouchPositionX;
@property (nonatomic, assign) CGFloat initialHorizontalCenter;

@end

@implementation SwipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        timing = [RSTimingFunction timingFunctionWithName:kRSTimingFunctionEaseOut];
        timingBounce = [RSTimingFunction timingFunctionWithName:kRSTimingFunctionEaseOut];
        timingBounce = [RSTimingFunction timingFunctionWithControlPoint1:CGPointMake(0.12, 0.74) controlPoint2:CGPointMake(0.48, 0.96)];
        // http://cubic-bezier.com/#0,.61,.66,.92
        //timing = [RSTimingFunction timingFunctionWithControlPoint1:CGPointMake(0.15, 0.65) controlPoint2:CGPointMake(0.4, 0.9)];
        //timing = [RSTimingFunction timingFunctionWithControlPoint1:CGPointMake(0, 2) controlPoint2:CGPointMake(0.91, 1.19)];
        //timing = [RSTimingFunction timingFunctionWithControlPoint1:CGPointMake(0, 0.85) controlPoint2:CGPointMake(0.3, 1.01)];
        //timing = [RSTimingFunction timingFunctionWithControlPoint1:CGPointMake(0, 2.21) controlPoint2:CGPointMake(1.0, 0.95)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.swipeEnabled = YES;
    
/*    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;*/

    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateSwipeViewHorizontalCenterWithRecognizer:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    panDuration = 0.5;
    /*
    // setup ProgressHUD
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.delegate = self;
    progressHUD.animationType = MBProgressHUDAnimationZoom;
    progressHUD.userInteractionEnabled = NO;
    progressHUD.graceTime = 1.0;
    progressHUD.minShowTime = 0.5;
    progressHUD.mode = MBProgressHUDModeIndeterminate;
    progressHUD.labelText = NSLocalizedString(@"LOADING", nil);
    [self.view addSubview:progressHUD];*/
    
    if (_current)
    {
        [self.view addSubview:_current.view];
        [_current childIsMain:YES];
        [self viewWillLayoutSubviews];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.next = nil;
    self.previous = nil;
    [self viewWillLayoutSubviews];
}

-(void)dealloc
{
    self.next = nil;
    self.previous = nil;
    self.current = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_current.progressStart)
    {
        [self.navigationController.navigationBar progressEnd:0];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
/*    if (_current.progressStart)
    {
        [self.navigationController.navigationBar progressStart:0 inTime:0];
        if (_current.progressIndeterminate == NO)
            [self.navigationController.navigationBar progressUpdate:_current.progress duration:0];
    }
  */  
}

-(void)reload
{
    if (self.previous)
        [self.previous reload];
    if (self.current)
        [self.current reload];
    if (self.next)
        [self.next reload];
}

-(void)removeFromParentViewController
{
}

- (BOOL)prefersStatusBarHidden
{
    return [_current.loader prefersStatusBarHidden];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return [_current.loader preferredStatusBarStyle];
}

#pragma mark - API

-(void)executeJS:(NSString *)js
{
    if (self.previous)
        [self.previous executeJS:js];
    if (self.current)
        [self.current executeJS:js];
    if (self.next)
        [self.next executeJS:js];
}


-(BOOL)apiCall:(AppDeckApiCall *)call
{
    call.container = self;
    
    return [self.current.loader apiCall:call];
}

-(void)setShadowEnabled:(BOOL)enabled toView:(UIView *)targetView
{
    /*        [_previous.view.layer setCornerRadius:5];
     [_previous.view.layer setShadowOffset:CGSizeMake(0, 20)];
     [_previous.view.layer setShadowColor:[[UIColor blackColor] CGColor]];
     [_previous.view.layer setShadowRadius:20.0];
     [_previous.view.layer setShadowOpacity:1];*/
    //_next.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:_next.view.bounds].CGPath;
    
    if (enabled)
    {
        [targetView.layer setShadowOffset:CGSizeMake(0, 10)];
        [targetView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [targetView.layer setShadowOpacity:0.25];
        // adjust shadow
        [targetView.layer setShadowPath:[[UIBezierPath
                                                     bezierPathWithRect:targetView.bounds] CGPath]];
    } else {
        [targetView.layer setShadowOffset:CGSizeZero];
        [targetView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [targetView.layer setShadowOpacity:0.0];
    }
}

-(void)orderPreviousCurrentNextView
{
    if (_previous)
        [self.view insertSubview:_previous.view belowSubview:_current.view];
    if (_next)
        [self.view insertSubview:_next.view aboveSubview:_current.view];

    
}


-(void)setPrevious:(LoaderChildViewController *)previous
{
    if (_previous)
    {
        [self setShadowEnabled:NO toView:_previous.view];
        [_previous.view removeFromSuperview];
        [_previous removeFromParentViewController];
        _previous.swipeContainer = nil;
    }
    _previous = previous;
    if (_previous)
    {
        [self setShadowEnabled:YES toView:_previous.view];
        _previous.view.hidden = YES;
        _previous.swipeContainer = self;
        //[self.view insertSubview:_previous.view belowSubview:_current.view];
        [self.view addSubview:_previous.view];
        [self orderPreviousCurrentNextView];
        [self addChildViewController:_previous];
        [_previous didMoveToParentViewController:self];
        [_previous childIsMain:NO];
    }
}

-(void)setNext:(LoaderChildViewController *)next
{
    if (_next)
    {
        [self setShadowEnabled:NO toView:_next.view];
        [_next.view removeFromSuperview];
        [_next removeFromParentViewController];
        _next.swipeContainer = nil;
    }
    _next = next;
    if (_next)
    {
        [self setShadowEnabled:YES toView:_next.view];
        _next.view.hidden = YES;
        _next.swipeContainer = self;
        //[self.view insertSubview:_next.view aboveSubview:_current.view];
        [self.view addSubview:_next.view];
        [self orderPreviousCurrentNextView];
        [self addChildViewController:_next];
        [_next didMoveToParentViewController:self];
        [_next childIsMain:NO];
    }
}

-(void)setCurrent:(LoaderChildViewController *)viewController
{
    if (_current)
    {
        [self setShadowEnabled:NO toView:_current.view];
        [_current removeFromParentViewController];
        [_current.view removeFromSuperview];
    }
    _current = viewController;
    self.next = nil;
    self.previous = nil;
    
    self.title = nil;
    
    if (viewController)
    {
        _current.swipeContainer = self;
        [self setShadowEnabled:YES toView:_current.view];
        //_current.swipeIndex = 0;
        [self addChildViewController:_current];
        [_current didMoveToParentViewController:self];
        self.title = _current.title;
        [self.view addSubview:_current.view];
        [self orderPreviousCurrentNextView];
        [_current childIsMain:YES];
        [self viewWillLayoutSubviews];
        
    }
}

-(NSTimeInterval)getPanDuration:(CGFloat)velocityX
{
    NSTimeInterval duration = panDuration;
    if (velocityX > 0)
        duration = _current.view.frame.origin.x / velocityX;
    if (duration > panDuration)
        duration = panDuration;
    if (duration < panDuration / 100)
        duration = panDuration / 100;
    return duration;
}

-(void)gotoPrevious:(CGFloat)velocityX
{
    if (self.previous == nil)
        return [self gotoCurrent:velocityX];
    
    [UIView animateWithDuration:[self getPanDuration:velocityX]
                     animations:^{
                         if (_previous)
                         {
                             _previous.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _previous.overlay.alpha = 0.0;
                         }
                         if (_current)
                         {
                             _current.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _current.overlay.alpha = 0.0;
                             //_current.view.alpha = 0.0;
                         }
                         if (_next)
                         {
                             _next.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _next.overlay.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished){

                         //NSLog(@"should go to previous!");
                         // stats
//                         [self.current.loader.globalTracker trackEventWithCategory:@"swipe" withAction:@"previous" withLabel:self.current.url.absoluteString withValue:[NSNumber numberWithInt:1]];
                         
                         [self.current.loader.analytics sendEventWithName:@"swipe" action:@"previous" label:self.current.url.absoluteString value:[NSNumber numberWithInt:1]];
                         
                         //LoaderChildViewController *old = self.next;
                         
                         //LoaderChildViewController *tmp = self.previous;
                         
                         self.next = nil;
                         _next =_current;
                         _current = _previous;
                         _previous = nil;
                         
                         _next.view.hidden = YES;
                         
                         [_next childIsMain:NO];
                         [_current childIsMain:YES];
                         
                         if ([_current isKindOfClass:[PageViewController class]])
                             [_current.loader.adManager pageViewController:(PageViewController *)_current appearWithEvent:AdManagerEventSwipe];
                         
                         [self orderPreviousCurrentNextView];
                         
                         //NSLog(@"scrollview update, remove old next child");
                         //[old.view removeFromSuperview];
                         //[old removeFromParentViewController];
                         
                         [self viewWillLayoutSubviews];

                         [self insertPreviousChildView];
                     }];
}

-(void)gotoNext:(CGFloat)velocityX
{
    if (self.next == nil)
        return [self gotoCurrent:velocityX];
    
    [UIView animateWithDuration:[self getPanDuration:velocityX]
                     animations:^{
                         if (_previous)
                         {
                             _previous.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _previous.overlay.alpha = 1.0;
                         }
                         if (_current)
                         {
                             _current.view.frame = CGRectMake(-self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _current.view.alpha = 1.0;
                         }
                         if (_next)
                         {
                             _next.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _next.overlay.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished){
                         
                         [self.current.loader.analytics sendEventWithName:@"swipe" action:@"next" label:self.current.url.absoluteString value:[NSNumber numberWithInt:1]];
                         
                         self.previous = nil;
                         _previous = _current;
                         _current = _next;
                         _next = nil;
                         
                         _previous.view.hidden = YES;
                         
                         [_previous childIsMain:NO];
                         [_current childIsMain:YES];
                         if ([_current isKindOfClass:[PageViewController class]])
                             [_current.loader.adManager pageViewController:(PageViewController *)_current appearWithEvent:AdManagerEventSwipe];
                         
                         [self orderPreviousCurrentNextView];
                         //NSLog(@"scrollview update, remove old next child");
                         //[old.view removeFromSuperview];
                         //[old removeFromParentViewController];
                         
                         [self viewWillLayoutSubviews];
                         
                         [self insertNextChildView];
                     }];
    
    if (self.next != nil)
    {
        //[self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width * 2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
    }
}

-(void)gotoCurrent:(CGFloat)velocityX
{
    
    [UIView animateWithDuration:[self getPanDuration:velocityX]
                     animations:^{
                         if (_previous)
                         {
                             _previous.view.frame = CGRectMake(-self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _previous.overlay.alpha = 1.0;
                         }
                         if (_current)
                         {
                             _current.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _current.overlay.alpha = 0.0;
                         }
                         if (_next)
                         {
                             _next.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                             _next.overlay.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished){
                         _next.view.hidden = YES;
                         _previous.view.hidden = YES;
                     }];
}

#pragma mark - progress API

-(void)child:(LoaderChildViewController *)childViewController startProgressWithExpectedProgress:(float)expectedProgress inTime:(float)duration
{
    childViewController.progressStart = YES;
    childViewController.progressIndeterminate = YES;
    childViewController.progress = 0;
    if (_current == childViewController)
    {
        //NSLog(@"startProgressWithExpectedProgress:%f inTime:%f", expectedProgress, duration);
        //NSLog(@"navigationController: %@ navigationBar: %@", self.navigationController, self.navigationController.navigationBar);
        [self.navigationController.navigationBar progressStart:expectedProgress inTime:duration];
        
        AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self];
        [appdeckProgressHUD show];
    }
}

-(void)child:(LoaderChildViewController *)childViewController updateProgressWithProgress:(float)progress duration:(float)duration
{
    childViewController.progressStart = YES;
    childViewController.progressIndeterminate = NO;
    childViewController.progress = progress;
    if (_current == childViewController)
    {
        //NSLog(@"updateProgressWithProgress:%f duration:%f", progress, duration);
        [self.navigationController.navigationBar progressUpdate:progress duration:duration];
        if (progress > 0.75)
        {
            AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self];
            [appdeckProgressHUD hide];
        }
    }
}

-(void)child:(LoaderChildViewController *)childViewController endProgressDuration:(float)secconds
{
    childViewController.progressStart = NO;
    childViewController.progressIndeterminate = YES;
    childViewController.progress = 1;
    if (_current == childViewController)
    {
        //NSLog(@"endProgressDuration:%f", secconds);
        AppDeckProgressHUD *appdeckProgressHUD = [AppDeckProgressHUD progressHUDForViewController:self];
        [appdeckProgressHUD hide];
        [self.navigationController.navigationBar progressEnd:secconds];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)shouldSwipeViews
{
/*
#ifdef DEBUG_OUTPUT
    NSLog(@"shouldSwipeViews: x = %f - width = %f", self.scrollView.contentOffset.x, self.view.frame.size.width);
#endif
    
    if (self.scrollView.contentOffset.x == 0 && self.previous != nil)
    {
        //NSLog(@"should go to previous!");
        // stats
        [self.current.loader.globalTracker trackEventWithCategory:@"swipe" withAction:@"previous" withLabel:self.current.url.absoluteString withValue:[NSNumber numberWithInt:1]];

        //LoaderChildViewController *old = self.next;
        
        //LoaderChildViewController *tmp = self.previous;
        
        self.next = nil;
        _next =_current;
        _current = _previous;
        _previous = nil;
        
//        [self.next childIsMain:NO];
        [_current childIsMain:YES];
        
        //NSLog(@"scrollview update, remove old next child");
        //[old.view removeFromSuperview];
        //[old removeFromParentViewController];
        
        [self viewWillLayoutSubviews];
        self.scrollView.contentOffset = CGPointMake(0, 0);
        [self insertPreviousChildView];
    }
    else if ((self.scrollView.contentOffset.x == self.view.frame.size.width && self.previous == nil) || self.scrollView.contentOffset.x == self.view.frame.size.width * 2)
    {
        // stats
        [self.current.loader.globalTracker trackEventWithCategory:@"swipe" withAction:@"next" withLabel:self.current.url.absoluteString withValue:[NSNumber numberWithInt:1]];
        //NSLog(@"should go to next!");

        //LoaderChildViewController *old = self.previous;
        
        self.previous = nil;
        _previous = _current;
        _current = _next;
        _next = nil;
        
        //[self.previous childIsMain:NO];
        [_current childIsMain:YES];
        
        //NSLog(@"scrollview update, remove old previous child");
        //[old.view removeFromSuperview];
        //[old removeFromParentViewController];
        
        [self viewWillLayoutSubviews];
        [self insertNextChildView];
    }
    else if (self.scrollView.contentOffset.x == 0 || self.scrollView.contentOffset.x == self.view.frame.size.width)
    {
        [_current childIsMain:YES];
    }    */
}
/*
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll: AD: %d - offset.x: %f - width: %f - previous: %@", fullScreenAdReady, self.scrollView.contentOffset.x, self.view.frame.size.width, self.previous);
    if (fullScreenAdReady == YES)
    {
        // insert fullscreen ad in previous
        if (self.scrollView.contentOffset.x < self.view.frame.size.width && self.previous != nil)
        {
            [self.scrollView addSubview:fullScreenAd.view];
            [self addChildViewController:fullScreenAd];
            fullScreenAd.view.frame = self.previous.view.frame;
            fullScreenAd.previousUrl = self.previous.url;
            fullScreenAd.nextUrl = _current.url;
            fullScreenAd.autoScroll = FullScreenAdAutoScrollPrevious;
            //LoaderChildViewController *old = self.previous;
            self.previous = fullScreenAd;
            fullScreenAd = nil;
            fullScreenAdReady = NO;
            fullScreenAdDisplayed = YES;
            //[old.view removeFromSuperview];
            //[old removeFromParentViewController];
        }
        // insert fullscreen ad in next
        else if (self.scrollView.contentOffset.x > self.view.frame.size.width && self.next != nil)
        {
            [self.scrollView addSubview:fullScreenAd.view];
            [self addChildViewController:fullScreenAd];
            fullScreenAd.view.frame = self.next.view.frame;
            fullScreenAd.nextUrl = self.next.url;
            fullScreenAd.previousUrl = _current.url;
            fullScreenAd.autoScroll = FullScreenAdAutoScrollNext;
            //LoaderChildViewController *old = self.next;
            self.next = fullScreenAd;
            fullScreenAd = nil;
            fullScreenAdReady = NO;
            fullScreenAdDisplayed = YES;            
            //[old.view removeFromSuperview];
            //[old removeFromParentViewController];
        }
    }
    if (_current.isMain == YES && self.scrollView.contentOffset.x != 0 && self.scrollView.contentOffset.x != self.view.frame.size.width && self.scrollView.contentOffset.x != self.view.frame.size.width * 2)
    {
        [_current childIsMain:NO];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self shouldSwipeViews];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.isDecelerating == NO)
    {
        [self shouldSwipeViews];
    }
}
*/
#pragma mark - Rotate

-(void)insertNextChildView
{
    //NSLog(@"insertNextChildView: current.nextUrl = %@ - next = %@", _current.nextUrl, self.next);
    // if url are not the same we pop
    if (_current.nextUrl != nil && self.next != nil &&
        [_current.nextUrl.absoluteString isEqualToString:self.next.url.absoluteString] == NO)
    {
        NSLog(@"_current.nextUrl: %@", _current.nextUrl.absoluteString);
        NSLog(@"self.next.url: %@", self.next.url.absoluteString);

        /*[_next.view removeFromSuperview];
        [_next removeFromParentViewController];
        _next.swipeContainer = nil;
        _next = nil;*/
        self.next = nil;        
    }

    if (_current.nextUrl != nil && self.next == nil)
    {
        self.next = [_current.loader getChildViewControllerFromURL:_current.nextUrl.absoluteString type:nil];
        /*self.next.swipeContainer = self;
        [self.scrollView addSubview:self.next.view];
        [self addChildViewController:self.next];
        [self.next childIsMain:NO];*/
        [self viewWillLayoutSubviews];
    }
}

-(void)insertPreviousChildView
{
    NSLog(@"insertPreviousChildView: previousUrl = %@ - previous = %@", _current.previousUrl, self.previous);

    // if url are not the same we pop
    if (_current.previousUrl != nil && self.previous != nil &&
        [_current.previousUrl.absoluteString isEqualToString:self.previous.url.absoluteString] == NO)
    {
        NSLog(@"_current.previousUrl: %@", _current.previousUrl.absoluteString);
        NSLog(@"self.previous.url: %@", self.previous.url.absoluteString);
        self.previous = nil;
    }
    
    if (_current.previousUrl != nil && self.previous == nil)
    {
        self.previous = [_current.loader getChildViewControllerFromURL:_current.previousUrl.absoluteString type:nil];
        [self viewWillLayoutSubviews];
    }
}

#pragma mark - pan gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (_previous == nil && _next == nil)
        return NO;
    
    if (self.swipeEnabled == NO)
        return NO;
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panRecognizer velocityInView:self.view];
        // denied vertical panning
        if (ABS(velocity.x) < ABS(velocity.y))
            return NO;

        /*
        if (velocity.x > 0 && _previous == nil)
            return NO;
        if (velocity.x < 0 && _next == nil)
            return NO;
        */
        //return ABS(velocity.x) > ABS(velocity.y); // Horizontal panning
        //return ABS(velocity.x) < ABS(velocity.y); // Vertical panning
    }
    
    CGPoint currentTouchPoint     = [gestureRecognizer locationInView:self.view];
    
    // left menu conflict ?
    if (_current.loader.conf.leftMenuUrl != nil)
    {
        if (currentTouchPoint.x < self.view.frame.size.width * 0.20)
            return NO;
    }
    // right menu conflict ?
    if (_current.loader.conf.rightMenuUrl != nil)
    {
        if (currentTouchPoint.x > self.view.frame.size.width - self.view.frame.size.width * 0.20)
            return NO;
    }
    
/*    CGPoint currentTouchPoint     = [gestureRecognizer locationInView:self.view];
    CGFloat currentTouchPositionX = currentTouchPoint.x;
    CGFloat panAmount = currentTouchPositionX - self.initialTouchPositionX;
    if (panAmount > 0 && _previous == nil)
        return NO;
    if (panAmount < 0 && _next == nil)
        return NO;*/
    return YES;
}

- (void)updateSwipeViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchPoint     = [recognizer locationInView:self.view];
    CGFloat currentTouchPositionX = currentTouchPoint.x;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialTouchPositionX = currentTouchPositionX;
        self.initialHorizontalCenter = self.view.center.x;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat panAmount = currentTouchPositionX - self.initialTouchPositionX;

        if (_current)
        {
            CGRect frame = self.view.bounds;
            frame.origin.x = (panAmount > 0 ? panAmount : panAmount / 2);
            if (frame.origin.x >= 0 && _previous == nil)
                frame.origin.x *= 0.5;
            if (frame.origin.x <= 0 && _next == nil)
                frame.origin.x *= 0.5;
            _current.view.frame = frame;
            if (panAmount < 0 && _next != nil)
                _current.overlay.alpha = -panAmount/self.view.bounds.size.width;
            else
                _current.overlay.alpha = 0.0;
        }
        
        if (_previous)
        {
            _previous.view.hidden = NO;
            CGRect frame = self.view.bounds;
            frame.origin.x = -self.view.bounds.size.width / 2 + panAmount / 2;
            if (frame.origin.x >= 0)
                frame.origin.x = 0;
            _previous.view.frame = frame;
            _previous.overlay.alpha = 1 - panAmount/self.view.bounds.size.width;
            //_previous.view.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width / 2 + panAmount / 2, 0.0f);
        }

        if (_next)
        {
            _next.view.hidden = NO;
            CGRect frame = self.view.bounds;
            frame.origin.x = self.view.bounds.size.width + panAmount/* * 2*/;
            if (frame.origin.x <= 0)
                frame.origin.x = 0;
            _next.view.frame = frame;
            _next.overlay.alpha = 0.0;
//            [_next setOverlay:-panAmount/self.view.frame.size.width];
        }
        
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
        CGFloat panAmount = self.initialTouchPositionX - currentTouchPositionX;

        
        /*CGFloat newCenterPosition = self.initialHorizontalCenter - panAmount;*/
        
        CGPoint currentVelocityPoint = [recognizer velocityInView:self.view];
        CGFloat currentVelocityX     = currentVelocityPoint.x;
        
//        NSLog(@"panAmount: %f = newCenterPosition : %f - currentVelocityX : %f", panAmount, newCenterPosition, currentVelocityX);
        
        if (currentVelocityPoint.x > 0 && panAmount < 0 && (-panAmount > self.view.frame.size.width * 0.25 || currentVelocityPoint.x > 75))
        {
            [self gotoPrevious:currentVelocityX];
        }
        else if (currentVelocityPoint.x < 0 && panAmount > 0 && (panAmount > self.view.frame.size.width * 0.25 || currentVelocityPoint.x > 75))
        {
            [self gotoNext:currentVelocityX];
        }
        else
        {
            [self gotoCurrent:currentVelocityX];
        }
        
        recognizer.enabled = YES;
/*
        
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             if (_previous)
                                 _previous.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                             if (_current)
                                 _current.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                             if (_next)
                                 _next.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             _next.view.hidden = YES;
                             _previous.view.hidden = YES;
                         }];
        */
/*        BOOL viewIsPastAnchor = (self.anchorLeftTopViewCenter != NSNotFound && self.topView.layer.position.x <= self.anchorLeftTopViewCenter) ||
        (self.anchorRightTopViewCenter != NSNotFound && self.topView.layer.position.x >= self.anchorRightTopViewCenter);
        
        if ([self underLeftShowing] && (viewIsPastAnchor || currentVelocityX > self.panningVelocityXThreshold)) {
            [self anchorTopViewTo:ECRight];
        } else if ([self underRightShowing] && (viewIsPastAnchor || -currentVelocityX > self.panningVelocityXThreshold)) {
            [self anchorTopViewTo:ECLeft];
        } else {
            [self resetTopView];
        }*/
    }
}

#pragma mark - fullScreen

-(void)adjustFullScreen
{
    if (_current.isFullScreen)
    {
        [_current.loader setFullScreen:YES animation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        if (_current.loader.appDeck.iosVersion >= 7.0)
            [_current.loader setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        //if (self.lo)
        //[self setNeedsStatusBarAppearanceUpdate];
    } else {
        [_current.loader setFullScreen:NO animation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        if (_current.loader.appDeck.iosVersion >= 7.0)
            [_current.loader setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

#pragma mark - rotation

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
#ifdef DEBUG_OUTPUT
    NSLog(@"SwipeViewController: %f - %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"SwipeViewController: %f - %f", self.view.bounds.size.width, self.view.bounds.size.height);    
#endif

    if (_previous)
        _previous.view.frame = CGRectMake(-self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (_current)
        _current.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (_next)
        _next.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    /*
    
    
    // align subview correctly
    float originX = 0;
    if (self.previous != nil)
    {
        self.previous.view.frame = CGRectMake(originX, 0, self.view.frame.size.width, self.view.frame.size.height);
        originX += self.view.frame.size.width;
    }
    _current.view.frame = CGRectMake(originX, 0, self.view.frame.size.width, self.view.frame.size.height);
    originX += self.view.frame.size.width;
    if (self.next != nil)
    {
        self.next.view.frame = CGRectMake(originX, 0, self.view.frame.size.width, self.view.frame.size.height);
    }*/
    
    // resize titleView
    if (self.navigationItem.titleView)
    {
        CGRect newSuperviewBounds = self.navigationItem.titleView.superview.bounds;
        CGRect frame = self.navigationItem.titleView.frame;
        if (newSuperviewBounds.size.width > 0 && newSuperviewBounds.size.height > 0 && frame.size.height != newSuperviewBounds.size.height)
        {
            frame.origin.y += (frame.size.height - newSuperviewBounds.size.height) / 2;
            frame.size.height = newSuperviewBounds.size.height;
            self.navigationItem.titleView.frame = frame;
        }
    }
    [self adjustFullScreen];
}

@end
