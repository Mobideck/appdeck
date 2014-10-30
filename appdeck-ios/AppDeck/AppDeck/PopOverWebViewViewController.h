//
//  PopUpWebViewViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 09/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoaderChildViewController.h"
#import "ManagedUIWebViewController.h"
#import "FPPopover/FPPopoverController.h"

@interface PopOverWebViewViewController : UIViewController <ManagedUIWebViewDelegate, FPPopoverControllerDelegate, AppDeckApiCallDelegate>
{
    ManagedUIWebViewController *ctl;
}

@property (nonatomic, strong) UIColor   *backgroundColor;

@property (nonatomic, strong) NSString     *url;

@property (nonatomic, strong) LoaderChildViewController *parent;

@property (nonatomic, strong) FPPopoverController *popover;

+(PopOverWebViewViewController *)showWithConfig:(NSString *)config fromView:(UIView *)view withParent:(LoaderChildViewController *)parent error:(NSError **)error;

@end
