//
//  MPInterstitialAdDetailViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPSampleAppInstanceProvider.h"
#import "MPGlobal.h"
#import "MPAdPersistenceManager.h"

@interface MPInterstitialAdDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPInterstitialAdController *interstitial;

@end

@implementation MPInterstitialAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)adInfo
{
    self = [super init];
    if (self) {
        self.info = adInfo;

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
    self.title = @"Interstitial";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;
    self.showButton.hidden = YES;

    self.interstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.info.ID];
    self.interstitial.delegate = self;

    self.keywordsTextField.text = self.info.keywords;

    [super viewDidLoad];
}

- (IBAction)didTapLoadButton:(id)sender
{
    [self.keywordsTextField endEditing:YES];

    [self.spinner startAnimating];
    self.showButton.hidden = YES;
    self.loadButton.enabled = NO;
    self.expireLabel.hidden = YES;
    self.failLabel.hidden = YES;
    self.willAppearLabel.alpha = 0.1;
    self.didAppearLabel.alpha = 0.1;
    self.willDisappearLabel.alpha = 0.1;
    self.didDisappearLabel.alpha = 0.1;
    self.didReceiveTapLabel.alpha = 0.1;

    self.interstitial.keywords = self.keywordsTextField.text;

    self.info.keywords = self.interstitial.keywords;
    // persist last used keywords if this is a saved ad
    if ([[MPAdPersistenceManager sharedManager] savedAdForID:self.info.ID] != nil) {
        [[MPAdPersistenceManager sharedManager] addSavedAd:self.info];
    }

    [self.interstitial loadAd];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
}

- (IBAction)didTapShowButton:(id)sender
{
    [self.interstitial showFromViewController:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];

    return YES;
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    [self.spinner stopAnimating];
    self.showButton.hidden = NO;
    self.loadButton.enabled = YES;
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    self.failLabel.hidden = NO;
    self.loadButton.enabled = YES;
    [self.spinner stopAnimating];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    self.expireLabel.hidden = NO;
    self.loadButton.enabled = YES;
    self.showButton.hidden = YES;
    [self.spinner stopAnimating];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    self.willAppearLabel.alpha = 1.0;
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    self.didAppearLabel.alpha = 1.0;
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    self.willDisappearLabel.alpha = 1.0;
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    self.showButton.hidden = YES;
    self.didDisappearLabel.alpha = 1.0;
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial
{
    self.didReceiveTapLabel.alpha = 1.0;
}

@end
