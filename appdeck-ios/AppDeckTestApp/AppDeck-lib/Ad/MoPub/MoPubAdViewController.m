//
//  MoPubBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MoPubAdViewController.h"
#import "../../PageViewController.h"
#import "../../LoaderChildViewController.h"
#import "../../AppDeck.h"
#import "../../AppDeckUserProfile.h"
#import "../../AdManager.h"

@interface MoPubAdViewController ()

@end

@implementation MoPubAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(MoPubAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
/*
- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(MoPubAdEngine *)engine
{
    self = [super initWithAdManager:adManager type:adType engine:engine];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    if ([self.adType isEqualToString:@"banner"])
    {
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
            self.adView = [[MPAdView alloc] initWithAdUnitId:self.adEngine.bannerTabletAdUnitId size:MOPUB_LEADERBOARD_SIZE];
        else
            self.adView = [[MPAdView alloc] initWithAdUnitId:self.adEngine.bannerAdUnitId size:MOPUB_BANNER_SIZE];
    }
    else if ([self.adType isEqualToString:@"rectangle"])
    {
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
            self.adView = [[MPAdView alloc] initWithAdUnitId:self.adEngine.rectangleTabletAdUnitId size:MOPUB_MEDIUM_RECT_SIZE];
        else
            self.adView = [[MPAdView alloc] initWithAdUnitId:self.adEngine.rectangleAdUnitId size:MOPUB_MEDIUM_RECT_SIZE];
    }
    else if ([self.adType isEqualToString:@"interstitial"])
    {
    }
    
    // meta
    AppDeckUserProfile *profile = self.adManager.loader.appDeck.userProfile;
   
    NSString *keywords = @"appdeck=1";
    if (profile.gender)
        keywords = [keywords stringByAppendingFormat:@"&m_gender:%@", (profile.gender == ProfileGenderMale ? @"m" : @"f")];
    if (profile.age)
        keywords = [keywords stringByAppendingFormat:@"&m_age:%@", profile.age];
    if (profile.maritalStatus)
        keywords = [keywords stringByAppendingFormat:@"&m_marital:%@", (profile.maritalStatus == ProfileMaritalEngaged || profile.maritalStatus == ProfileMaritalMarried ? @"married" : @"single")];
    self.adView.keywords = keywords;
    
    self.view.clipsToBounds = YES;
    
    self.width = self.adView.frame.size.width;
    self.height = self.adView.frame.size.height;
    
    self.adView.delegate = self;

    [self.view addSubview:self.adView];
    
    [self.adEngine setMetaData:self.adView]; 
    
    [self.adView loadAd];

    [super viewDidLoad];
}

- (void)dealloc
{
    self.adView.delegate = nil;
    self.adView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    [self.adView stopAutomaticallyRefreshingContents]; // ??
    self.adView.delegate = nil;
    self.adView = nil;
    [self.adView removeFromSuperview];
}

#pragma mark - Helper

-(void)computeSize:(MPAdView *)view
{
    CGSize size = [view adContentViewSize];
    self.width = size.width;
    self.height = size.height;
    self.adView.frame = CGRectMake(0, 0, self.width, self.height);
}

#pragma mark - <MPAdViewDelegate>

- (void)adViewDidLoadAd:(MPAdView *)view
{
    [self computeSize:view];
    self.state = AppDeckAdStateReady;
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    self.state = AppDeckAdStateFailed;
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
    self.page.isFullScreen = YES;
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
    self.page.isFullScreen = NO;
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view
{
    self.state = AppDeckAdStateClose;    
}

- (UIViewController *)viewControllerForPresentingModalView
{
    if (self.page)
        return (UIViewController *)self.page;
    return self;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self.adView rotateToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self computeSize:self.adView];
}

#pragma mark - rotate / resize

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self computeSize:self.adView];
}

@end
