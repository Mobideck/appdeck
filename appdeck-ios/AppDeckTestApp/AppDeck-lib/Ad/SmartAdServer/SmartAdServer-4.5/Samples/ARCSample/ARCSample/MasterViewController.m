//
//  MasterViewController.m
//  ARCSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "MasterViewController.h"
#import "MenuItem.h"
#import "BannerViewController.h"
#import "ToasterViewController.h"
#import "InterstitialViewController.h"
#import "InterstitialDismissAnimationViewController.h"
#import "PrefetchInterstitialViewController.h"


@interface MasterViewController () {
	NSMutableArray *_items;
}
@end


@implementation MasterViewController

#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = @"ARC Sample";
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
		[self initializeItems];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	// The 'Reset' button will call again 'initializeItems', causing all previous controllers to be automatically released: all
	// SASAdView instances in these controllers will be released as well.
	UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(resetItems)];
	self.navigationItem.rightBarButtonItem = resetButton;
}

#pragma mark - Generating menu items & child controllers

- (void)initializeItems {
	_items = [[NSMutableArray alloc] init];
	
	[self createItemWithTitle:@"Banner" controller:[[BannerViewController alloc] initWithNibName:@"BannerViewController" bundle:nil] inArray:_items];
	[self createItemWithTitle:@"Toaster" controller:[[ToasterViewController alloc] initWithNibName:@"ToasterViewController" bundle:nil] inArray:_items];
	[self createItemWithTitle:@"Interstitial" controller:[[InterstitialViewController alloc] initWithNibName:@"InterstitialViewController" bundle:nil] inArray:_items];
	[self createItemWithTitle:@"Interstitial dismiss animation" controller:[[InterstitialDismissAnimationViewController alloc] initWithNibName:@"InterstitialDismissAnimationViewController" bundle:nil] inArray:_items];
	[self createItemWithTitle:@"Prefetch interstitial" controller:[[PrefetchInterstitialViewController alloc] initWithNibName:@"PrefetchInterstitialViewController" bundle:nil] inArray:_items];
}


- (void)createItemWithTitle:(NSString *)title controller:(UIViewController *)itemController inArray:(NSMutableArray *)items {
	MenuItem *item = [[MenuItem alloc] initWithTitle:title];
	item.controller = itemController;
	[items addObject:item];
}


- (void)resetItems {
	UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:@"Reset controllers?" message:@"All controllers references will be reset (and SASAdView instances will be deallocated)." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
	[resetAlert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self initializeItems];
		[self.tableView reloadData];
		NSLog(@"Controllers have been reset");
	}
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Choose a sample:";
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"\nThis sample demonstrates how to implement the Smart AdServer SDK in ARC-enabled applications.\n\nFor applications without ARC check the others samples.";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	[cell.textLabel setText:[[_items objectAtIndex:indexPath.row] title]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIViewController *controller = [[_items objectAtIndex:indexPath.row] controller];
	if (controller != nil) {
		[self.navigationController pushViewController:controller animated:YES];
	}
}

@end
