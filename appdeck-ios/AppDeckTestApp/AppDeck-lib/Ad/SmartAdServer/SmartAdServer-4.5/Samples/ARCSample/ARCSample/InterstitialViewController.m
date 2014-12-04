//
//  InterstitialViewController.m
//  ARCSample
//
//  Created by Loïc GIRON DIT METAZ on 16/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "InterstitialViewController.h"


/**
 * The purpose of this sample is to display a simple image interstitial.
 * This interstitial should be clickable and should be automatically released with ARC.
 */
@implementation InterstitialViewController

#pragma mark - Object lifecycle

- (void)dealloc {
	//The interstitial is released automatically by ARC but the delegate should be set to nil to prevent crashes during fast navigation in the application.
	//This can be made in the dealloc method which will be called automatically by ARC when the controller will be released.
	_interstitial.delegate = nil;
	
	NSLog(@"InterstitialViewController has been deallocated");
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Interstitial";
		_statusBarHidden = NO;
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
	//Do not forget to set the delegate to nil before loosing last reference to the interstitial (because the interstitial will be automatically released by ARC)
	_interstitial.delegate = nil;
	
	[self createInterstitial];
}


- (void)createInterstitial {
	//_interstitial is an instance variable with default lifetime qualifier, which means '__strong':
	//the interstitial will be retained by the controller until it is released.
	_interstitial = [[SASInterstitialView alloc] initWithFrame:self.navigationController.view.bounds loader:SASLoaderActivityIndicatorStyleBlack];
	_interstitial.delegate = self;
	[_interstitial loadFormatId:12167 pageId:@"188763" master:YES target:nil];
	
	[self.navigationController.view addSubview:_interstitial];

	[self setStatusBarHidden:YES];
}

#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
	NSLog(@"Interstitial has been loaded");
	[self setStatusBarHidden:YES];
}


- (void)adViewDidFailToLoad:(SASAdView *)adView error:(NSError *)error {
	NSLog(@"Interstitial has failed to load with error: %@", [error description]);
	[self setStatusBarHidden:NO];
}


- (void)adViewDidDisappear:(SASAdView *)adView {
	NSLog(@"Interstitial has disappeared");
	[self setStatusBarHidden:NO];
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
