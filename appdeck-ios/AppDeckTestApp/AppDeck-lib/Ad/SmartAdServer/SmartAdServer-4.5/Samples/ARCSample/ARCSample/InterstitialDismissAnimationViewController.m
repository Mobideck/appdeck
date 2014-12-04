//
//  InterstitialDismissAnimationViewController.m
//  ARCSample
//
//  Created by Loïc GIRON DIT METAZ on 16/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "InterstitialDismissAnimationViewController.h"


/**
 * The purpose of this sample is to display a simple image interstitial that will be dismissed with a custom animation.
 * This interstitial should be clickable and should be automatically released with ARC.
 */
@implementation InterstitialDismissAnimationViewController

#pragma mark - Object lifecycle

- (void)dealloc {
	//The interstitial is released automatically by ARC but the delegate should be set to nil to prevent crashes during fast navigation in the application.
	//This can be made in the dealloc method which will be called automatically by ARC when the controller will be released.
	_interstitial.delegate = nil;
	
	NSLog(@"InterstitialDismissAnimationViewController has been deallocated");
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Animation";
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
	//Do not forget to set the delegate to nil before loosing last reference to the interstitial (because
	//the interstitial will be automatically released by ARC)
	_interstitial.delegate = nil;
	
	[self createInterstitial];
}


- (void)createInterstitial {
	//_interstitial is an instance variable with default lifetime qualifier, which means '__strong':
	//the interstitial will be retained by the controller until it is released.
	_interstitial = [[SASInterstitialView alloc] initWithFrame:self.navigationController.view.bounds loader:SASLoaderActivityIndicatorStyleBlack];
	_interstitial.delegate = self;
	[_interstitial loadFormatId:12167 pageId:@"188763" master:YES target:nil];
	
	//The dismissal animation can be added by specifying an animation block
	_interstitial.dismissalAnimations = ^(SASAdView *adView) {
		//Use the block parameter to manipulate the adView (not the _interstitial instance variable)
		adView.frame = CGRectMake(CGRectGetMinX(adView.frame), -CGRectGetHeight(adView.frame), CGRectGetWidth(adView.frame), CGRectGetHeight(adView.frame));
		adView.alpha = 0;
		
		//More informations about using blocks in ARC application in the Apple official documentation
		//http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW9
	};
	
	[self.navigationController.view addSubview:_interstitial];
}

#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
	NSLog(@"Interstitial has been loaded");
}


- (void)adViewDidFailToLoad:(SASAdView *)adView error:(NSError *)error {
	NSLog(@"Interstitial has failed to load with error: %@", [error description]);
}


- (UIViewAnimationOptions)animationOptionsForDismissingAdView:(SASAdView *)adView {
	// This delegate method can be used to set the options used by the animation. A default value will
	// be used if not implemented.
	return UIViewAnimationCurveEaseIn;
}


- (NSTimeInterval)animationDurationForDismissingAdView:(SASAdView *)adView {
	// This delegate method can be used to set the dismissal animation duration. A default value will be
	// used if not implemented.
	return 0.5;
}

@end
