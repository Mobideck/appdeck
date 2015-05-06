//
//  PageAdViewController.m
//  SwipeNavigationSample
//
//  Created by Loïc GIRON DIT METAZ on 17/02/2014.
//  Copyright (c) 2014 Smart AdServer. All rights reserved.
//

#import "PageAdViewController.h"
#import "Constants.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@implementation PageAdViewController

#pragma mark - Object lifecycle

- (void)dealloc {
	//The delegate and the modalParentViewController  must be set to nil otherwise the application might crash
	self.banner.delegate = nil;
    self.banner.modalParentViewController = nil;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	CGRect adViewFrame = [self bannerFrameForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
	self.banner.frame = adViewFrame;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Position tunning depending on iOS version
	CGRect adViewFrame = [self bannerFrameForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
	
	//The banner is created and the delegate and the modalParentViewController are set
	//In this case, we use the whole view but it could be implemented using a smaller view on iPad
	self.banner = [[SASBannerView alloc] initWithFrame:adViewFrame loader:SASLoaderActivityIndicatorStyleBlack];
	self.banner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.banner.delegate = self;
    self.banner.modalParentViewController = self;
	
	//The content of the banner is loaded, the banner is added to the controller's view
	[self.banner loadFormatId:kAdFormatId pageId:kAdPageId master:YES target:kAdTarget];
	[self.view addSubview:self.banner];
}


- (CGRect)bannerFrameForOrientation:(UIInterfaceOrientation)interfaceOrientation {
	CGRect adViewFrame = self.view.frame;
	CGFloat topOffset = [self topOffsetForOrientation:interfaceOrientation];
	adViewFrame.origin.y += topOffset;
	adViewFrame.size.height -= topOffset;
	
	return adViewFrame;
}


- (CGFloat)topOffsetForOrientation:(UIInterfaceOrientation)interfaceOrientation {
	CGFloat topOffset = [self navigationBarHeight];
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
		topOffset += [self statusBarHeight];
	} else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
			topOffset += [self statusBarHeight];
		} else {
			topOffset += [self statusBarWidth];
		}
	} else {
		topOffset = 0;
	}
	
	return topOffset;
}


- (CGFloat)statusBarHeight {
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}


- (CGFloat)statusBarWidth {
	return [UIApplication sharedApplication].statusBarFrame.size.width;
}


- (CGFloat)navigationBarHeight {
	return self.navigationController.navigationBar.frame.size.height;
}

#pragma mark - Ad view delegate

- (void)adViewDidLoad:(SASAdView *)adView {
	//The video is stopped by default if the controller is not visible in the page view controller, started otherwise
	if (self.isVisibleInPageViewController) {
		[self startVideo];
	} else {
		[self stopVideo];
	}
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
	//If there is no ad, a placeholder is added in place of the ad
	UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:self.view.frame];
	placeholderLabel.text = [NSString stringWithFormat:@"The ad can't be displayed for the following reason:\n\n%@", [error localizedDescription]];
	placeholderLabel.numberOfLines = 0;
	placeholderLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:placeholderLabel];
}

-(void)adViewWillDismissModalView:(SASAdView *)adView {
    [self startVideo];
}

#pragma mark - Video state handling

- (void)startVideo {
	//The video is started by sending a 'start' message to the creative
	[self.banner sendMessageToWebView:@"start"];
}


- (void)stopVideo {
	//The video is stopped by sending a 'stop' message to the creative
	[self.banner sendMessageToWebView:@"stop"];
}

#pragma mark - Visibility status

- (void)setVisibleInPageViewController:(BOOL)visibleInPageViewController {
	_visibleInPageViewController = visibleInPageViewController;
	
	//When the visibility in the page view controller of the ad view controller changed, the state of the video
	//must be updated (so that the video does not keep playing without being visible)
	if (visibleInPageViewController) {
		[self startVideo];
	} else {
		[self stopVideo];
	}
		
}

@end
