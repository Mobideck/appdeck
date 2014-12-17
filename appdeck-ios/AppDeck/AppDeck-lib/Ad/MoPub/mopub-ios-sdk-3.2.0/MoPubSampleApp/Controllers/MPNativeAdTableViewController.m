 //
//  MPNativeAdTableViewController.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdTableViewController.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAd.h"
#import "MPAdPersistenceManager.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdCell.h"
#import "MPTableViewAdManager.h"
#import "MPNativeAdTableHeaderView.h"
#import "MPAdInfo.h"
#import "MPNativeAdDelegate.h"

NSString *const kNativeAdTableViewAccessibilityLabel = @"kNativeAdTableViewAccessibilityLabel";
NSString *const kDefaultCellIdentifier = @"kDefaultCellIdentifier";
NSInteger const kRowForAdCell = 1;

@interface MPNativeAdTableViewController () <UITextFieldDelegate, MPNativeAdDelegate>

@property (nonatomic, strong) NSMutableArray *contentArray;
@property (nonatomic, strong) MPTableViewAdManager *adManager;
@property (nonatomic, strong) MPAdInfo *adInfo;

@property (nonatomic, weak) MPNativeAdTableHeaderView *tableHeaderView;

- (BOOL)shouldShowAdAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MPNativeAdTableViewController


#pragma mark - Lazy Loading

- (NSMutableArray *)contentArray
{
    if (_contentArray) {
        return _contentArray;
    }

    _contentArray = [NSMutableArray array];

    for (NSInteger i = 1; i <= 5; i++) {
        NSString *contentString = [NSString stringWithFormat:@"Normal TableView Cell #%ld", (long)i];
        [_contentArray addObject:contentString];
    }

    return _contentArray;
}

#pragma mark - Object Lifecycle

- (id)initWithAdInfo:(MPAdInfo *)info
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Native Ad in TableView";
        self.adInfo = info;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.accessibilityLabel = kNativeAdTableViewAccessibilityLabel;

    self.adManager = [[MPTableViewAdManager alloc] initWithTableView:self.tableView];

    self.tableHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"MPNativeAdTableHeaderView" owner:self options:nil] objectAtIndex:0];
    self.tableHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 128);
    self.tableView.tableHeaderView = self.tableHeaderView;
    [self.tableHeaderView.loadAdButton addTarget:self action:@selector(loadAd) forControlEvents:UIControlEventTouchUpInside];
    self.tableHeaderView.keywordsTextField.delegate = self;

    self.tableHeaderView.IDLabel.text = self.adInfo.ID;
    self.tableHeaderView.keywordsTextField.text = self.adInfo.keywords;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDefaultCellIdentifier];

    [self loadAd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)loadAd
{
    self.tableHeaderView.loadAdButton.enabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [self.tableHeaderView.keywordsTextField endEditing:YES];

    self.tableHeaderView.failLabel.hidden = YES;
    [self.tableHeaderView.spinner startAnimating];
    if ([[self.contentArray objectAtIndex:kRowForAdCell] isKindOfClass:[MPNativeAd class]]) {
        [self.contentArray removeObjectAtIndex:kRowForAdCell];
    }
    [self.tableView reloadData];

    MPNativeAdRequest *adRequest1 = [MPNativeAdRequest requestWithAdUnitIdentifier:self.adInfo.ID];

    MPNativeAdRequestTargeting *targeting = [[MPNativeAdRequestTargeting alloc] init];
    targeting.keywords = self.tableHeaderView.keywordsTextField.text;
    adRequest1.targeting = targeting;
    self.adInfo.keywords = adRequest1.targeting.keywords;

    [adRequest1 startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error) {
            NSLog(@"================> %@", error);
            self.tableHeaderView.failLabel.hidden = NO;
        } else {
            response.delegate = self;
            [self.contentArray insertObject:response atIndex:kRowForAdCell];
            [self.tableView reloadData];
            NSLog(@"Received Native Ad");
        }
        [self.tableHeaderView.spinner stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.tableHeaderView.loadAdButton.enabled = YES;
    }];
}

#pragma mark - Ad Helpers

- (BOOL)shouldShowAdAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.contentArray objectAtIndex:indexPath.row] isKindOfClass:[MPNativeAd class]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.contentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([self shouldShowAdAtIndexPath:indexPath])
    {
        MPNativeAd *adObject = (MPNativeAd *)[self.contentArray objectAtIndex:indexPath.row];
        return [_adManager adCellForAd:adObject cellClass:[MPNativeAdCell class]];
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier forIndexPath:indexPath];

        cell.textLabel.text = [self.contentArray objectAtIndex:indexPath.row];

        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self shouldShowAdAtIndexPath:indexPath])
    {
        MPNativeAd *adObject = (MPNativeAd *)[self.contentArray objectAtIndex:indexPath.row];
        [adObject displayContentWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"Completed display of ad's default action URL");
            } else {
                NSLog(@"================> %@", error);
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self shouldShowAdAtIndexPath:indexPath])
    {
        return 313;
    }
    else
    {
        return 80;
    }
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];

    return YES;
}

#pragma mark - MPNativeAdDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

@end
