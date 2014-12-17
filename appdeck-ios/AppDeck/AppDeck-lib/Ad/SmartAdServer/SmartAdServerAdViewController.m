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

    if ([self.adType isEqualToString:@"banner"])
    {

    }
    
    if ([self.adType isEqualToString:@"banner"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 768;
        self.height = 128;
        adView = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
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

    adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    adView.delegate = self;
    
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:adView];
    
    [adView loadFormatId:1 pageId:@"1" master:YES target:nil];
    
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

#pragma mark - SmartAdServer delegate

// Notifies the delegate that the expanded ad was closed.
- (void)adView:(SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame
{
    
}

// Notifies the delegate that the resized ad was closed.
- (void)adView:(SASAdView *)adView didCloseResizeWithFrame:(CGRect)frame
{
    
}

// Notifies the delegate that the ad json has been received and fetched and that it will launch its download.
- (void)adView:(SASAdView *)adView didDownloadAd:(SASAd *)ad
{
    
}

// Notifies the delegate that the ad view was expanded.
- (void)adView:(SASAdView *)adView didExpandWithFrame:(CGRect)frame
{
    
}

// Notifies the delegate that the SASAdView failed to download the ad.
- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error
{
    
}

// Notifies the delegate that the SASAdView failed to prefetch the ad in cache.
- (void)adView:(SASAdView *)adView didFailToPrefetchWithError:(NSError *)error
{
    
}

// Notifies the delegate that the ad view received a message from the MRAID creative.
- (void)adView:(SASAdView *)adView didReceiveMessage:(NSString *)message
{
    
}


// Notifies the delegate that the ad view was resized.
- (void)adView:(SASAdView *)adView didResizeWithFrame:(CGRect)frame
{
    
}

// Asks the delegate whether to execute the ad action.
- (BOOL)adView:(SASAdView *)adView shouldHandleURL:(NSURL *)URL
{
    
}

// Notifies the delegate that an ad action has been made (for example the user tapped the ad).
- (void)adView:(SASAdView *)adView willPerformActionWithExit:(BOOL)willExit
{
    
}

// Notifies the delegate that the ad view is about to be resized.
- (void)adView:(SASAdView *)adView willResizeWithFrame:(CGRect)frame
{
    
}

// Notifies the delegate that the SASAdView which displayed an expandable ad did collapse.
- (void)adViewDidCollapse:(SASAdView *)adView
{
    
}

// Notifies the delegate that the SASAdView has been dismissed.
- (void)adViewDidDisappear:(SASAdView *)adView
{
    
}

// Notifies the delegate that the ad view was resized.
- (void)adViewDidFailToResize:(SASAdView *)adView error:(NSError *)error
{
    
}

// Notifies the delegate that the creative from the current ad has been loaded and displayed.
- (void)adViewDidLoad:(SASAdView *)adView
{
    
}

// Notifies the delegate that the creative from the current ad has been prefetched in cache.
- (void)adViewDidPrefetch:(SASAdView *)adView
{
    
}

// Notifies the delegate that the modal view will be dismissed.
- (void)adViewWillDismissModalView:(SASAdView *)adView
{
    
}

// Notifies the delegate that the ad view is about to be expanded.
- (void)adViewWillExpand:(SASAdView *)adView
{
    
}

//Notifies the delegate that a modal view will appear to display the ad’s redirect URL web page if appropriate. This won’t be called in case of URLs which should not be displayed in a browser like YouTube, iTunes,… In this case, it will call adView:shouldHandleURL:.
- (void)adViewWillPresentModalView:(SASAdView *)adView
{
    
}

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
    
}

@end
