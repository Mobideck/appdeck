//
//  ToasterViewController.m
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 16/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "ToasterViewController.h"


/**
 * The purpose of this sample is to display a simple toaster.
 * Displaying a toaster works the same way as the banner (and actually use a SASBannerView), 
 * except that more delegate methods are available.
 * This toaster should be clickable and should be automatically released with ARC.
 */
@implementation ToasterViewController

#pragma mark - Object lifecycle

- (void)dealloc {
	//The toaster is released automatically by ARC but the delegate and the modalParentViewController should be set to nil to prevent crashes during fast navigation in the application.
	//This can be made in the dealloc method which will be called automatically by ARC when the controller will be released.
    _toaster.delegate = nil;
    _toaster.modalParentViewController = nil;
	
	NSLog(@"ToasterViewController has been deallocated");
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Toaster";
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
	
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self createToaster];
	[self createReloadButton];
}


- (void)createReloadButton {
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleBordered target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = reloadButton;
}


- (void)reload {
	//Do not forget to set the delegate and the modalParentViewController to nil before loosing last reference to the toaster (because the toaster will be automatically released by ARC)
    _toaster.delegate = nil;
    _toaster.modalParentViewController = nil;
	[_toaster removeFromSuperview];
	
	[self createToaster];
}


- (void)createToaster {
	//_toaster is an instance variable with default lifetime qualifier, which means '__strong':
	//the toaster will be retained by the controller until it is released.
	_toaster = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 53)];
	_toaster.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _toaster.delegate = self;
    _toaster.modalParentViewController = self;
	_toaster.expandsFromTop = YES; //set to YES if the toaster is on the top of the parent view
	[_toaster loadFormatId:12161 pageId:@"188762" master:YES target:nil];
	
	[self.view addSubview:_toaster];
}

#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
	NSLog(@"Toaster has been loaded");
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
	NSLog(@"Toaster has failed to load with error: %@", [error description]);
}


- (void)adViewDidCollapse:(SASAdView *)adView {
	NSLog(@"Toaster has been collapsed");
}


- (void)adViewWillExpand:(SASAdView *)adView {
	NSLog(@"Toaster will expand");
	[self setStatusBarHidden:YES];
}


- (void)adView:(SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame {
	NSLog(@"Toaster did close expand");
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
