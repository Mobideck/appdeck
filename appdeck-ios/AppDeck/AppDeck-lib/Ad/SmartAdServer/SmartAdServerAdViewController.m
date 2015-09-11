//
//  WideSpaceBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "SmartAdServerAdViewController.h"
#import "SmartAdServerAdEngine.h"
#import "../../LoaderChildViewController.h"
#import "../../AppDeck.h"
#import "../../AppDeckUserProfile.h"
#import "../../AdManager.h"

@interface SmartAdServerAdViewController ()

@end

@implementation SmartAdServerAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(SmartAdServerAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.adType isEqualToString:@"banner"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 768;
        self.height = 128;
        adView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        //adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    else if ([self.adType isEqualToString:@"banner"])
    {
        self.width = 320;
        self.height = 53;
        adView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) loader:SASLoaderNone];
    }
    else if ([self.adType isEqualToString:@"rectangle"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 300;
        self.height = 300;
        adView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) loader:SASLoaderNone];
    }
    else if ([self.adType isEqualToString:@"rectangle"])
    {
        self.width = 320;
        self.height = 320;
        adView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) loader:SASLoaderNone];
    }
    else if ([self.adType isEqualToString:@"interstitial"])
    {
        self.width = 320;
        self.height = 480;
        adView = [[SASInterstitialView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) loader:SASLoaderNone];
    }
    
    // The modalParentViewController must be a view controller since it will be used to display the post click modal view
//    adView.modalParentViewController = self.page;

    //adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    adView.delegate = self;
    
//    self.view.clipsToBounds = YES;
    
    if ([self.adType isEqualToString:@"banner"])
    {
        [adView loadFormatId:self.adEngine.formatBannerID.intValue pageId:self.adEngine.pageID master:YES target:nil];
    }
    else if ([self.adType isEqualToString:@"rectangle"])
    {
        [adView loadFormatId:self.adEngine.formatRectangleID.intValue pageId:self.adEngine.pageID master:YES target:nil];
    }
    else if ([self.adType isEqualToString:@"interstitial"])
    {
        [adView loadFormatId:self.adEngine.formatinterstitialID.intValue pageId:self.adEngine.pageID master:YES target:nil];
    }

//    [self.view addSubview:adView];

//    if ([self.adType isEqualToString:@"interstitial"])
//        [adView prefetchAd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    adView.delegate = nil;
//    [adView closeAd];
 //   [adView stop];
    [adView removeFromSuperview];
    adView = nil;
}

-(void)dealloc
{
    [self cancel];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
 
    NSLog(@"AdViewController: %f - %f - %f", self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"AdView: %f - %f - %f", adView.frame.origin.x, adView.frame.size.width, adView.frame.size.height);
    
//    self.view.frame = self.view.bounds;
    
    adView.frame = self.view.bounds;//CGRectMake((self.view.frame.size.width - self.width) / 2, (self.view.frame.size.height - self.height) / 2, self.width, self.height);
}

#pragma mark - SmartAdServer delegate

// Notifies the delegate that the expanded ad was closed.
- (void)adView:(SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame
{
    self.state = AppDeckAdStateClose;
}

// Notifies the delegate that the resized ad was closed.
- (void)adView:(SASAdView *)adView didCloseResizeWithFrame:(CGRect)frame
{
    self.state = AppDeckAdStateClose;
}

// Notifies the delegate that the ad json has been received and fetched and that it will launch its download.
- (void)adView:(SASAdView *)adView didDownloadAd:(SASAd *)ad
{
//    self.width = ad.landscapeSize;
    if (ad.portraitSize.height > 0 && ad.portraitSize.width > 0)
    {
        self.height = ad.portraitSize.height;
        self.width = ad.portraitSize.width;
    }
}

// Notifies the delegate that the ad view was expanded.
- (void)adView:(SASAdView *)adView didExpandWithFrame:(CGRect)frame
{
    
}

// Notifies the delegate that the SASAdView failed to download the ad.
- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error
{
    self.state = AppDeckAdStateFailed;
}

// Notifies the delegate that the SASAdView failed to prefetch the ad in cache.
- (void)adView:(SASAdView *)adView didFailToPrefetchWithError:(NSError *)error
{
    self.state = AppDeckAdStateFailed;
}

// Notifies the delegate that the ad view received a message from the MRAID creative.
- (void)adView:(SASAdView *)adView didReceiveMessage:(NSString *)message
{
    
}


// Notifies the delegate that the ad view was resized.
- (void)adView:(SASAdView *)adView didResizeWithFrame:(CGRect)frame
{
    self.width = frame.size.width;
    self.height = frame.size.height;
//    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.height);
}

/*
// Asks the delegate whether to execute the ad action.
- (BOOL)adView:(SASAdView *)adView shouldHandleURL:(NSURL *)URL
{
    
}*/

// Notifies the delegate that an ad action has been made (for example the user tapped the ad).
- (void)adView:(SASAdView *)adView willPerformActionWithExit:(BOOL)willExit
{
    self.state = AppDeckAdStateClose;
}

// Notifies the delegate that the ad view is about to be resized.
- (void)adView:(SASAdView *)adView willResizeWithFrame:(CGRect)frame
{
    self.width = frame.size.width;
    self.height = frame.size.height;
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.height);
}

// Notifies the delegate that the SASAdView which displayed an expandable ad did collapse.
- (void)adViewDidCollapse:(SASAdView *)adView
{
   
}

// Notifies the delegate that the SASAdView has been dismissed.
- (void)adViewDidDisappear:(SASAdView *)adView
{
    self.state = AppDeckAdStateClose;
}

// Notifies the delegate that the ad view was resized.
- (void)adViewDidFailToResize:(SASAdView *)adView error:(NSError *)error
{
    self.state = AppDeckAdStateClose;

}

// Notifies the delegate that the creative from the current ad has been loaded and displayed.
- (void)adViewDidLoad:(SASAdView *)myAdView
{
    [self.view addSubview:myAdView];
    self.width = adView.frame.size.width;
    self.height = adView.frame.size.height;
    //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.height);
//    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, adView.frame.size.width, adView.frame.size.height);
    self.state = AppDeckAdStateReady;
}

// Notifies the delegate that the creative from the current ad has been prefetched in cache.
- (void)adViewDidPrefetch:(SASAdView *)adView
{
    
}

// Notifies the delegate that the modal view will be dismissed.
- (void)adViewWillDismissModalView:(SASAdView *)adView
{
//    if ([self.adType isEqualToString:@"interstitial"])
        self.state = AppDeckAdStateClose;
}

// Notifies the delegate that the ad view is about to be expanded.
- (void)adViewWillExpand:(SASAdView *)adView
{
    
}

//Notifies the delegate that a modal view will appear to display the ad’s redirect URL web page if appropriate. This won’t be called in case of URLs which should not be displayed in a browser like YouTube, iTunes,… In this case, it will call adView:shouldHandleURL:.
- (void)adViewWillPresentModalView:(SASAdView *)adView
{
    
}
/*
// Returns the animations used to dismiss the ad view.
- (NSTimeInterval)animationDurationForDismissingAdView:(SASAdView *)adView
{
    
}


// Returns the animations used to dismiss the ad view.
- (UIViewAnimationOptions)animationOptionsForDismissingAdView:(SASAdView *)adView
{
    
}

// Asks the delegate for a View Controller to manage the modal view that displays the redirect URL.
- (UIViewController *)viewControllerForAdView:(SASAdView *)adView
{
    
}*/

@end
