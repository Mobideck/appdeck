//
//  ViewController.m
//  Prefetch
//
//  Created by Julien Stoeffler on 14/03/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "SASBannerView.h"
#import "SASInterstitialView.h"

#define kInterstitialFormatID	12167
#define kBannerFormatID			12161
#define kBannerPageID			@"240851"
#define kInterstitialPageID		@"297754"


@implementation ViewController

#pragma mark - Deallocation

- (void)dealloc {
    // Do not forget to release all SASAdView instances properly (including the delegate)
    
    self.prefetchedStartupInterstitial.delegate = nil;
    self.prefetchedStartupInterstitial = nil;
    
    self.banner.delegate = nil;
    self.banner = nil;

    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    ((AppDelegate *) [[UIApplication sharedApplication] delegate]).viewController = self;
    
    // Disable fullscreen mode in iOS 7 (no content under navigation bar)
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Both the banner and the prefetched interstitial are loaded at startup
    [self loadInterstitial];
    [self loadBanner];
    
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    ((AppDelegate *) [[UIApplication sharedApplication] delegate]).viewController = nil;
}

#pragma mark - Ad management

- (void)loadBanner {
    if (_banner) {
        [self.banner removeFromSuperview];
        self.banner = nil;
    }
    
    // Banners cannot use prefetched ad
    [self.banner loadFormatId:kBannerFormatID pageId:kBannerPageID master:NO target:nil];
    [self.view sendSubviewToBack:self.banner];
}


- (SASBannerView *)banner {
    if(!_banner) {        
        _banner = [[SASBannerView alloc] initWithFrame:CGRectMake(.0, .0, CGRectGetMaxX(self.view.frame), 53)
												loader:SASLoaderActivityIndicatorStyleBlack];
        _banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _banner.delegate = self;
        [self.view addSubview:_banner];
    }
    return _banner;
}


- (void)loadInterstitial {
	if (_prefetchedStartupInterstitial) {
		// Release of the old interstitial if it already exists
        [self.prefetchedStartupInterstitial removeFromSuperview];
        self.prefetchedStartupInterstitial.delegate = nil;
        self.prefetchedStartupInterstitial = nil;
    }
    
    // You should use the dedicated prefetch loading method for prefetch interstitials as this will:
    // - Check if an ad is already on the disk
    // - Display it if available
    // - Download an ad from the server and store it on the disk
    [self.prefetchedStartupInterstitial prefetchFormatId:kInterstitialFormatID pageId:kInterstitialPageID master:YES target:nil];
}


- (SASInterstitialView *)prefetchedStartupInterstitial {
    if (!_prefetchedStartupInterstitial) {
		CGRect interstitialFrame = CGRectMake(.0, .0, CGRectGetWidth(self.navigationController.view.frame), CGRectGetHeight(self.navigationController.view.frame));
		
		// The interstitial is created with a loader
        _prefetchedStartupInterstitial = [[SASInterstitialView alloc] initWithFrame:interstitialFrame loader:SASLoaderActivityIndicatorStyleBlack];
		
        _prefetchedStartupInterstitial.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		// Set a ViewController instance as the delegate, so that it will notify changes to this instance in its life cycle
        _prefetchedStartupInterstitial.delegate = self;
		
		// Add the view to the navigationController, so that it stays fullscreen
        [self.navigationController.view addSubview:_prefetchedStartupInterstitial];
		
		// Hide the status bar
        [self setStatusBarHidden:YES];
    }
    return _prefetchedStartupInterstitial;
}

#pragma mark - SASAdViewDelegate delegate

- (void)adViewDidLoad:(SASAdView *)adView {
    if (adView == self.prefetchedStartupInterstitial) {
		NSLog(@"[SASInterstitialView] adViewDidLoad:");
		[self setStatusBarHidden:YES];
    }
}


- (void)adViewDidDisappear:(SASAdView *)adView {
    if (adView == self.prefetchedStartupInterstitial) {
        NSLog(@"[SASInterstitialView] adViewDidDisappear:");
        [self setStatusBarHidden:NO];
    }
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    if (adView == self.prefetchedStartupInterstitial) {
        NSLog(@"[SASInterstitialView] adView:didFailToLoadWithError: %@", [error description]);
        [self setStatusBarHidden:NO];
    }
}


- (void)adViewWillPresentModalView:(SASAdView *)adView {
    if (adView == self.prefetchedStartupInterstitial) {
    }
}


- (void)adViewDidPrefetch:(SASAdView *)adView {
    if (adView == self.prefetchedStartupInterstitial) {
        NSLog(@"[SASInterstitialView] adViewDidPrefetch:");
    }
}


- (void)adView:(SASAdView *)adView didFailToPrefetchWithError:(NSError *)error {
    if (adView == self.prefetchedStartupInterstitial) {
        NSLog(@"[SASInterstitialView] adView:didFailToPrefetchWithError: %@", [error description]);
    }
}

#pragma mark - iOS 7 status bar handling

- (void)setStatusBarHidden:(BOOL)hidden {
    _statusBarHidden = hidden;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}


- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden || [super prefersStatusBarHidden];
}

@end
