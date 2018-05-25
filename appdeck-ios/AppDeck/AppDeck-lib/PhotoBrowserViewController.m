//
//  PhotoBrowserViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 16/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "NSError+errorWithFormat.h"
#import "PhotoViewController.h"
#import "NSString+UIColor.h"
#import "PageBarButtonContainer.h"
#import "PageBarButton.h"
#import "SwipeViewController.h"
#import "UIView+align.h"
#import "LoaderViewController.h"
#import "AppDeckAnalytics.h"
#import "IOSVersion.h"

@interface PhotoBrowserViewController ()

@end

@implementation PhotoBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.photos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor blackColor];
    scrollView = [[UIScrollView alloc] init];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    [self initActionButton];
//    PhotoViewController *photo = [self.photos objectAtIndex:startingIndex];
//    [photo loadImage];
    [self viewWillLayoutSubviews];
    self.index = self.startingIndex;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initActionButton
{
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeperator.width = -5;
    [buttons addObject:negativeSeperator];
    
    PageBarButtonContainer *container = [[PageBarButtonContainer alloc] initWithChild:self];
    
    buttonPrevious = [container addButton:@{@"content": @"photo:back", @"icon" : @"!previous"}];
    buttonNext = [container addButton:@{@"content": @"photo:forward", @"icon" : @"!next"}];
    buttonAction = [container addButton:@{@"content": @"photo:share", @"icon" : @"!action"}];
    
    [self checkButton];
    
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:container]];
    
    self.rightBarButtonItems = buttons;
    
    doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    [self.view addGestureRecognizer:tapRecognizer];
/*    if (self.isMain)
        self.swipeContainer.navigationItem.rightBarButtonItems = buttons;*/
    
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (areControlsHidden)
            [self showControls:sender];
        else
            [self hideControls:sender];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        PhotoViewController *photo = [self getCurrentPhoto];
        [photo toggleZoom:sender];
    }
}

-(void)showControls:(id)sender
{
//    [self.loader setFullScreen:NO animation:UIStatusBarAnimationFade];
//    [self.swipeContainer.navigationController setNavigationBarHidden:NO animated:NO];
    self.isFullScreen = NO;
    areControlsHidden = NO;
}


-(void)hideControls:(id)sender
{
//    [self.loader setFullScreen:YES animation:UIStatusBarAnimationFade];
//    [self.swipeContainer.navigationController setNavigationBarHidden:YES animated:NO];
    self.isFullScreen = YES;
    areControlsHidden = YES;
}

- (void)cancelControlHiding
{
	// If a timer exists then cancel and release
	if (controlVisibilityTimer)
    {
		[controlVisibilityTimer invalidate];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay
{
	if (areControlsHidden == NO)
    {
        [self cancelControlHiding];
		controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideControls:) userInfo:nil repeats:NO];
	}
}

-(void)checkButton
{
    if (self.photos.count < 2)
    {
        buttonNext.enabled = NO;
        buttonPrevious.enabled = NO;
        return;
    }
    buttonNext.enabled = YES;
    buttonPrevious.enabled = YES;
    if (scrollView.contentOffset.x <= 0)
        buttonPrevious.enabled = NO;
    if (scrollView.contentOffset.x + scrollView.frame.size.width >= scrollView.contentSize.width)
        buttonNext.enabled = NO;
    NSInteger oldCurrentIndex = currentIndex;
    currentIndex = [self index];
    if (oldCurrentIndex != currentIndex)
    {
        PhotoViewController *photo = [self getCurrentPhoto];
        // stats
//        [self.loader.globalTracker trackEventWithCategory:@"photo" withAction:@"change" withLabel:photo.url.absoluteString withValue:[NSNumber numberWithInt:1]];
        
        [self.loader.analytics sendEventWithName:@"photo" action:@"change" label:photo.url.absoluteString value:[NSNumber numberWithInt:1]];
        
    }
}

-(void)doPhotoChange:(NSInteger)currentPhotoIndex
{
    //NSLog(@"doPhotoChange: %d", currentPhotoIndex);
    // set state of all images
    for (int k = 0; k < self.photos.count; k++)
    {
        PhotoViewController *photo = [self.photos objectAtIndex:k];
        
        if (k == currentPhotoIndex)
            [photo setState:PhotoViewControllerStateOnScreen];
        else if (k == currentPhotoIndex + 1 || k == currentPhotoIndex - 1)
            [photo setState:PhotoViewControllerStateNextScreen];
        else
            [photo setState:PhotoViewControllerStateBackground];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self checkButton];
//    [self doPhotoChange:self.index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self doPhotoChange:self.index];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)_scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.isDecelerating == NO)
    {
        [self doPhotoChange:self.index];
    }
}

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    return [super apiCall:call];
}

-(void)load:(NSString *)url
{
    if ([url hasPrefix:@"photo:back"])
    {
//        CGFloat idx = self.index - 1;
        CGRect rect = CGRectMake(scrollView.contentOffset.x - scrollView.frame.size.width, scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height);
        [scrollView scrollRectToVisible:rect animated:YES];
//        [self doPhotoChange:idx];
        [self doPhotoChange:self.index - 1];
    }
    else if ([url hasPrefix:@"photo:forward"])
    {
        CGRect rect = CGRectMake(scrollView.contentOffset.x + scrollView.frame.size.width, scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height);
        [scrollView scrollRectToVisible:rect animated:YES];
        [self doPhotoChange:self.index + 1];
    }
    else if ([url hasPrefix:@"photo:share"])
    {
        PhotoViewController *photo = [self getCurrentPhoto];
        // stats
        [self.loader.analytics sendEventWithName:@"action" action:@"share" label:photo.url.absoluteString value:[NSNumber numberWithInt:1]];

        AppDeck *appDeck = [AppDeck sharedInstance];
        if (appDeck.iosVersion >= 6.0)
        {
            UIImage *image = [[self getCurrentPhoto] image];
            NSArray *activityItems = @[image];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact ];
            [self presentViewController:activityViewController animated:YES completion:NULL];
        }
    }
    else
        [super load:url];
}

-(void)setIndex:(NSInteger)index
{
//    startingIndex = index;
    scrollView.contentOffset = CGPointMake(index * scrollView.frame.size.width, 0);
    [self doPhotoChange:index];
//    [scrollView scrollRectToVisible:CGRectMake(index * scrollView.contentSize.width, 0, scrollView.contentSize.width, scrollView.contentSize.height) animated:YES];
}

-(NSInteger)index
{
    if (self.photos.count == 0)
        return 0;
    CGFloat width = scrollView.contentSize.width / self.photos.count;
    int idx = scrollView.contentOffset.x / width;
//    int idx = (int)floor(scrollView.contentSize.width / scrollView.frame.size.width);
    
    if (idx < 0 || idx >= self.photos.count)
        idx = 0;
    
    return idx;
}

-(PhotoViewController *)getCurrentPhoto
{
    if (self.photos.count == 0)
        return nil;
    
    return [self.photos objectAtIndex:self.index];
}

-(void)addPhoto:(PhotoViewController *)photo
{
    [self.photos addObject:photo];
    [self checkButton];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    id<UIApplicationDelegate> app = [[UIApplication sharedApplication] delegate];
 
    CGSize screensize = app.window.frame.size;
    if (self.view.bounds.size.width > self.view.bounds.size.height)
        screensize = CGSizeMake(screensize.height, screensize.width);
    
//#ifdef DEBUG_OUTPUT
    NSLog(@"app: %f~%f", screensize.width, screensize.height);
    NSLog(@"view: %fx%f - %f~%f", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    NSLog(@"scrollview: %fx%f - %f~%f", scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
//#endif
    
    [self checkButton];
    
    CGRect frame = self.view.bounds;
/*    frame.origin.y = - (screensize.height - self.view.bounds.size.height);
    frame.size.height = screensize.height;*/
    
    //self.view.frame = frame;

    // detect rotation
    BOOL rotating = scrollView.frame.size.width != frame.size.width && scrollView.frame.size.width != 0;
    //NSLog(@"rotating = %f != %f = %d", scrollView.frame.size.width, frame.size.width, rotating);
    NSInteger save_index = 0;
    if (rotating)
        save_index = self.index;
    
    scrollView.frame = frame;//app.window.frame;
    scrollView.backgroundColor = self.bgColor;


    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * self.photos.count, scrollView.frame.size.height);
    
    CGFloat x = 0;
    
    for (PhotoViewController *photo in self.photos)
    {
        if ([photo.view isDescendantOfView:scrollView] == NO)
        {
            [photo.view removeFromSuperview];
            [photo removeFromParentViewController];
            [scrollView addSubview:photo.view];
            [self addChildViewController:photo];
        }
        photo.view.frame = CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        
        [photo setFullScreen:self.isFullScreen];
        
        x += scrollView.frame.size.width;
    }

    if (rotating)
        self.index = save_index;
    
    if (self.photos.count <= 1)
    {
        buttonNext.hidden = YES;
        buttonPrevious.hidden = YES;
    }
    else
    {
        buttonNext.hidden = NO;
        buttonPrevious.hidden = NO;
    }
}

#pragma mark - load photos

+(PhotoBrowserViewController *)photoBrowserWithConfig:(NSDictionary *)config baseURL:(NSURL *)baseUrl error:(NSError **)error
{
    if (config == nil)
    {
        if (error)
            *error = [NSError errorWithFormat:@"no config set"];
        return nil;
    }
    
    if ([config respondsToSelector:@selector(objectForKey:)] == NO)
    {
        if (error)
            *error = [NSError errorWithFormat:@"argument should be an object: %@", config];
        return nil;
    }

    NSDictionary *images = [config objectForKey:@"images"];
    if (images == nil)
    {
        if (error)
            *error = [NSError errorWithFormat:@"entry 'images' missing: %@", config];
        return nil;
    }

    PhotoBrowserViewController *browser = [[PhotoBrowserViewController alloc] initWithNibName:nil bundle:nil];
    
    for (NSDictionary *image in images)
    {
        if ([image respondsToSelector:@selector(objectForKey:)] == NO)
        {
            if (error)
                *error = [NSError errorWithFormat:@"each images argument should be an object: %@", image];
            return nil;
        }
        
        NSString *url = [image objectForKey:@"url"];
        if (url == nil)
        {
            NSLog(@"entry 'url' missing: %@", image);
            continue;
        }
        NSString *thumbnail = [image objectForKey:@"thumbnail"];
        NSString *caption = [image objectForKey:@"caption"];
        if ([caption isEqualToString:@""])
            caption = nil;
        
        [browser addPhoto:[PhotoViewController photoViewWithUrl:[NSURL URLWithString:url relativeToURL:baseUrl]
                                                     thumbnail:[NSURL URLWithString:thumbnail relativeToURL:baseUrl]
                                                       caption:caption]];
    }
        
    browser.bgColor = [[config objectForKey:@"bgcolor"] toUIColor];
    if (browser.bgColor == nil)
        browser.bgColor = [UIColor blackColor];
    CGFloat alpha = [[config objectForKey:@"bgcolor"] floatValue];
    if (alpha == 0)
        alpha = 0.8;
    browser.bgColor = [browser.bgColor colorWithAlphaComponent:alpha];
    
    NSInteger startIndex = [[config objectForKey:@"startIndex"] intValue];
    if (startIndex < 0 || startIndex >= [images count])
        startIndex = 0;
    
    browser.startingIndex = startIndex;
    
    return browser;
}

@end
