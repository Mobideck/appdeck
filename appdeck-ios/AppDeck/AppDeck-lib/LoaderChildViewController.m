//
//  LoaderChildViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "LoaderChildViewController.h"
#import "SwipeViewController.h"
#import "LoaderViewController.h"
#import "GoogleAnalytics/GAI.h"
#import "GoogleAnalytics/GAIDictionaryBuilder.h"
#import "GoogleAnalytics/GAIFields.h"
#import "PopOverWebViewViewController.h"
#import "PhotoBrowserViewController.h"
#import "IOSVersion.h"
#import "AMBlurView.h"

@interface LoaderChildViewController ()

@end

@implementation LoaderChildViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url content:(UIWebView *)content header:(UIWebView *)headerOrNil footer:(UIWebView *)footerOrNil loader:(LoaderViewController *)loader
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.url = url;
        //self.header = headerOrNil;
        //self.footer = footerOrNil;
        //        self.content = content;
        self.loader = loader;
    }
    return self;
}
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.isVisible = YES;

    if (YES)
    {
        if (self.loader.appDeck.iosVersion >= 7.0 && false)
        {
            AMBlurView *blurView = [[AMBlurView alloc] initWithFrame:self.view.bounds];
            blurView.blurTintColor = [UIColor redColor];
            [blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            self.overlay = blurView;
            //self.overlay.backgroundColor = [UIColor blackColor];
        } else {
            self.overlay = [[UIView alloc] initWithFrame:self.view.bounds];
            self.overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            //self.overlay.hidden = YES;
        }
        self.overlay.userInteractionEnabled = NO;
        self.overlay.alpha = 0.0;
        [self.view addSubview:self.overlay];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return [self.loader prefersStatusBarHidden];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.loader preferredStatusBarStyle];
}

-(void)reload
{
    
}

/*
-(void)playPopUpAdVideo
{
    return;
    video = [[PopUpVideoViewController alloc] init];

    [video.view setFrame:CGRectMake(0, 0, 320, 320)];
    
    //video.view.backgroundColor = [UIColor redColor];
    video.view.userInteractionEnabled = NO;
    
    [self.view addSubview:video.view];
}



-(void)playAdVideo
{
    return;
    // video ad test
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource: @"destiny" withExtension:@"mp4"];
    player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    player.scalingMode = MPMovieScalingModeAspectFit;
    player.controlStyle = MPMovieControlStyleNone;
//    player.movieControlMode = MPMovieControlModeHidden;
    [player prepareToPlay];
    [player.view setFrame: self.navigationController.view.bounds];  // player's frame must match parent's
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(myMovieFinishedCallback:)
     name: MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    [player play];
    
    [self.view addSubview:player.view];
    
    [self.navigationController  setNavigationBarHidden:YES animated:YES];
//     [navController setNavigationBarHidden:NO animated:NO];
    //[self.navigationController.view addSubview:player.view];
}

// When the movie is done, release the controller.
-(void) myMovieFinishedCallback: (NSNotification*) aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: theMovie];

    [self.navigationController  setNavigationBarHidden:NO animated:NO];
    
    [player.view removeFromSuperview];
    [self.navigationController.view addSubview:player.view];
    

    
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         player.view.alpha = 0;
                     }
                     completion:^(BOOL finished){


                         [player.view removeFromSuperview];
                         player = nil;
                         
                     }];
    
}
*/
/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

#pragma mark - mainView

-(void)childIsMain:(BOOL)isMain
{
    if (self.loader.globalTracker)
    {
        //NSLog(@"child: %@", self.url.absoluteString);
//        [self.loader.globalTracker sendView:self.url.absoluteString];
        
        // This screen name value will remain set on the tracker and sent with
        // hits until it is set to a new value or to nil.
        [self.loader.globalTracker set:kGAIScreenName value:self.url.absoluteString];
        [self.loader.globalTracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
    }
    if (isMain)
    {
        self.swipeContainer.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
        [self becomeFirstResponder];
    }
    _isMain = isMain;
}

-(void)setIsFullScreen:(BOOL)fullScreen
{
    _isFullScreen = fullScreen;
    if (_isMain)
        [self.swipeContainer adjustFullScreen];
}

#pragma mark - progressEstimateChanged Notification API

- (void)progressEstimateChanged:(NSNotification*)theNotification
{
    //NSLog(@"progressEstimateChanged: %@", theNotification);
    
	// You can get the progress as a float with
	// [[theNotification object] estimatedProgress], and then you
	// can set that to a UIProgressView if you'd like.
	// theProgressView is just an example of what you could do.
    
    float progress = [[theNotification.userInfo objectForKey:@"WebProgressEstimatedProgressKey"] floatValue];
    //    [[theNotification object] performSelector:NSSelectorFromString(@"estimatedProgress")];
    
    if (self.showProgress == NO)
    {
        [self.swipeContainer child:self startProgressWithExpectedProgress:progress inTime:60];
        self.showProgress = YES;
    }
    else
    {
        [self.swipeContainer child:self updateProgressWithProgress:progress duration:0.125];
    }
    
    if (progress == 1)
    {
        [self.swipeContainer child:self endProgressDuration:0.125];
        self.showProgress = NO;
    }
    
    
	//if ((int)[[theNotification object] estimatedProgress] == 1) {
    //		theProgressView.hidden = TRUE;
    // Hide the progress view. This is optional, but depending on where
    // you put it, this may be a good idea.
    // If you wanted to do this, you'd
    // have to set theProgressView to visible in your
    // webViewDidStartLoad delegate method,
    // see Apple's UIWebView documentation.
    //	}
}

#pragma mark - api

-(void)shouldReloadHistory
{
    
}

-(void)load:(NSString *)url
{
    [self.loader loadPage:url];
}

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    call.child = self;
    
    // share ?
    if ([call.command isEqualToString:@"share"])
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        
        if (self.loader.appDeck.iosVersion >= 6.0)
        {
            if ([call.param respondsToSelector:@selector(objectForKey:)])
            {
                NSString *paramTitle = [call.param objectForKey:@"title"];
                NSString *paramURL = [call.param objectForKey:@"url"];
                NSString *paramImageURL = [call.param objectForKey:@"imageurl"];

                __block NSString *title = nil;
                __block NSURL *url = nil;
                __block NSURL *imageUrl = nil;
                
                
                if (paramTitle != nil && paramTitle.length > 0)
                    title = [NSString stringWithFormat:@"%@", paramTitle];
                if (paramURL != nil && paramURL.length > 0)
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", paramURL] relativeToURL:self.url];
                if (paramImageURL != nil && paramImageURL.length > 0)
                    imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@", paramImageURL] relativeToURL:self.url];

                if (paramImageURL == nil)
                {
                    NSMutableArray *dataToShare = [[NSMutableArray alloc] init];
                    if (title)
                        [dataToShare addObject:title];
                    if (url)
                        [dataToShare addObject:url];
                    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
                    if (self.loader.appDeck.iosVersion >= 8.0)
                        activityViewController.popoverPresentationController.sourceView = self.view;
                    [self presentViewController:activityViewController animated:YES completion:^{}];
                    
                } else {
                    __block LoaderChildViewController *me = self;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imageUrl] returningResponse:nil error:nil];
                        UIImage *image = nil;
                        if (data)
                            image = [UIImage imageWithData:data];
                        
                        NSMutableArray *dataToShare = [[NSMutableArray alloc] init];
                        if (title)
                            [dataToShare addObject:title];
                        if (url)
                            [dataToShare addObject:url];
                        if (image)
                            [dataToShare addObject:image];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
                            if (me.loader.appDeck.iosVersion >= 8.0)
                                activityViewController.popoverPresentationController.sourceView = me.view;
                            [me presentViewController:activityViewController animated:YES completion:^{}];
                        });
                        
                    });
                }
                
                
                
                
                // stats
                if (self.loader.tracker)
                {
//                    [self.loader.tracker trackEventWithCategory:@"action" withAction:@"share" withLabel:(url ? url.absoluteString : title) withValue:[NSNumber numberWithInt:1]];
                    [self.loader.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"action"
                                                                                      action:@"share"
                                                                                       label:(url ? url.absoluteString : title)
                                                                                       value:[NSNumber numberWithInt:1]] build]];
                    
                }
//                [self.loader.globalTracker trackEventWithCategory:@"action" withAction:@"share" withLabel:(url ? url.absoluteString : title) withValue:[NSNumber numberWithInt:1]];
                [self.loader.globalTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"action"
                                                                                        action:@"share"
                                                                                         label:(url ? url.absoluteString : title)
                                                                                         value:[NSNumber numberWithInt:1]] build]];
                
            }
        }
        else
            NSLog(@"Not supported in ios 5.0");
#endif
        return YES;
    }
    
    if ([call.command isEqualToString:@"previousnext"])
    {
        
        NSString *previous_page = [call.param objectForKey:@"previous_page"];
        NSString *next_page = [call.param objectForKey:@"next_page"];
        
        if (previous_page != nil && [previous_page respondsToSelector:@selector(isEqualToString:)] && ![previous_page isEqualToString:@"0"] && ![previous_page isEqualToString:@""])
        {
            self.previousUrl = [NSURL URLWithString:previous_page relativeToURL:self.url];
            [self.swipeContainer insertPreviousChildView];
        }
        if (next_page != nil && [next_page respondsToSelector:@selector(isEqualToString:)] && ![next_page isEqualToString:@"0"] && ![next_page isEqualToString:@""])
        {
            self.nextUrl = [NSURL URLWithString:next_page relativeToURL:self.url];
            [self.swipeContainer insertNextChildView];
        }
        return YES;
    }
    
    
    // goto previous/next
    if ([call.command isEqualToString:@"gotoprevious"])
    {
        [self.swipeContainer gotoPrevious:0.0];
        return YES;
    }
    if ([call.command isEqualToString:@"gotonext"])
    {
        [self.swipeContainer gotoNext:0.0];
        return YES;
    }
    
    // popover ?
    if ([call.command isEqualToString:@"popover"])
    {
        NSError *error;
        
        PopOverWebViewViewController *pop = [PopOverWebViewViewController showWithConfig:call.param fromView:self.focus withParent:self error:&error];
        
        if (pop == nil)
        {
            NSLog(@"Popover Error: %@", error);
        }
        
        return YES;
    }
    
    return [self.swipeContainer apiCall:call];
}

/*-(void)setOverlay:(CGFloat)value
{
    overlay.alpha = value;
    overlay.hidden = (value == 0.0);
}*/

/*
-(BOOL)call:(NSString *)command origin:(UIView *)origin
{

 
    return NO;
}*/

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.view bringSubviewToFront:self.overlay];
    
    self.overlay.frame = self.view.bounds;
    
}
/*
-(void)setScreenConfiguration:(ScreenConfiguration *)screenConfiguration
{
    _screenConfiguration = screenConfiguration;
}
*/
@end
