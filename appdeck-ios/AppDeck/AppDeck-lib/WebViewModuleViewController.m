//
//  WebViewModuleViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 19/06/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "WebViewModuleViewController.h"
#import "UIView+align.h"
#import "QuartzCore/QuartzCore.h"
#import "AppDeck.h"
#import "LoaderViewController.h"
#import "LoaderConfiguration.h"

@interface WebViewModuleViewController ()

@end

@implementation WebViewModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ChildViewController:(UIViewController *)_childViewController apiCall:(AppDeckApiCall *)call
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        childViewController = _childViewController;
        self.apicall = call;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDeck *appDeck = [AppDeck sharedInstance];
    self.view.opaque = ![appDeck.loader.conf.app_background_color1 isEqual:[UIColor clearColor]];
    
    container = [[UIView alloc] init];
    [self.view addSubview:container];

    self.view.clipsToBounds = NO;
    container.clipsToBounds = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.webview.delegate = nil;
    self.webview.scrollView.delegate = nil;
    self.webview = nil;
    self.apicall = nil;
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
    childViewController = nil;
}

-(BOOL)getModuleFrame:(CGRect *)frame andSize:(CGSize *)size
{
    NSError *error;
    
    NSString *js = [NSString stringWithFormat:@"var obj = %@; if (obj) JSON.stringify({top: obj.documentOffsetTop, left: obj.documentOffsetLeft, width: obj.offsetWidth, height: obj.offsetHeight, totalWidth: document.body.offsetWidth, totalHeight: document.body.offsetHeight});", self.apicall.jsTarget];
    
    NSLog(@"js: %@", js);
    
/*    NSString *js = @"var obj = document.getElementById('carousel'); if (obj) JSON.stringify({top: obj.documentOffsetTop, left: obj.documentOffsetLeft, width: obj.offsetWidth, height: obj.offsetHeight, totalWidth: document.body.offsetWidth, totalHeight: document.body.offsetHeight});";*/
    NSString *inputJSON = [self.webview stringByEvaluatingJavaScriptFromString:js];
    NSData *inputJSONData = [inputJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tmpinput = nil;
    @try {
        tmpinput = [NSJSONSerialization JSONObjectWithData:inputJSONData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        //tmpinput = [inputJSONData objectFromJSONDataWithParseOptions:JKParseOptionComments|JKParseOptionUnicodeNewlines|JKParseOptionLooseUnicode|JKParseOptionPermitTextAfterValidJSON error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"JSAPI: Exception while reading JSon: %@: %@", exception, inputJSON);
        return NO;
    }
    
    if (error != nil)
    {
        NSLog(@"JSAPI: Error while reading JSon: %@: %@", error, inputJSON);
        return NO;
    }
    
    if ([[tmpinput class] isSubclassOfClass:[NSDictionary class]] == NO)
    {
        NSLog(@"JSAPI: invalid input format: not an object: %@", inputJSON);
        return NO;
    }
    
    NSLog(@"JSPos: %@", tmpinput);
        
    id top = [tmpinput objectForKey:@"top"];
    id left = [tmpinput objectForKey:@"left"];
    id width = [tmpinput objectForKey:@"width"];
    id height = [tmpinput objectForKey:@"height"];

    id totalWidth = [tmpinput objectForKey:@"totalWidth"];
    id totalHeight = [tmpinput objectForKey:@"totalHeight"];
    
    
    if (top == nil || left == nil || width == nil || height == nil || totalWidth == nil || totalHeight == nil)
    {
        NSLog(@"JSAPI: pos MUST have top/left/width/height/totalWidth/totalHeight entries: %@", inputJSON);
        return NO;
    }
    
/*    CGFloat scaleX = self.webview.frame.size.width / [totalWidth floatValue];
    CGFloat scaleY = self.webview.frame.size.height / [totalHeight floatValue];

    NSLog(@"webview scale: %fx%f", scaleX, scaleY);
*/
    frame->origin.x = [left floatValue];
    frame->origin.y = [top floatValue];
    frame->size.width = [width floatValue];
    frame->size.height = [height floatValue];

    size->width = [totalWidth floatValue];
    size->height = [totalHeight floatValue];
    
    return YES;
}

-(void)viewDidLayoutSubviews
{
    CGRect moduleFrame;
    CGSize webViewSize;

    if ([self getModuleFrame:&moduleFrame andSize:&webViewSize] == NO)
        return;
    
    //self.view.frame = self.webview.scrollView.bounds;
    self.view.frame = self.webview.scrollView.frame;
    
    NSLog(@"View: %fx%f - %fx%f", self.view.frame.origin.x, self.view.frame.origin.y,
          self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"webViewSize: %fx%f", webViewSize.width, webViewSize.height);
    NSLog(@"webViewSizeObjC: %fx%f", self.webview.scrollView.contentSize.width,self.webview.scrollView.contentSize.height);
    NSLog(@"webViewSizeObjC: %fx%f", self.webview.scrollView.contentSize.width,self.webview.scrollView.contentSize.height);
    NSLog(@"module frame: %fx%f - %fx%f", moduleFrame.origin.x, moduleFrame.origin.y, moduleFrame.size.width, moduleFrame.size.height);

    CGFloat scaleX = self.view.frame.size.width / webViewSize.width;
    CGFloat scaleY = self.view.frame.size.height / webViewSize.height;
    
    NSLog(@"webview scale: %fx%f", scaleX, scaleY);    
    
    CGRect containerFrame = CGRectMake(moduleFrame.origin.x * scaleX,
                                       moduleFrame.origin.y * scaleY,
                                       moduleFrame.size.width * scaleY,
                                       moduleFrame.size.height * scaleY);
    container.frame = containerFrame;

    NSLog(@"container frame: %fx%f - %fx%f", containerFrame.origin.x, containerFrame.origin.y,
            containerFrame.size.width, containerFrame.size.height);
    
    //[container setContentSize:webViewSize];
    //container.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY);

    //childViewController.view.frame = CGRectMake(0, 0, moduleFrame.size.width, moduleFrame.size.height);
    if (childReady == NO)
    {
        [self addChildViewController:childViewController];
        [container addSubview:childViewController.view];
        childReady = YES;
    }

    if (childViewController)
        childViewController.view.frame = CGRectMake(0, 0, containerFrame.size.width, containerFrame.size.height);
    
    return;
    
    CGRect frame = CGRectMake(0, 0, moduleFrame.size.width, moduleFrame.size.height);
    frame.size.width /= 10;
    frame.size.height /= 10;
    
    redView.frame = frame;
    greenView.frame = frame;
    blueView.frame = frame;
    blackView.frame = frame;
    
    /*
     typedef enum {
     UIViewAlignNone         = 0,
     UIViewAlignLeft         = 1 << 0,
     UIViewAlignCenter       = 1 << 1,
     UIViewAlignRight        = 1 << 2,
     UIViewAlignTop          = 1 << 3,
     UIViewAlignMiddle       = 1 << 4,
     UIViewAlignBottom       = 1 << 5,
     UIViewAlignFullWidth    = 1 << 6,
     UIViewAlignFullHeight   = 1 << 7
     } UIViewAlign;
     */
    
    [redView align:UIViewAlignTop|UIViewAlignLeft];
    [blueView align:UIViewAlignBottom|UIViewAlignLeft];
    [greenView align:UIViewAlignTop|UIViewAlignRight];
    [blackView align:UIViewAlignBottom|UIViewAlignRight];
    
    NSLog(@"redView: %fx%f - %fx%f", redView.frame.origin.x, redView.frame.origin.y, redView.frame.size.width, redView.frame.size.height);
    
    childViewController.view.frame = CGRectMake(0, 0, moduleFrame.size.width, moduleFrame.size.height);
    
}

@end
