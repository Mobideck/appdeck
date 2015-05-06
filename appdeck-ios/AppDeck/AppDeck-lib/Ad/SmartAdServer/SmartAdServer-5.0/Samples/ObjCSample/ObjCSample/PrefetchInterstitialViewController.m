//
//  PrefetchInterstitialViewController.m
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 21/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "PrefetchInterstitialViewController.h"


/**
 * The purpose of this sample is to display a simple prefeteched image interstitial.
 * The integration of an prefetched interstitial is quite similar to the integration of a regular
 * interstitial, only the load ad method is different.
 * This interstitial should be clickable only when WiFi is available and should be automatically released with ARC.

 * Note: the SDK can only handle one prefetch placement per application.
 */
@implementation PrefetchInterstitialViewController

#pragma mark - Object lifecycle

- (void)dealloc {
	//The interstitial is released automatically by ARC but the delegate and the modalParentViewController should be set to nil to prevent crashes during fast navigation in the application.
	//This can be made in the dealloc method which will be called automatically by ARC when the controller will be released.
    _interstitial.delegate = nil;
    _interstitial.modalParentViewController = nil;
	
	NSLog(@"PrefetchInterstitialViewController has been deallocated");
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Prefetch";
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
	
    return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	[self createLoadButton];
}


- (void)createLoadButton {
	UIBarButtonItem *loadButton = [[UIBarButtonItem alloc] initWithTitle:@"Load" style:UIBarButtonItemStyleBordered target:self action:@selector(load)];
	self.navigationItem.rightBarButtonItem = loadButton;
}


- (void)load {
	//Do not forget to set the delegate and the modalParentViewController to nil before loosing last reference to the interstitial (because
	//the interstitial will be automatically released by ARC)
    _interstitial.delegate = nil;
    _interstitial.modalParentViewController = nil;
	
	[self createInterstitial];
}


- (void)createInterstitial {
	// _interstitial is an instance variable with a default lifetime qualifier, which means '__strong':
	//the interstitial will be retained by the controller until it is released.
	_interstitial = [[SASInterstitialView alloc] initWithFrame:self.navigationController.view.bounds loader:SASLoaderActivityIndicatorStyleBlack];
    _interstitial.delegate = self;
    _interstitial.modalParentViewController = self;
	
	//The only difference between a standard interstitial and a prefetched interstitial from an implementation point of view is the method called to download the ad.
	[_interstitial prefetchFormatId:12167 pageId:@"297754" master:YES target:nil];
	//A call to prefetchFormatId:pageId:master:target: will:
	// 1) Check if an ad is available in the application sandbox
	// 2) Display it if available
	// 3) Try to download a new ad from the server and store it in the sandbox if successful (no delegates are triggered when the ad loading is finished)
	
	[self.navigationController.view addSubview:_interstitial];
}

#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
	NSLog(@"Interstitial has been loaded");
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
	NSLog(@"Interstitial has failed to load with error: %@", [error description]);
}

@end
