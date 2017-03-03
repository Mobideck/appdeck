//
//  MPAdTableViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdTableViewController.h"
#import "MPAdInfo.h"
#import "MPAdSection.h"
#import "MPBannerAdDetailViewController.h"
#import "MPInterstitialAdDetailViewController.h"
#import "MPManualAdViewController.h"
#import "MPMRectBannerAdDetailViewController.h"
#import "MPLeaderboardBannerAdDetailViewController.h"
#import "MPNativeAdDetailViewController.h"
#import "MPGlobal.h"
#import "MPAdPersistenceManager.h"
#import "MPAdEntryViewController.h"
#import "MPNativeAdPlacerTableViewController.h"
#import "MPNativeAdPlacerCollectionViewController.h"
#import "MPNativeAdPlacerPageViewController.h"
#import "MPSampleAppLogReader.h"
#import "MPRewardedVideoAdDetailViewController.h"

@interface MPAdTableViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSIndexPath *selectedSavedIndexPath;

@end

@implementation MPAdTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithAdSections:(NSArray *)sections
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.sections = sections;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (MPAdInfo *)infoAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.sections[indexPath.section] adAtIndex:indexPath.row];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
    self.tableView.separatorColor = [UIColor colorWithRed:0.31 green:0.31 blue:0.31 alpha:1];
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 30;

    self.title = @"Ads";
    self.tableView.accessibilityLabel = @"Ad Table View";
    [self.tableView reloadData];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapNewAdButton:)];
    self.navigationItem.rightBarButtonItem.accessibilityLabel = @"New Ad";

    UIButton* myInfoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [myInfoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myInfoButton];

    [[MPSampleAppLogReader sharedLogReader] beginReadingLogMessages];

    [super viewDidLoad];
}

- (void)infoButtonClicked:(id)sender
{
    UIAlertView *infoAV = [[UIAlertView alloc] initWithTitle:@"MoPub Sample App"
                                                     message:[NSString stringWithFormat:@"MoPub SDK Version: %@", MP_SDK_VERSION]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [infoAV show];
}

- (void)didTapManualButton:(id)sender
{
    [self.navigationController pushViewController:[[MPManualAdViewController alloc] init] animated:YES];
}

- (void)didTapNewAdButton:(id)sender
{
    [self.navigationController pushViewController:[[MPAdEntryViewController alloc] init] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    MPAdInfo *info = [self infoAtIndexPath:indexPath];

    cell.textLabel.text = info.title;
    cell.detailTextLabel.text = info.ID;
    cell.textLabel.textColor = [UIColor colorWithRed:0.42 green:0.66 blue:0.85 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1];

    MPAdSection *section = self.sections[indexPath.section];
    cell.accessoryType = [section.title isEqualToString:@"Saved Ads"] ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections[section] title];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPAdInfo *info = [self infoAtIndexPath:indexPath];
    UIViewController *detailViewController = nil;

    switch (info.type) {
        case MPAdInfoBanner:
            detailViewController = [[MPBannerAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoMRectBanner:
            detailViewController = [[MPMRectBannerAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoLeaderboardBanner:
            detailViewController = [[MPLeaderboardBannerAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoInterstitial:
            detailViewController = [[MPInterstitialAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoRewardedVideo:
            detailViewController = [[MPRewardedVideoAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoNative:
            detailViewController = [[MPNativeAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoNativeInCollectionView:
            detailViewController = [[MPNativeAdPlacerCollectionViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoNativeTableViewPlacer:
            detailViewController = [[MPNativeAdPlacerTableViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoNativePageViewControllerPlacer:
            detailViewController = [[MPNativeAdPlacerPageViewController alloc] initWithAdInfo:info];
            break;
        default:
            break;
    }

    if (detailViewController) {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedSavedIndexPath = indexPath;

    MPAdInfo *info = [self infoAtIndexPath:indexPath];

    UIActionSheet *adActionsSheet = [[UIActionSheet alloc] initWithTitle:info.title
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Delete"
                                           otherButtonTitles:@"Edit", nil];

    [adActionsSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MPAdInfo *info = [self infoAtIndexPath:self.selectedSavedIndexPath];

    if(buttonIndex == actionSheet.destructiveButtonIndex)
    {
        UIAlertView *deleteConfirmAV = [[UIAlertView alloc] initWithTitle:@"Confirm Delete"
                                                                  message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", info.title]
                                                                 delegate:self
                                                        cancelButtonTitle:@"No"
                                                        otherButtonTitles:@"Yes", nil];
        [deleteConfirmAV show];
    }
    else if(buttonIndex == 1) // edit, go to pre-configured ad entry view controller
    {
        [self.navigationController pushViewController:[[MPAdEntryViewController alloc] initWithAdInfo:info] animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex)
    {
        if(alertView.alertViewStyle == UIAlertViewStyleDefault)
        {
            [[MPAdPersistenceManager sharedManager] removeSavedAd:[self infoAtIndexPath:self.selectedSavedIndexPath]];
        }

        [self.tableView reloadData];
    }
}

@end
