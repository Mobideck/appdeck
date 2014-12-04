//
//  TAMasterViewController.m
//  Test Application
//
//  Copyright (c) 2012 InMobi Inc. All rights reserved.
//

#import "TAMasterViewController.h"

#import "TADetailViewController.h"

@interface TAMasterViewController () 
{
    NSArray *_objects;
}

@end

@implementation TAMasterViewController

@synthesize detailViewController = _detailViewController;

#pragma mark - UIViewController life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"InMobi Monetization", @"InMobi Monetization");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSString *plistPath = nil;
    
    BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
    iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
    if (iPad)
        plistPath = [[NSBundle mainBundle] pathForResource:@"PublisherDemo-AdSizes-iPad" ofType:@"plist"];
    else
        plistPath = [[NSBundle mainBundle] pathForResource:@"PublisherDemo-AdSizes" ofType:@"plist"];
    
    _objects = [NSArray arrayWithContentsOfFile:plistPath];
    
    // Remove the iPad formats when displaying on a phone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _objects = [_objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(idiom != 'Pad')"]];
    } 
    
    // Remove the iPhone only formats when displaying on a phone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _objects = [_objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(idiom != 'Phone')"]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return @"Supported Ad Formats & Sizes";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                  initWithTitle: @"Back" 
                                  style: UIBarButtonItemStyleBordered
                                  target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    NSDictionary *demoCompontent = [_objects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [demoCompontent objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *demoCompontent = [_objects objectAtIndex:indexPath.row];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        TADetailViewController* detailViewController = [[TADetailViewController alloc] initWithNibName:@"TADetailViewController_iPhone" bundle:nil];
	    detailViewController.detailItem = demoCompontent;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        self.detailViewController.detailItem = demoCompontent;
    }
}

@end
