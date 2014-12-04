//
//  MPBannerAdDetailViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPSampleAppInstanceProvider.h"
#import "MPGlobal.h"
#import "MPAdPersistenceManager.h"

@interface MPBannerAdDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPAdView *adView;
@property (nonatomic, assign) BOOL didLoadAd;

@end

@implementation MPBannerAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)info
{
    self = [super initWithNibName:@"MPBannerAdDetailViewController" bundle:nil];
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

    self.title = @"Banner";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;
    self.keywordsTextField.text = self.info.keywords;
    
    self.loadAdButton.enabled = NO;
    
    [self configureAd];

    [self.spinner startAnimating];
}

- (IBAction)loadAdClicked:(id)sender
{
    self.adView.keywords = self.keywordsTextField.text;
    
    self.info.keywords = self.adView.keywords;
    // persist last used keywords if this is a saved ad
    if ([[MPAdPersistenceManager sharedManager] savedAdForID:self.info.ID] != nil) {
        [[MPAdPersistenceManager sharedManager] addSavedAd:self.info];
    }
    
    [self loadAd];
}

- (void)configureAd
{
    self.adView = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:self.info.ID
                                                                                     size:MOPUB_BANNER_SIZE];
    self.adView.delegate = self;
    self.adView.accessibilityLabel = @"banner";
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.adViewContainer addSubview:self.adView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.didLoadAd) {
        [self loadAd];
        self.didLoadAd = YES;
    }
}

- (void)loadAd
{
    [self.keywordsTextField endEditing:YES];
    
    self.loadAdButton.enabled = NO;
    self.failLabel.hidden = YES;
    [self.spinner startAnimating];
    [self.adView loadAd];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.adView rotateToOrientation:toInterfaceOrientation];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    
    return YES;
}

#pragma mark - <MPAdViewDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    self.loadAdButton.enabled = YES;
    
    [self.spinner stopAnimating];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    self.loadAdButton.enabled = YES;
    
    [self.spinner stopAnimating];
    self.failLabel.hidden = NO;
}

#pragma mark - Legacy Custom Events

- (void)startLegacyBannerCustomEvent:(MPAdView *)view
{
    UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    banner.backgroundColor = [UIColor redColor];

    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapCustomEventBanner:)];
    [banner addGestureRecognizer:tapRecognizer];

    [self.adView customEventDidLoadAd];
    [self.adView setAdContentView:banner];
    [self.spinner stopAnimating];
}

- (void)userDidTapCustomEventBanner:(UIGestureRecognizer *)recognizer
{
    [self.adView customEventActionWillBegin];
    recognizer.view.backgroundColor = [UIColor greenColor];

    [UIView animateWithDuration:1.0 animations:^{
        recognizer.view.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished) {
        [self.adView customEventActionDidEnd];
    }];
}

@end
