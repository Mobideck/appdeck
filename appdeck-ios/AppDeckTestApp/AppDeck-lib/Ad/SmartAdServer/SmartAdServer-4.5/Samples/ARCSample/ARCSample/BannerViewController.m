//
//  BannerViewController.m
//  ARCSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "BannerViewController.h"


/**
 * The purpose of this sample is to display a simple banner.
 * This banner should be clickable and should be automatically released with ARC.
 */
@implementation BannerViewController

#pragma mark - Object lifecycle

- (void)dealloc {
	//The banner is released automatically by ARC but the delegate should be set to nil to prevent crashes during fast navigation in the application.
	//This can be made in the dealloc method which will be called automatically by ARC when the controller will be released.
	_banner.delegate = nil;
	
	NSLog(@"BannerViewController has been deallocated");
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Banner";
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
	
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self createBanner];
	[self createReloadButton];
}


- (void)createReloadButton {
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleBordered target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = reloadButton;
}


- (void)reload {
	//Do not forget to set the delegate to nil before loosing last reference to the banner (because the banner will be automatically released by ARC)
	_banner.delegate = nil;
	[_banner removeFromSuperview];
	
	[self createBanner];
}


- (void)createBanner {
	//_banner is an instance variable with default lifetime qualifier, which means '__strong':
	//the banner will be retained by the controller until it is released.
	_banner = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 53) loader:SASLoaderActivityIndicatorStyleWhite];
	_banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_banner.delegate = self;
	[_banner loadFormatId:12161 pageId:@"188761" master:YES target:nil];
	
	[self.view addSubview:_banner];
}

#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
	NSLog(@"Banner has been loaded");
}


- (void)adViewDidFailToLoad:(SASAdView *)adView error:(NSError *)error {
	NSLog(@"Banner has failed to load with error: %@", [error description]);
}


- (void)adViewWillExpand:(SASAdView *)adView {
	NSLog(@"Banner will expand");
	[self setStatusBarHidden:YES];
}


- (void)adView:(SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame {
	NSLog(@"Banner did close expand");
	[self setStatusBarHidden:NO];
}

#pragma mark - iOS 7+ status bar handling

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
