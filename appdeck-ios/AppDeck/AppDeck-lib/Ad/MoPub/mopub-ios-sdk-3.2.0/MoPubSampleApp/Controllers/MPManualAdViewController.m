//
//  MPManualAdViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPManualAdViewController.h"
#import "MPSampleAppInstanceProvider.h"
#import "MPGlobal.h"
#import "MPAdInfo.h"

@interface MPManualAdViewController ()

@property (nonatomic, strong) MPInterstitialAdController *firstInterstitial;
@property (nonatomic, strong) MPInterstitialAdController *secondInterstitial;
@property (nonatomic, strong) MPAdView *banner;
@property (nonatomic, strong) MPAdView *mRectBanner;
@property (nonatomic, strong) UITextField *activeField;

@end

@implementation MPManualAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif

    self.title = @"Manual";
    self.firstInterstitialShowButton.hidden = YES;
    self.secondInterstitialShowButton.hidden = YES;

    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.scrollView.contentSize = self.scrollView.bounds.size;
}

- (void)dealloc
{
    self.firstInterstitial.delegate = nil;
    self.secondInterstitial.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)didTapFirstInterstitialLoadButton:(id)sender
{
    self.firstInterstitialLoadButton.enabled = NO;
    self.firstInterstitialStatusLabel.text = @"";
    [self.firstInterstitialActivityIndicator startAnimating];
    self.firstInterstitialShowButton.hidden = YES;

    self.firstInterstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.firstInterstitialTextField.text];
    self.firstInterstitial.delegate = self;
    [self.firstInterstitial loadAd];
}

- (IBAction)didTapFirstInterstitialShowButton:(id)sender
{
    [self.firstInterstitial showFromViewController:self];
}

- (IBAction)didTapSecondInterstitialLoadButton:(id)sender
{
    self.secondInterstitialLoadButton.enabled = NO;
    self.secondInterstitialStatusLabel.text = @"";
    [self.secondInterstitialActivityIndicator startAnimating];
    self.secondInterstitialShowButton.hidden = YES;

    self.secondInterstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.secondInterstitialTextField.text];
    self.secondInterstitial.delegate = self;
    [self.secondInterstitial loadAd];
}

- (IBAction)didTapSecondInterstitialShowButton:(id)sender
{
    [self.secondInterstitial showFromViewController:self];
}

- (IBAction)didTapBannerLoadButton:(id)sender
{
    [self updateForBannerAdLoad];
    
    [self.view endEditing:YES];
    [self.bannerActivityIndicator startAnimating];
    self.bannerStatusLabel.text = @"";
    self.banner.adUnitId = self.bannerTextField.text;
    [self.banner loadAd];
}

- (IBAction)didTapBannerMRectLoadButton:(id)sender
{
    [self updateForBannerMRectAdLoad];
    
    [self.view endEditing:YES];
    [self.bannerActivityIndicator startAnimating];
    self.bannerStatusLabel.text = @"";
    self.mRectBanner.adUnitId = self.bannerTextField.text;
    [self.mRectBanner loadAd];
}

- (void)updateForBannerAdLoad
{
    [self.banner removeFromSuperview];
    [self.mRectBanner removeFromSuperview];
    
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
    self.bannerContainer.frame = CGRectMake(0, self.bannerContainer.frame.origin.y, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    
    self.banner.delegate = nil;
    self.banner = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:@"" size:MOPUB_BANNER_SIZE];
    self.banner.delegate = self;
    [self.bannerContainer addSubview:self.banner];
}

- (void)updateForBannerMRectAdLoad
{
    [self.banner removeFromSuperview];
    [self.mRectBanner removeFromSuperview];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.bannerContainer.frame.origin.y + MOPUB_MEDIUM_RECT_SIZE.width);
    
    CGFloat sideBuffer = (self.view.bounds.size.width - MOPUB_MEDIUM_RECT_SIZE.width) / 2;
    self.bannerContainer.frame = CGRectMake(sideBuffer, self.bannerContainer.frame.origin.y, MOPUB_MEDIUM_RECT_SIZE.width, MOPUB_MEDIUM_RECT_SIZE.height);
    
    self.mRectBanner.delegate = nil;
    self.mRectBanner = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:@"" size:MOPUB_MEDIUM_RECT_SIZE];
    self.mRectBanner.delegate = self;
    [self.bannerContainer addSubview:self.mRectBanner];
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        [self.firstInterstitialActivityIndicator stopAnimating];
        self.firstInterstitialShowButton.hidden = NO;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        [self.secondInterstitialActivityIndicator stopAnimating];
        self.secondInterstitialShowButton.hidden = NO;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        [self.firstInterstitialActivityIndicator stopAnimating];
        self.firstInterstitialLoadButton.enabled = YES;
        self.firstInterstitialStatusLabel.text = @"Failed";
    } else if (interstitial == self.secondInterstitial) {
        [self.secondInterstitialActivityIndicator stopAnimating];
        self.secondInterstitialLoadButton.enabled = YES;
        self.secondInterstitialStatusLabel.text = @"Failed";
    }
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        self.firstInterstitialStatusLabel.text = @"Expired";
        self.firstInterstitialShowButton.hidden = YES;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        self.secondInterstitialStatusLabel.text = @"Expired";
        self.secondInterstitialShowButton.hidden = YES;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        self.firstInterstitialShowButton.hidden = YES;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        self.secondInterstitialShowButton.hidden = YES;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

#pragma mark - <MPAdViewDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    [self.bannerActivityIndicator stopAnimating];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    self.bannerStatusLabel.text = @"Failed";
    [self.bannerActivityIndicator stopAnimating];
}

- (void)didTapScrollView
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Keyboard Scroll Management

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint activeFieldVisiblePoint = CGPointMake(self.activeField.frame.origin.x, self.activeField.frame.origin.y + self.activeField.frame.size.height + 10);
    if (!CGRectContainsPoint(aRect, activeFieldVisiblePoint) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeFieldVisiblePoint.y - aRect.size.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Rotation (pre-iOS 6.0)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.banner rotateToOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

@end
