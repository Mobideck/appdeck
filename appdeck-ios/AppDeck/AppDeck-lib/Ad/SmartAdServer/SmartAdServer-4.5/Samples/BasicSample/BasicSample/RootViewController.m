//
//  RootViewController.m
//  Sample
//
//  Created by Julien Stoeffler on 07/07/11.
//  Copyright 2011 Smart AdServer. All rights reserved.
//

#import "RootViewController.h"
#import "SASBannerView.h"


#define kBannerFormatID 12161
#define kToasterFormatID 12175
#define kPageID @"185330"

#define kBannerHeight 53
#define kToasterTriggerHeight 20

#define kBannerTitle @"Banner"
#define kToasterTitle @"Toaster"


@interface RootViewController ()

@property (nonatomic, retain) UIActivityIndicatorView *indicator;

@end

@implementation RootViewController
@synthesize topBanner = _topBanner;

#pragma mark - Object lifecycle

- (void)dealloc {
	self.indicator = nil;
	self.tableView.delegate = nil;
	self.tableView = nil;

    // Don't forget to set the delegate to nil
    self.topBanner.delegate = nil;
    self.topBanner = nil;
	
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Banner + Toaster";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	_isToaster = NO;
	[self displayTopBanner];
	[self configureTableView];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:_indicator];
	[_indicator release];
	self.navigationItem.rightBarButtonItem = barButton;
}


- (void)configureTableView {
	CGRect tableViewHeight = CGRectMake(0, kBannerHeight, CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame) - kBannerHeight);
	_tableView = [[[UITableView alloc] initWithFrame:tableViewHeight] retain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_tableView];
	[self.view insertSubview:_tableView belowSubview:_topBanner];
	[_tableView reloadData];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Ad lifecycle

- (void)displayTopBanner {
    
    // We properly remove the old banner/toaster before loading the new one
    if (self.topBanner != nil) {
        [self.topBanner removeFromSuperview];
        self.topBanner.delegate = nil;
        self.topBanner = nil;
    }

    // We create the banner with a white activity indicator as the loader.
    // This loader is usually not visible if the user has a wifi connection because the ad loading is faster.
    // The standard recommended size for a banner is full-width and 53-pixel high.
    SASBannerView *topBanner = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), kBannerHeight)
                                                             loader:SASLoaderActivityIndicatorStyleWhite];
    self.topBanner = topBanner;
    [topBanner release];
	
    // In this example, we  display a banner or toaster, so we need to set this for the toaster. The default value is YES.
	// However, a traffic manager can program an expandable format on this placement without the developer knowing so you should anticipate by always specifying this.
    _topBanner.expandsFromTop = YES;
    
    // We set this view controller as the delegate to support clicks and to be warned by the ad events such as its loading success or failure.
    _topBanner.delegate = self;
    
    // We ask the view to call an ad, without any timeout. We don't want a timeout in this case because the banner doesn't block the application,
	// so it's not necessary to remove it when the connection is bad, we can wait.
    [_topBanner loadFormatId:kBannerFormatID pageId:kPageID master:NO target:nil];
	
    // Here we add the view to self.view
	// If you work with a tableview, you can also put the banner in the tableview's header view
	[self.view addSubview:_topBanner];
}


- (void)loadTopBannerWithFormatID:(NSInteger)formatID {
	_isToaster = (formatID == kToasterFormatID) ? YES : NO;
    [self displayTopBanner];
	
	// To replace the elements there are 2 ways of doing it depending on wether or not you know
	// if the formatID of the ad you want to display is a toaster or banner and which size the trigger is
	// If you do know, you can put the right height right now like this:
	NSInteger height = _isToaster ? kToasterTriggerHeight : kBannerHeight;
	
	// If you don't know, you should set the right frame in the adView:didDownloadAdData: delegate method,
	// but nonetheless set it to the banner height temporarily to avoid a display 
//	NSInteger height = kBannerHeight;
	[self replaceElementsWithAdHeight:height];
	
	[_topBanner loadFormatId:formatID pageId:kPageID master:NO target:nil];
	[_indicator startAnimating];
}


- (void)replaceElementsWithAdHeight:(CGFloat)height {
	_topBanner.frame = CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), height);
	self.tableView.frame = CGRectMake(0, height, CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame) - height);
}

#pragma mark - SASAdViewDelegate

- (void)adViewDidLoad:(SASAdView *)adView {

	// The ad is loaded and will be displayed
	if (adView == self.topBanner) {
		 [_indicator stopAnimating];
	}
}


- (void)adView:(SASAdView *)adView didDownloadAd:(SASAd *)ad {

	if (adView == _topBanner) {
		NSInteger height = _isToaster ? kToasterTriggerHeight : kBannerHeight;
		[self replaceElementsWithAdHeight:height];
	}
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
	
	// Check which instance adView is referring to if you have several ad views
    if (adView == self.topBanner) {
        // Here you can customize what you want to happen in case of failure
        // In this case, we simply remove the view
        [self.topBanner removeFromSuperview];
		self.tableView.frame = self.view.frame;
		[_indicator stopAnimating];
    }
}


- (void)adViewDidDisappear:(SASAdView *)adView {
	
	// Put your table view in place on top of the view
	if (adView == self.topBanner) {
		self.tableView.frame = self.view.frame;
	}
}

#pragma mark - UITableView related Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return .0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell autorelease];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = kBannerTitle;
	} else {
        cell.textLabel.text = kToasterTitle;
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger formatID = (indexPath.row == 0) ? kBannerFormatID : kToasterFormatID;
	[self loadTopBannerWithFormatID:formatID];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
