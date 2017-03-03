//
//  MPAdEntryViewController.m
//  MoPubSampleApp
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdEntryViewController.h"
#import "MPAdInfo.h"
#import "MPBannerAdDetailViewController.h"
#import "MPMRectBannerAdDetailViewController.h"
#import "MPLeaderboardBannerAdDetailViewController.h"
#import "MPInterstitialAdDetailViewController.h"
#import "MPAdPersistenceManager.h"
#import "MPNativeAdDetailViewController.h"
#import "MPRewardedVideoAdDetailViewController.h"

#import <QuartzCore/QuartzCore.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface MPAdEntryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *adTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *pickerDoneButton;
@property (weak, nonatomic) IBOutlet UIPickerView *adTypePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (weak, nonatomic) IBOutlet UITextField *adUnitTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showAndSaveBarButton;
@property (weak, nonatomic) IBOutlet UIToolbar *showToolbar;
@property (weak, nonatomic) IBOutlet UITextField *adNameTextField;

@property (nonatomic, assign) MPAdInfoType selectedAdType;
@property (nonatomic, strong) MPAdInfo *initialAdInfo;
@property (nonatomic, strong) NSArray *sortedSupportedAdTypes;

@end

@implementation MPAdEntryViewController

- (id)init
{
    return [self initWithAdInfo:nil];
}

- (id)initWithAdInfo:(MPAdInfo *)adInfo
{
    self = [super initWithNibName:@"MPAdEntryViewController" bundle:nil];
    if (self) {
        _initialAdInfo = adInfo;
        self.title = (adInfo.title != nil) ? adInfo.title : @"New Ad";

        _sortedSupportedAdTypes = [[MPAdInfo supportedAddedAdTypes].allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (MPAdInfo *)adInfoForCurrentInput
{
    MPAdInfo *info = [[MPAdInfo alloc] init];
    info.title = (self.adNameTextField.text.length > 0) ? self.adNameTextField.text : self.adTypeButton.titleLabel.text;
    info.type = self.selectedAdType;
    info.ID = self.adUnitTextField.text;

    return info;
}

#pragma mark - UI Actions

- (void)showAd
{
    UIViewController *detailViewController = nil;

    MPAdInfo *info = [self adInfoForCurrentInput];

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
        case MPAdInfoNative:
            detailViewController = [[MPNativeAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoRewardedVideo:
            detailViewController = [[MPRewardedVideoAdDetailViewController alloc] initWithAdInfo:info];
            break;
        default:
            break;
    }

    if (detailViewController) {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (IBAction)showAndSaveBarButtonClicked:(id)sender
{
    [[MPAdPersistenceManager sharedManager] addSavedAd:[self adInfoForCurrentInput]];

    [self showAd];
}

- (IBAction)showBarButtonClicked:(id)sender
{
    [self showAd];
}

- (IBAction)touchEaterClicked:(id)sender
{
    [self animateOutPicker];
}

- (IBAction)pickerDoneButtonClicked:(id)sender
{
    [self animateOutPicker];
}

- (IBAction)adTypeButtonClicked:(id)sender
{
    [self animateInPicker];
}

- (void)animateInPicker
{
    [self.adUnitTextField endEditing:YES];

    self.pickerDoneButton.alpha = self.adTypePicker.alpha = self.pickerToolbar.alpha = 0;
    self.pickerDoneButton.hidden = self.adTypePicker.hidden = self.pickerToolbar.hidden = NO;

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.pickerDoneButton.alpha = 0.5;
                         self.adTypePicker.alpha = 1;
                         self.pickerToolbar.alpha = 1;
                         self.showToolbar.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.adTypePicker selectRow:self.selectedAdType inComponent:0 animated:NO];
                     }];
}

- (void)animateOutPicker
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.pickerDoneButton.alpha = self.adTypePicker.alpha = self.pickerToolbar.alpha = 0;
                         self.showToolbar.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.pickerDoneButton.hidden = self.adTypePicker.hidden = self.pickerToolbar.hidden = YES;
                     }];
}

- (void)updateActionButtonStates
{
    if (self.adUnitTextField.text.length > 0) {
        self.showAndSaveBarButton.enabled = self.showBarButton.enabled = YES;
    } else {
        self.showAndSaveBarButton.enabled = self.showBarButton.enabled = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateActionButtonStates];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.sortedSupportedAdTypes.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.sortedSupportedAdTypes objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedAdType = [[[MPAdInfo supportedAddedAdTypes] objectForKey:[self pickerView:pickerView titleForRow:row forComponent:component]] integerValue];

    [self.adTypeButton setTitle:[self pickerView:pickerView titleForRow:row forComponent:component] forState:UIControlStateNormal];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.selectedAdType = (self.initialAdInfo != nil) ? self.initialAdInfo.type : MPAdInfoBanner;
    self.adUnitTextField.text = self.initialAdInfo.ID;
    self.adNameTextField.text = self.initialAdInfo.title;

    self.pickerDoneButton.hidden = self.adTypePicker.hidden = YES;

    // add a border around this button on iOS 7
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.adTypeButton.layer.borderWidth = 1.0f;
        self.adTypeButton.layer.cornerRadius = 10.0f;
        self.adTypeButton.layer.borderColor = [UIColor colorWithRed:63 / 255.0f green:117 / 255.0f blue:1.0f alpha:1.0f].CGColor;
    }

    [self updateActionButtonStates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
