//
//  LogViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 11/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "LogViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "AppDeck.h"
#import "LoaderViewController.h"
#import "LoaderChildViewController.h"
#import "LoaderConfiguration.h"

__strong LogViewController *glLog = nil;

@interface LogViewController ()

@end

@implementation LogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil loader:(LoaderViewController *)loader
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.loader = loader;
        self.host = loader.conf.baseUrl.host;
    }
    return self;
}

-(void)dealloc
{
    scrollView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//#warning remove me
//    return;
    
    nbWarning = 0;
    nbError = 0;
    
    font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14];
    //self.view.alpha = 0.5;
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
//    [self.view setUserInteractionEnabled:NO];
    scrollView = [[UIScrollView alloc] init];
    scrollView.scrollsToTop = NO;
    //scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
  
    scrollView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
    
    self.position = LogViewControllerPositionHiddenBottom;
    
//    color1 = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
    color1 = [UIColor clearColor];
    color2 = [[UIColor grayColor] colorWithAlphaComponent:0.25f];

//    color1 = [UIColor lightGrayColor];
//    color2 = [UIColor grayColor];
    
    miniView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height)];
    miniView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    miniView.layer.cornerRadius = miniView.frame.size.width / 2;
    miniButton = [UIButton buttonWithType:UIButtonTypeCustom];
    miniButton.frame = CGRectMake(0, -12, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height);
    [miniButton setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
    [miniButton setImage:self.loader.conf.icon_up.image forState:UIControlStateNormal];
    [miniButton addTarget:self action:@selector(buttonCloseMini:) forControlEvents:UIControlEventTouchUpInside];
    miniLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, miniView.frame.size.width, miniView.frame.size.height - 20)];
    miniLabel.text = @"log";
    miniLabel.font = font;
    miniLabel.textColor = [UIColor whiteColor];
    miniLabel.shadowColor = [UIColor grayColor];
    miniLabel.shadowOffset = CGSizeMake(0, 1);
    miniLabel.backgroundColor = [UIColor clearColor];
    miniLabel.textAlignment = NSTextAlignmentCenter;
    miniInfo = [[UILabel alloc] initWithFrame:CGRectMake(30, miniView.frame.size.height / 2 - miniView.frame.size.width / 2 - 6, miniView.frame.size.width, miniView.frame.size.width)];
    miniInfo.text = @"50";
    miniInfo.font = font;
    miniInfo.textColor = [UIColor whiteColor];
    miniInfo.backgroundColor = [UIColor redColor];
    miniInfo.layer.borderColor = [UIColor whiteColor].CGColor;
    miniInfo.layer.borderWidth = 2.0;
    miniInfo.shadowColor = [UIColor grayColor];
    miniInfo.shadowOffset = CGSizeMake(0, 1);
    miniInfo.layer.cornerRadius = miniInfo.frame.size.width / 2;
    miniInfo.textAlignment = NSTextAlignmentCenter;
    
    [miniView addSubview:miniLabel];
    [miniView addSubview:miniInfo];
    [miniView addSubview:miniButton];
    
    [self.view addSubview:miniView];
    
//    [scrollView setUserInteractionEnabled:NO];
    [self.view addSubview:scrollView];
    
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 0);
    scrollView.alwaysBounceVertical = YES;
    lastJS = @"alert('ok');";
    
    scrollView.delegate = self;
    
    autoScroll = YES;
    maxlogs = 100;
    logs = [[NSMutableArray alloc] initWithCapacity:maxlogs * 2];
 
    toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    toolbar.alpha = 0.5;
    
    showDebug = NO;
    showInfo = YES;
    showWarn = YES;
    showError = YES;
    
    debugColor = [UIColor whiteColor];
    infoColor = [UIColor blueColor];
    warnColor = [UIColor orangeColor];
    errorColor = [UIColor redColor];
    
    debug = [[UIBarButtonItem alloc] initWithTitle:@"d" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonDebug:)];
//    debug.tintColor = [UIColor blackColor];
    debug.style = UIBarButtonItemStyleDone;
    info = [[UIBarButtonItem alloc] initWithTitle:@"i" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonDebug:)];
    info.tintColor = infoColor;
    warn = [[UIBarButtonItem alloc] initWithTitle:@"w" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonDebug:)];
    warn.tintColor = warnColor;
    error = [[UIBarButtonItem alloc] initWithTitle:@"e" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonDebug:)];
    error.tintColor = errorColor;
    code = [[UIBarButtonItem alloc] initWithTitle:@"{}" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonCode:)];
    code.tintColor = [UIColor lightGrayColor];
    clear = [[UIBarButtonItem alloc] initWithTitle:@"x" style:UIBarButtonItemStyleBordered target:self action:@selector(clear:)];
    clear.tintColor = [UIColor lightGrayColor];
    
    UISegmentedControl *closeSegment = [[UISegmentedControl alloc] initWithItems:@[self.loader.conf.icon_up.image, self.loader.conf.icon_down.image]];
    closeSegment.segmentedControlStyle = UISegmentedControlStylePlain;
    closeSegment.frame = CGRectMake(0, 0, 60, 30.0);
    closeSegment.tintColor = [UIColor blackColor];
    //close = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStyleDone target:self action:@selector(buttonClose:)];
    [closeSegment addTarget:self action:@selector(buttonClose:) forControlEvents:UIControlEventValueChanged];
    close = [[UIBarButtonItem alloc] initWithCustomView:closeSegment];
    //close.style = UIBarButtonItemStyleDone;
//    close.tintColor = [UIColor lightGrayColor];
    
    NSArray *items = [NSArray arrayWithObjects:close, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                      debug, info, warn, error, code, clear, nil];

    [toolbar setItems:items animated:NO];
    
    [self.view addSubview:toolbar];
    
    // attach hide gesture recognizer
    UIGestureRecognizer  *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
//    longTap.numberOfTapsRequired = 1;
//    longTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:longTap];
}

-(void)hide:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
//        self.view.hidden = !self.view.hidden;
        if (self.position == LogViewControllerPositionHidden)
            self.position = LogViewControllerPositionHiddenBottom;
        else
            self.position = LogViewControllerPositionHidden;
        [self viewWillLayoutSubviews];
//        self.view.alpha = (self.view.alpha == 0 ? 1 : 0);
        //self.view.UserInteractionEnabled = YES;
    }
}

-(void)buttonDebug:(UIBarButtonItem *)button
{
    BOOL enable;
    if (button.style == UIBarButtonItemStyleDone)
    {
        button.style = UIBarButtonItemStyleBordered;
        enable = YES;
    }
    else
    {
        button.style = UIBarButtonItemStyleDone;
        enable = NO;
    }
    UIColor *color;
    if (button == debug)
    {
        showDebug = enable;
        color = debugColor;
    }
    if (button == info)
    {
        showInfo = enable;
        color = infoColor;
    }
    if (button == warn)
    {
        showWarn = enable;
        color = warnColor;
    }
    if (button == error)
    {
        showError = enable;
        color = errorColor;
    }
    if (enable)
        button.tintColor = color;
    else
        button.tintColor = [UIColor blackColor];
    [self viewWillLayoutSubviews];
}

-(void)buttonClose:(UISegmentedControl *)closeSegment
{
    if (closeSegment.selectedSegmentIndex == 0 && self.position == LogViewControllerPositionTop)
        self.position = LogViewControllerPositionHiddenTop;
    else if (closeSegment.selectedSegmentIndex == 0 && self.position == LogViewControllerPositionBottom)
        self.position = LogViewControllerPositionTop;
    else if (closeSegment.selectedSegmentIndex == 1 && self.position == LogViewControllerPositionTop)
        self.position = LogViewControllerPositionBottom;
    else if (closeSegment.selectedSegmentIndex == 1 && self.position == LogViewControllerPositionBottom)
        self.position = LogViewControllerPositionHiddenBottom;
    closeSegment.selectedSegmentIndex = UISegmentedControlNoSegment;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [self viewWillLayoutSubviews];
    
    [UIView commitAnimations];

}

-(void)buttonCloseMini:(UIButton *)button
{
    if (self.position == LogViewControllerPositionHiddenTop)
        self.position = LogViewControllerPositionTop;
    if (self.position == LogViewControllerPositionHiddenBottom)
        self.position = LogViewControllerPositionBottom;
    nbWarning = nbError = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    [self viewWillLayoutSubviews];
    
    [UIView commitAnimations];
}

-(void)buttonCode:(UIBarButtonItem *)button
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Execute local JS code"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Execute", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message textFieldAtIndex:0].text = lastJS;
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UITextField *field = [alertView textFieldAtIndex:0];
        lastJS = field.text;
//        AppDeck *app = [AppDeck sharedInstance];
        LoaderChildViewController *current = [self.loader getCurrentChild];
        NSString *fulljs = [NSString stringWithFormat:@"javascriptlog:%@;", lastJS];
        [current load:fulljs];
    }
}


-(void)clear:(UIBarButtonItem *)button
{
    for (UILabel *label in logs)
    {
        [label removeFromSuperview];
    }
    [logs removeAllObjects];
    [self viewWillLayoutSubviews];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addLog:(UIColor *)color content:(NSString *)content
{
    CGSize expectedLabelSize = [content sizeWithFont:font
                                   constrainedToSize:self.view.bounds.size
                                       lineBreakMode:NSLineBreakByCharWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollView.contentSize.height, self.view.bounds.size.width, expectedLabelSize.height)];
    label.text = content;
    label.textColor = color;
    label.font = font;
    label.numberOfLines = 100;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.lineBreakMode = NSLineBreakByCharWrapping;// UILineBreakModeCharacterWrap;
    
    BOOL redraw = NO;
    
    [logs addObject:label];
    if ([logs count] >= maxlogs * 2)
    {
        for (int k = 0; k < maxlogs; k++)
        {
            UILabel *outLabel = [logs objectAtIndex:0];
            [logs removeObjectAtIndex:0];
            [outLabel removeFromSuperview];
        }
        redraw = YES;
    }
    
    miniInfo.hidden = !(nbWarning + nbError > 0);
    miniInfo.backgroundColor = (nbError > 0 ? errorColor : warnColor);
    miniInfo.text = [NSString stringWithFormat:@"%d", nbWarning + nbError];
    
    if (label.textColor == debugColor && showDebug == NO)
        return;
    if (label.textColor == infoColor && showInfo == NO)
        return;
    if (label.textColor == warnColor && showWarn == NO)
        return;
    if (label.textColor == errorColor && showError == NO)
        return;
    
    label.backgroundColor = (colorAlt ? color1 : color2);
    colorAlt = !colorAlt;
    
    //BOOL scrollViewIsAtBottom = (scrollView.contentOffset.y + scrollView.bounds.size.height == scrollView.contentSize.height);
    
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height + expectedLabelSize.height);
    [scrollView addSubview:label];
    
    if (redraw)
        [self viewWillLayoutSubviews];
    else if (autoScroll)
    {
        CGPoint visible = scrollView.contentOffset;
        [scrollView scrollRectToVisible:CGRectMake(0, visible.y + expectedLabelSize.height, scrollView.contentSize.width, scrollView.contentSize.height) animated:YES];
    }

}

#pragma mark - ScrolViewDelegate

-(void)checkAutoScroll
{
    autoScroll = (scrollView.contentOffset.y + scrollView.bounds.size.height == scrollView.contentSize.height);
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    [self checkAutoScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)_scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.isDecelerating == NO)
    {
        [self checkAutoScroll];
    }
}

#pragma mark - API

-(void)debug:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"debug: %@", reason);
    __block LogViewController *me = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [me addLog:debugColor content:reason];
    });
}

-(void)info:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"info: %@", reason);
    __block LogViewController *me = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [me addLog:infoColor content:reason];
    });
}

-(void)warning:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"warning: %@", reason);
    __block LogViewController *me = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        nbWarning++;
        [me addLog:warnColor content:reason];
    });
}

-(void)error:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"error: %@", reason);
    __block LogViewController *me = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        nbError++;
        [me addLog:errorColor content:reason];
    });
}


#pragma mark - layout

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
#ifdef DEBUG_OUTPUT
    NSLog(@"super frame: %f - %f",  self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
    NSLog(@"log frame: %f - %f",  self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
#endif
    
    if (self.position == LogViewControllerPositionHiddenTop)
    {
        /*scrollView.hidden = YES;
        toolbar.hidden = YES;
        miniView.hidden = NO;*/
        scrollView.alpha = 0;
        toolbar.alpha = 0;
         miniView.alpha = 1;
        CGSize size = self.view.superview.bounds.size;
        self.view.frame = CGRectMake(size.width / 2 - miniView.frame.size.width / 2, 0, miniView.frame.size.width, miniView.frame.size.height);
        
        [miniButton setImage:self.loader.conf.icon_down.image forState:UIControlStateNormal];
        miniView.frame = CGRectMake(0, -10, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height);
        miniButton.frame = CGRectMake(0, 12, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height);
        miniLabel.frame = CGRectMake(0, 10, miniView.frame.size.width, miniView.frame.size.height - 20);
        miniInfo.frame = CGRectMake(30, miniView.frame.size.height / 2 - miniView.frame.size.width / 2 + 6, miniView.frame.size.width, miniView.frame.size.width);
        
        miniInfo.hidden = !(nbWarning + nbError > 0);
        miniInfo.backgroundColor = (nbError > 0 ? errorColor : warnColor);
            
        return;
    }
    if (self.position == LogViewControllerPositionHiddenBottom)
    {
/*        scrollView.hidden = YES;
        toolbar.hidden = YES;
        miniView.hidden = NO;*/
        scrollView.alpha = 0;
        toolbar.alpha = 0;
        miniView.alpha = 1;        
        CGSize size = self.view.superview.bounds.size;
        self.view.frame = CGRectMake(size.width / 2 - miniView.frame.size.width / 2, size.height - miniView.frame.size.height, miniView.frame.size.width, miniView.frame.size.height);

        [miniButton setImage:self.loader.conf.icon_up.image forState:UIControlStateNormal];
        miniView.frame = CGRectMake(0, 10, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height);
        miniButton.frame = CGRectMake(0, -12, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height);
        miniLabel.frame = CGRectMake(0, 10, miniView.frame.size.width, miniView.frame.size.height - 20);
        miniInfo.frame = CGRectMake(30, miniView.frame.size.height / 2 - miniView.frame.size.width / 2 - 5, miniView.frame.size.width, miniView.frame.size.width);

        miniInfo.hidden = !(nbWarning + nbError > 0);
        miniInfo.backgroundColor = (nbError > 0 ? errorColor : warnColor);
        
        return;
    }
    if (self.position == LogViewControllerPositionHidden)
    {
        scrollView.alpha = 0;
        toolbar.alpha = 0;
        miniView.alpha = 0;
        
        CGSize size = self.view.superview.bounds.size;
        self.view.frame = CGRectMake(size.width / 2 - miniView.frame.size.width / 2, size.height - miniView.frame.size.height, miniView.frame.size.width, miniView.frame.size.height);
        
        [miniButton setImage:self.loader.conf.icon_up.image forState:UIControlStateNormal];
        miniView.frame = CGRectMake(0, 10, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height);
        miniButton.frame = CGRectMake(0, -12, self.loader.conf.icon_up.image.size.width, self.loader.conf.icon_up.image.size.height);
        miniLabel.frame = CGRectMake(0, 10, miniView.frame.size.width, miniView.frame.size.height - 20);
        miniInfo.frame = CGRectMake(30, miniView.frame.size.height / 2 - miniView.frame.size.width / 2 - 5, miniView.frame.size.width, miniView.frame.size.width);
        
        miniInfo.hidden = !(nbWarning + nbError > 0);
        miniInfo.backgroundColor = (nbError > 0 ? errorColor : warnColor);
        
        return;
    }
    
    if (self.position == LogViewControllerPositionBottom)
    {
/*        scrollView.hidden = NO;
        toolbar.hidden = NO;
        miniView.hidden = YES;*/
        scrollView.alpha = 1;
        toolbar.alpha = 1;
        miniView.alpha = 0;
        CGSize size = self.view.superview.bounds.size;
        self.view.frame = CGRectMake(0, size.height / 2, size.width, size.height / 2);
    }
    if (self.position == LogViewControllerPositionTop)
    {
        scrollView.alpha = 1;
        toolbar.alpha = 1;
        miniView.alpha = 0;
        /*
        scrollView.hidden = NO;
        toolbar.hidden = NO;
        miniView.hidden = YES;*/
        CGSize size = self.view.superview.bounds.size;
        self.view.frame = CGRectMake(0, 0, size.width, size.height / 2);
    }

    
 
    BOOL rotate = (scrollView.frame.size.width != self.view.bounds.size.width);
 
    
    toolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    scrollView.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44);
    
    CGSize size = CGSizeMake(self.view.bounds.size.width, 0);//

    colorAlt = NO;
    for (UILabel *label in logs)
    {
        if ((label.textColor == debugColor && showDebug == NO) ||
            (label.textColor == infoColor && showInfo == NO) ||
            (label.textColor == warnColor && showWarn == NO) ||
            (label.textColor == errorColor && showError == NO))
        {
            if (label.superview != nil)
                [label removeFromSuperview];
            continue;
        }
        if (label.superview == nil)
            [scrollView addSubview:label];
        CGFloat height = label.frame.size.height;
        if (rotate)
        {
            CGSize expectedLabelSize = [label.text sizeWithFont:font
                                           constrainedToSize:self.view.bounds.size
                                               lineBreakMode:NSLineBreakByCharWrapping];
            height = expectedLabelSize.height;
        }
        label.frame = CGRectMake(0, size.height, size.width, height);
        label.backgroundColor = (colorAlt ? color1 : color2);
        colorAlt = !colorAlt;        
        size.height += height;
    }
    scrollView.contentSize = size;
    if (autoScroll)
    {
        [scrollView scrollRectToVisible:CGRectMake(0, scrollView.contentSize.height + scrollView.bounds.size.height, scrollView.contentSize.width, scrollView.contentSize.height) animated:NO];
    }
}

@end
