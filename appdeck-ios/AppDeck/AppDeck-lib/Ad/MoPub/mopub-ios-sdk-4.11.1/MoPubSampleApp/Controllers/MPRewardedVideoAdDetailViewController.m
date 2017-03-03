//
//  MPRewardedVideoAdDetailViewController.m
//  MoPubSampleApp
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPRewardedVideoAdDetailViewController.h"
#import "MPAdPersistenceManager.h"
#import "MPRewardedVideo.h"
#import "MPAdInfo.h"
#import "MoPub.h"

@interface MPRewardedVideoAdDetailViewController () <MPRewardedVideoDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (nonatomic, strong) MPAdInfo *info;

@end

@implementation MPRewardedVideoAdDetailViewController

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
    self.title = @"Rewarded Video";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;
    self.showButton.hidden = YES;

    [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:@[] delegate:self];

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
    self.shouldRewardLabel.alpha = 0.1;

    self.info.keywords = self.keywordsTextField.text;
    // persist last used keywords if this is a saved ad
    if ([[MPAdPersistenceManager sharedManager] savedAdForID:self.info.ID] != nil) {
        [[MPAdPersistenceManager sharedManager] addSavedAd:self.info];
    }


    // create Instance Mediation Settings as needed here
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:self.info.ID keywords:self.info.keywords location:nil customerId:@"testCustomerId" mediationSettings:@[]];
}

- (IBAction)didTapShowButton:(id)sender
{
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:self.info.ID]) {
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:self.info.ID fromViewController:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];

    return YES;
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID
{
    [self.spinner stopAnimating];
    self.showButton.hidden = NO;
    self.loadButton.enabled = YES;
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
    self.failLabel.hidden = NO;
    self.loadButton.enabled = YES;
    [self.spinner stopAnimating];
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID
{
    self.willAppearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID
{
    self.didAppearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID
{
    self.willDisappearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID
{
    self.showButton.hidden = YES;
    self.didDisappearLabel.alpha = 1.0;
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID
{
    self.expireLabel.hidden = NO;
    self.loadButton.enabled = YES;
    self.showButton.hidden = YES;
    [self.spinner stopAnimating];
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID
{
    self.didReceiveTapLabel.alpha = 1.0;
}

- (void)rewardedVideoWillLeaveApplicationForAdUnitID:(NSString *)adUnitID
{

}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward
{
    self.shouldRewardLabel.alpha = 1.0;
}

@end
