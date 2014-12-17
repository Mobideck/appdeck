//
//  MPNativeAdDetailViewController.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAd.h"
#import "MPAdPersistenceManager.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdView.h"
#import "MPNativeAdDelegate.h"

NSString *const kNativeAdDefaultActionViewKey = @"kNativeAdDefaultActionButtonKey";

@interface MPNativeAdDetailViewController () <UITextFieldDelegate, MPNativeAdDelegate>

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPNativeAd *nativeAd;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet MPNativeAdView *adViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;

@end

@implementation MPNativeAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)info
{
    self = [super initWithNibName:@"MPNativeAdDetailViewController" bundle:nil];
    if (self) {
        self.info = info;

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

    self.title = @"Native";
    self.IDLabel.text = self.info.ID;
    self.keywordsTextField.text = self.info.keywords;
    self.adViewContainer.accessibilityLabel = kNativeAdDefaultActionViewKey;

    [self loadAd:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Ad Configuration

- (IBAction)loadAd:(id)sender
{
    [self.keywordsTextField endEditing:YES];

    self.loadAdButton.enabled = NO;
    [self.spinner startAnimating];
    [self clearAd];

    MPNativeAdRequest *adRequest1 = [MPNativeAdRequest requestWithAdUnitIdentifier:self.info.ID];

    MPNativeAdRequestTargeting *targeting = [[MPNativeAdRequestTargeting alloc] init];
    targeting.keywords = self.keywordsTextField.text;
    adRequest1.targeting = targeting;
    self.info.keywords = adRequest1.targeting.keywords;
    // persist last used keywords if this is a saved ad
    if ([[MPAdPersistenceManager sharedManager] savedAdForID:self.info.ID] != nil) {
        [[MPAdPersistenceManager sharedManager] addSavedAd:self.info];
    }

    [adRequest1 startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error) {
            NSLog(@"================> %@", error);
            [self configureAdLoadFail];
        } else {
            self.nativeAd = response;
            self.nativeAd.delegate = self;
            [self displayAd];
            NSLog(@"Received Native Ad");
        }
        [self.spinner stopAnimating];
    }];
}

- (void)clearAd
{
    [self.adViewContainer clearAd];

    self.nativeAd = nil;
    self.failLabel.hidden = YES;
}

- (void)displayAd
{
    self.loadAdButton.enabled = YES;

    [self.nativeAd prepareForDisplayInView:self.adViewContainer];
}

- (void)configureAdLoadFail
{
    self.loadAdButton.enabled = YES;
    self.failLabel.hidden = NO;
}

#pragma mark - Actions

- (IBAction)launchAdURL:(id)sender
{
    [self.nativeAd displayContentWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Completed display of ad's default action URL");
        } else {
            NSLog(@"================> %@", error);
        }
    }];
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
