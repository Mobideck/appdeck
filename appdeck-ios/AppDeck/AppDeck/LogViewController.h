//
//  LogViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 11/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LogViewController;

extern  __strong LogViewController *glLog;

@class LoaderViewController;

typedef enum {
    /* hidden on top of the screen */
    LogViewControllerPositionHiddenTop,
    /* top of the screen */
    LogViewControllerPositionTop,
    /* bottom of the screen */
    LogViewControllerPositionBottom,
    /* hidden on bottom of the screen */
    LogViewControllerPositionHiddenBottom,
    /* hidden */
    LogViewControllerPositionHidden
    
} LogViewControllerPosition;

@interface LogViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>
{
    UIFont *font;    
    UIScrollView    *scrollView;
    BOOL    colorAlt;
    UIColor *color1;
    UIColor *color2;
    
    BOOL showDebug;
    BOOL showInfo;
    BOOL showWarn;
    BOOL showError;
    
    UIColor *debugColor;
    UIColor *infoColor;
    UIColor *warnColor;
    UIColor *errorColor;
    
    BOOL autoScroll;
    
    int maxlogs;
    
    NSMutableArray *logs;
    
    UIToolbar *toolbar;
    
    UIBarButtonItem *debug;
    UIBarButtonItem *info;
    UIBarButtonItem *warn;
    UIBarButtonItem *error;
    UIBarButtonItem *code;
    UIBarButtonItem *clear;
    UIBarButtonItem *close;
    
    NSString *lastJS;
    
    UIView *miniView;
    UIButton *miniButton;
    UILabel *miniLabel;
    UILabel *miniInfo;
    
    int nbWarning;
    int nbError;
}

-(void)debug:(NSString *)format, ...;
-(void)info:(NSString *)format, ...;
-(void)warning:(NSString *)format, ...;
-(void)error:(NSString *)format, ...;

@property (assign, nonatomic) BOOL isOpen;
@property (weak, nonatomic) LoaderViewController *loader;
@property (assign, nonatomic) LogViewControllerPosition position;
@property (strong, nonatomic) NSString *host;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil loader:(LoaderViewController *)loader;

@end
