//
//  ViewController.m
//  TableViewSample
//
//  Created by Loïc GIRON DIT METAZ on 08/07/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "MainViewController.h"
#import "SASBannerView.h"


#define kNumberOfCells				30
#define kDefaultCellHeight			40.0
#define kDefaultBannerCellHeight	50.0

#define kHeaderAdViewRow			0
#define kContentAdViewRow			15
#define kFooterAdViewRow			(kNumberOfCells - 1)

#define kPageID						@"(tableview)"
#define kFormatID					15140


@implementation MainViewController

- (void)dealloc {
	//All the banners created must be released properly, delegates and modalParentViewControllers must be set to nil to avoid crashes during fast navigation
	self.headerCellBanner.delegate = nil;
    self.headerCellBanner.modalParentViewController = nil;
	self.headerCellBanner = nil;
	
    self.contentCellBanner.delegate = nil;
    self.contentCellBanner.modalParentViewController = nil;
	self.contentCellBanner = nil;
	
    self.footerCellBanner.delegate = nil;
    self.footerCellBanner.modalParentViewController = nil;
	self.footerCellBanner = nil;
	
	[super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfCells;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Because this sample supports resizable MRAID 2.0 banners, the size of cell containing banners can be dynamically
	// changed during the view lifecycle
	// The delegate method should return the actual size of each banner cell if available, the default size otherwise.
	//
	// If resizable banners are not used, a generic size can be returned for every banner
	if (indexPath.row == kHeaderAdViewRow) {
        return (CGRectGetMaxY(_headerCellBanner.frame) != 0) ? CGRectGetMaxY(_headerCellBanner.frame) : kDefaultBannerCellHeight;
    } else if (indexPath.row == kContentAdViewRow) {
        return (CGRectGetMaxY(_contentCellBanner.frame) != 0) ? CGRectGetMaxY(_contentCellBanner.frame) : kDefaultBannerCellHeight;
    } else if (indexPath.row == kFooterAdViewRow) {
        return (CGRectGetMaxY(_footerCellBanner.frame) != 0) ? CGRectGetMaxY(_footerCellBanner.frame) : kDefaultBannerCellHeight;
    } else {
		return kDefaultCellHeight;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *labelCellIdentifier = @"labelCell";
	
	// Each banner cell should use a different cell identifier
	// Since an adView cannot be removed from its superview and added as a subview to another view, using a pool
	// of adviews added dynamically to a cell is not recommanded, except if you want to create a new adView
	// for each display
    static NSString *headerBannerCellIdentifier = @"headerBannerCell";
    static NSString *contentBannerCellIdentifier = @"contentBannerCell";
    static NSString *footerBannerCellIdentifier = @"footerBannerCell";
	
	// For each cell, a banner view must be created and added to the cell's view. Do not forget to keep a reference to the
	// ad view to be able to release the delegate properly
    if (indexPath.row == kHeaderAdViewRow) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerBannerCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerBannerCellIdentifier] autorelease];
		}
		[self displayBanner:&_headerCellBanner inTableViewCell:cell];

		return cell;
    } else if (indexPath.row == kContentAdViewRow) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contentBannerCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentBannerCellIdentifier] autorelease];
		}
		[self displayBanner:&_contentCellBanner inTableViewCell:cell];
		
		return cell;
    } else if (indexPath.row == kFooterAdViewRow) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:footerBannerCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:footerBannerCellIdentifier] autorelease];
		}
		[self displayBanner:&_footerCellBanner inTableViewCell:cell];

		return cell;
    } else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:labelCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:labelCellIdentifier] autorelease];
		}
        [cell.textLabel setText:[NSString stringWithFormat:@"Cell %d", (int)indexPath.row]];
		
		return cell;
    }
}


- (void)displayBanner:(SASBannerView **)banner inTableViewCell:(UITableViewCell *)cell {
	if ((*banner) == nil) {
		*banner = [[self createBannerViewForCell:cell formatID:kFormatID pageID:kPageID master:YES target:nil] retain];
		[cell.contentView addSubview:(*banner)];
	}
}


- (SASBannerView *)createBannerViewForCell:(UITableViewCell *)cell formatID:(NSInteger)formatID pageID:(NSString *)pageID master:(BOOL)master target:(NSString *)target {
	
	SASBannerView *cellBanner = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cell.frame), kDefaultBannerCellHeight) loader:SASLoaderActivityIndicatorStyleWhite];
	cellBanner.delegate = self;
    cellBanner.modalParentViewController = self;
	[cellBanner loadFormatId:formatID pageId:pageID master:master target:target];
	
	return [cellBanner autorelease];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
    NSLog(@"[ADVIEW] adViewDidLoad");
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    NSLog(@"[ADVIEW] didFailToLoadWithError %@", error);
}


- (void)adView:(SASAdView *)adView willResizeWithFrame:(CGRect)frame {
    NSLog(@"[ADVIEW] willResizeWithFrame, x, y, width, height: %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
}


// If the application is using the MRAID 2.0 resizable banner, the cell size must be recomputed every time an MRAID resize
// is called in the creative, so that the adView does not overlap on other cells
//
//If resizable banners are not used, implementing this method is not needed
- (void)adView:(SASAdView *)adView didResizeWithFrame:(CGRect)frame {
	NSLog(@"[ADVIEW] didResizeWithFrame, x, y, width, height: %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
	
	// Force table view cells resizing (without view refreshing)
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}


// If the application is using the MRAID 2.0 resizable banner, the cell size must be recomputed every time an MRAID close
// is called in the creative, so that the cell does not stay bigger than the creative
//
// If resizable banners are not used, implementing this method is not needed
- (void)adView:(SASAdView *)adView didCloseResizeWithFrame:(CGRect)frame {
	NSLog(@"[ADVIEW] didCloseResizeWithFrame, x, y, width, height: %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
	
	// Force table view cells resizing (without view refreshing)
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}


@end
