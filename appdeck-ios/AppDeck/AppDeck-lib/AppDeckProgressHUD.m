//
//  AppDeckProgressHUD.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 18/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AppDeckProgressHUD.h"
#import <objc/runtime.h>
#import "MBProgressHUD.h"
#import "MRProgress/src/MRProgress.h"
#import "MRProgress/src/Components/MRProgressOverlayView.h"
#import "AppDeck.h"
#import "SVProgressHUD.h"

static char AppDeckProgressHUDKey;

@interface AppDeckProgressHUD ()
{
    MBProgressHUD *mbProgressHUD;
//    SVProgressHUD * svpProgressHUD;
    MRProgressOverlayView *mrProgress;
}

@property (nonatomic, strong) NSTimer *graceTimer;
@property (nonatomic, strong) NSTimer *minShowTimer;
@property (nonatomic, strong) NSDate *showStarted;

@end;

@implementation AppDeckProgressHUD

+ (AppDeckProgressHUD *)progressHUDForViewController:(UIViewController *)viewController;
{
    AppDeckProgressHUD *progressHUD = (AppDeckProgressHUD *)objc_getAssociatedObject(viewController, &AppDeckProgressHUDKey);
    if (progressHUD == nil)
    {
        progressHUD = [[AppDeckProgressHUD alloc] initWithViewController:viewController];
        objc_setAssociatedObject(viewController, &AppDeckProgressHUDKey, progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //objc_setAssociatedObject(viewController, &AppDeckProgressHUDKey, progressHUD, 0);
    }
    return progressHUD;
}

-(id)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        self.graceTime = 1.0;
        self.minShowTime = 0.5;
        self.viewController = viewController;

    }
    return self;
}

-(void)show
{
	if (self.graceTime > 0.0)
    {
		self.graceTimer = [NSTimer scheduledTimerWithTimeInterval:self.graceTime target:self
                                                         selector:@selector(showNow:) userInfo:nil repeats:NO];
	}
    else
        [self showNow:nil];

}

-(void)showNow:(id)origin
{
    if (self.viewController == nil)
        return;
    self.graceTimer = nil;
    self.showStarted = [NSDate date];
    if ([[AppDeck sharedInstance] iosVersion] >= 7.0)
    {
        [SVProgressHUD show];
        /*
        if (mrProgress == nil)
        {
            mrProgress = [MRProgressOverlayView new];
            mrProgress.userInteractionEnabled = NO;
            //[mrProgress createBlurView];
            [self.viewController.view addSubview:mrProgress];
        }
        [mrProgress show:YES];*/
        
    }
    else
    {
        if (mbProgressHUD == nil)
        {
            mbProgressHUD = [[MBProgressHUD alloc] initWithView:self.viewController.view];
            //mbProgressHUD.delegate = self;
            mbProgressHUD.animationType = MBProgressHUDAnimationZoom;
            mbProgressHUD.userInteractionEnabled = NO;
            mbProgressHUD.graceTime = 0.0;
            mbProgressHUD.minShowTime = 0.0;
            mbProgressHUD.mode = MBProgressHUDModeIndeterminate;
            mbProgressHUD.labelText = NSLocalizedString(@"LOADING", nil);
            [self.viewController.view addSubview:mbProgressHUD];
        }
        mbProgressHUD.taskInProgress = YES;
        [mbProgressHUD show:YES];
    }
}

-(void)hide
{
    // we did not get the time to show it
    if (self.graceTimer)
    {
        [self.graceTimer invalidate];
        self.graceTimer = nil;
        return;
    }
 
    // we show it but not long enough
	if (self.minShowTime > 0.0 && self.showStarted)
    {
		NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:self.showStarted];
		if (interv < self.minShowTime)
        {
            self.showStarted = nil;
			self.minShowTimer = [NSTimer scheduledTimerWithTimeInterval:(self.minShowTime - interv) target:self
                                                               selector:@selector(hide) userInfo:nil repeats:NO];
			return;
		}
	}
    
    if ([[AppDeck sharedInstance] iosVersion] >= 7.0)
    {
        [SVProgressHUD dismiss];
//        [mrProgress dismiss:YES];
//        mrProgress = nil;
    }
    else
    {
        mbProgressHUD.taskInProgress = NO;
        [mbProgressHUD hide:YES];
    }
}

@end