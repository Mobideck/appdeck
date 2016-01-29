//
//  PopUpWebViewViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 09/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "PopOverWebViewViewController.h"

#import "NSError+errorWithFormat.h"
#import "LoaderChildViewController.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"
//#import "JSONKit.h"
#import "NSString+UIColor.h"

@interface PopOverWebViewViewController ()

@end

@implementation PopOverWebViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.view.backgroundColor = [UIColor redColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadWebView
{
    ctl = [ManagedWebView createManagedWebView];
    ctl.delegate = self;
    [self.view addSubview:ctl.view];
    
    [ctl setChromeless:YES];
    [ctl.webView setBackgroundColor:self.backgroundColor];

    if (self.backgroundColor)
        [ctl setBackgroundColor1:self.backgroundColor color2:self.backgroundColor];
    else
        [ctl setBackgroundColor1:self.parent.loader.conf.app_background_color1 color2:self.parent.loader.conf.app_background_color2];
    ctl.scrollView.alwaysBounceVertical = NO;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url relativeToURL:self.parent.url]];
    [ctl loadRequest:request
             progess:^(float percent) {}
           completed:^(NSError *error) {
               
               if (error != nil)
                   [self.popover dismissPopoverAnimated:YES];
               
           }];
}

#pragma mark - API

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    
    
    return NO;
}

#pragma mark - ManagedUIWebViewDelegate

-(BOOL)managedWebView:(ManagedWebView *)managedWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self.parent load:request.URL.absoluteString];
    [self.popover dismissPopoverAnimated:YES];
    return NO;
}

#pragma mark - FPPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController
{
    
}

- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    
}

#pragma mark - API

+(PopOverWebViewViewController *)showWithConfig:(NSMutableDictionary *)infos fromView:(UIView *)view withParent:(LoaderChildViewController *)parent error:(NSError **)error
{
/*    NSMutableDictionary *infos = [[NSMutableDictionary alloc] init];
    
    NSArray *chunks = [config componentsSeparatedByString:@","];
    for (NSString *chunk in chunks)
    {
        NSArray *tmp = [chunk componentsSeparatedByString:@"="];
        if ([tmp count] == 2)
        {
            NSString *name = [[tmp objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *value = [[tmp objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [infos setObject:value forKey:name];
        }
    }*/
    
    if (infos == nil)
    {
        if (error)
            *error = [NSError errorWithFormat:@"no config set"];
        return nil;
    }
    
    if ([infos respondsToSelector:@selector(objectForKey:)] == NO)
    {
        if (error)
            *error = [NSError errorWithFormat:@"argument should be an object: %@", infos];
        return nil;
    }
    
    NSString *url = [infos objectForKey:@"url"];
    if (url == nil)
    {
        if (error)
            *error = [NSError errorWithFormat:@"entry 'url' missing: %@", infos];
        return nil;
    }
    
    // configuration
    CGFloat width = [[infos objectForKey:@"width"] floatValue];
    CGFloat height = [[infos objectForKey:@"height"] floatValue];
    CGFloat alpha = [[infos objectForKey:@"alpha"] floatValue];
    NSString *tint = [infos objectForKey:@"tint"];
    NSString *arrow = [infos objectForKey:@"arrow"];
    NSString *title = [infos objectForKey:@"title"];
    UIColor *bgcolor = [[infos objectForKey:@"bgcolor"] toUIColor];
    id border = [infos objectForKey:@"border"];
    //id radius = [infos objectForKey:@"radius"];
    
    PopOverWebViewViewController *ctl = [[PopOverWebViewViewController alloc] initWithNibName:nil bundle:nil];
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:ctl];
        
    if (width == 0)
        width = 150;
    if (height == 0)
        height = 200;
    popover.contentSize = CGSizeMake(width, height);
    if (view == nil)
    {
        popover.arrowDirection = FPPopoverNoArrow;
    }
    
    if ([tint isEqualToString:@"black"])
        popover.tint = FPPopoverBlackTint;
    if ([tint isEqualToString:@"light"])
        popover.tint = FPPopoverLightGrayTint;
    if ([tint isEqualToString:@"green"])
        popover.tint = FPPopoverGreenTint;
    if ([tint isEqualToString:@"red"])
        popover.tint = FPPopoverRedTint;
    if ([tint isEqualToString:@"white"])
        popover.tint = FPPopoverWhiteTint;
    
    if ([arrow isEqualToString:@"up"])
        popover.arrowDirection = FPPopoverArrowDirectionUp;
    if ([arrow isEqualToString:@"down"])
        popover.arrowDirection = FPPopoverArrowDirectionDown;
    if ([arrow isEqualToString:@"none"])
        popover.arrowDirection = FPPopoverNoArrow;
    
    popover.border = YES;
    if (border != nil)
        popover.border = [border boolValue];
    
    /*if (radius != nil)
        popover.radius = [radius floatValue];*/
    
    if (alpha > 0)
        popover.alpha = alpha;
    
/*    if (bgcolor == nil)
        bgcolor = [UIColor clearColor];*/

    // disable shadow
/*    popover.view.layer.shadowOpacity = 0.0;
    popover.view.layer.shadowRadius = 0;
    popover.view.layer.shadowOffset = CGSizeMake(0, 0);*/
    [popover setShadowsHidden:YES];
    
    ctl.popover = popover;
    ctl.parent = parent;
    ctl.url = url;
    popover.delegate = ctl;
    ctl.backgroundColor = bgcolor;
    
    if (view != nil)
        [popover presentPopoverFromView:view];
    else
        [popover presentPopoverFromPoint:CGPointMake(parent.loader.view.frame.size.width / 2, parent.loader.view.frame.size.height / 2 - height / 2)];
    
    popover.title = title;
    
   [ctl loadWebView];
    
    
    return ctl;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
#ifdef DEBUG_OUTPUT
    NSLog(@"PopUpWebView: %f - %f - %f", self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"PopUpWebView: %f - %f - %f", self.view.bounds.origin.x, self.view.bounds.size.width, self.view.bounds.size.height);
#endif
    
    if (ctl != nil)
    {
        ctl.view.frame = self.view.bounds;
    }
    
}
@end
