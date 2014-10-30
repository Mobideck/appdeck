//
//  iCarouselWebViewModuleViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 20/06/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "iCarouselWebViewModuleViewController.h"
#import "PhotoViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDeck.h"
#import "AppURLCache.h"
#import "LoaderChildViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface iCarouselItem : NSObject

@property (nonatomic, retain)   UIWebView *webview;
@property (nonatomic, retain)   NSString *action;

@end

@implementation iCarouselItem

@end

@interface iCarouselWebViewModuleViewController ()

@end

@implementation iCarouselWebViewModuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    for (ManagedUIWebViewController *content in items)
    {
        [content.view removeFromSuperview];
        [content clean];
    }
    items = nil;
    [carousel removeFromSuperview];
    carousel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    self.view.backgroundColor = [UIColor clearColor];
	self.view.opaque = NO;
    
    NSLog(@"options for carousel: %@", self.options);

    items = [NSMutableArray array];
    
    for (NSDictionary *item in [self.options objectForKey:@"children"])
    {
        NSURL *url = [NSURL URLWithString:[item objectForKey:@"src"] relativeToURL:self.apicall.baseURL];
        
        if (url == nil)
            continue;
        
        UIWebView *webview = [[UIWebView alloc] init];
        webview.scrollView.showsHorizontalScrollIndicator = NO;
        webview.scrollView.showsVerticalScrollIndicator = NO;
        webview.scrollView.alwaysBounceVertical = NO;
        webview.scrollView.alwaysBounceHorizontal = NO;
        webview.scrollView.scrollEnabled = NO;
        webview.scrollView.scrollsToTop = NO;
        webview.scrollView.backgroundColor = [UIColor clearColor];
        webview.backgroundColor = [UIColor clearColor];
        webview.scalesPageToFit = YES;
        webview.opaque = NO;
        webview.scrollView.userInteractionEnabled = NO;
        webview.userInteractionEnabled = NO;
        
        //webview.layer.shadowColor = [[UIColor blackColor] CGColor];
        //webview.layer.shadowOpacity = 0.5;
//        webview.userInteractionEnabled ;
//        webview.scrollView.userInteractionEnabled = NO;
        [webview loadRequest:[NSURLRequest requestWithURL:url]];

        iCarouselItem *carouselItem = [[iCarouselItem alloc] init];
        carouselItem.webview = webview;
        carouselItem.action = [item objectForKey:@"onclick"];
        
        [items addObject:carouselItem];
        /*
        continue;
        
        ManagedUIWebViewController *content = [[ManagedUIWebViewController alloc] initWithNibName:nil bundle:nil];
        content.view.frame = self.view.frame;
        content.delegate = self;
        
        //    content.view.frame = self.view.frame;
        content.webView.scrollView.showsHorizontalScrollIndicator = NO;
        content.webView.scrollView.showsVerticalScrollIndicator = NO;
        content.webView.scrollView.alwaysBounceVertical = NO;
        content.webView.scrollView.alwaysBounceHorizontal = NO;
        content.webView.scrollView.scrollEnabled = NO;
        content.webView.scrollView.scrollsToTop = NO;
        [content setChromeless:YES];
        //content.webView.scalesPageToFit = YES;
        [content.webView setBackgroundColor:[UIColor clearColor]];
        content.webView.opaque = NO;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        
        AppDeck *app = [AppDeck sharedInstance];
        
        NSDate *date = nil;
        if ([app.cache requestIsInCache:[NSURLRequest requestWithURL:url] date:&date] == YES)
        {
            request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
            NSCachedURLResponse *cachedResponse = [app.cache cachedResponseForRequest:request];
            [content loadRequest:request withCachedResponse:cachedResponse progess:^(float progress){ } completed:^(NSError *error) { }];
        }
        else
            [content loadRequest:request progess:^(float progress){} completed:^(NSError *error){
            
                //NSLog(@"load OK: %@", error);
            
            }];

        
        [items addObject:content];*/
    }
    

    
    [self initCarousel];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)apiCall:(AppDeckApiCall *)call
{
    return NO;
}

- (BOOL)managedUIWebViewController:(ManagedUIWebViewController *)managedUIWebViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

#pragma mark -
#pragma mark iCarousel methods

-(void)initCarousel
{
    /*
     iCarouselTypeLinear = 0,
     iCarouselTypeRotary,
     iCarouselTypeInvertedRotary,
     iCarouselTypeCylinder,
     iCarouselTypeInvertedCylinder,
     iCarouselTypeWheel,
     iCarouselTypeInvertedWheel,
     iCarouselTypeCoverFlow,
     iCarouselTypeCoverFlow2,
     iCarouselTypeTimeMachine,
     iCarouselTypeInvertedTimeMachine,
     iCarouselTypeCustom
     */
 	//create carousel
	carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
	carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    carousel.type = iCarouselTypeWheel;//iCarouselTypeCoverFlow2;
	carousel.delegate = self;
	carousel.dataSource = self;
    carousel.decelerationRate = 0.0;
	//add carousel to view
	[self.view addSubview:carousel];
    self.view.clipsToBounds = NO;
    
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    iCarouselItem *carouselItem = [items objectAtIndex:index];
    return carouselItem.webview;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    iCarouselItem *carouselItem = [items objectAtIndex:index];
    if (carouselItem.action)
        [self.apicall.child load:carouselItem.action];
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value;// * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionArc:
        {
            return M_PI / 2;
        }
        default:
        {
            return value;
        }
    }
}

-(void)viewDidLayoutSubviews
{
    NSLog(@"Carousel: %fx%f - %fx%f", self.view.bounds.origin.x, self.view.bounds.origin.y,
          self.view.bounds.size.width, self.view.bounds.size.height);
    if (carousel == nil)
        [self initCarousel];
    
    carousel.frame = self.view.bounds;
    
/*    for (ManagedUIWebViewController *content in items)
    {
        content.view.frame = self.view.bounds;
    }*/
    CGRect frame = self.view.bounds;//CGRectMake(1, 1, self.view.bounds.size.width - 2, self.view.bounds.size.height - 2);
    for (iCarouselItem *item in items)
    {
        item.webview.frame = frame;//self.view.bounds;
    }
    
    [carousel reloadData];
        
}

@end
