//
//  WideSpaceBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MobFoxAdViewController.h"
#import "MobFoxAdEngine.h"
#import "../../LoaderChildViewController.h"
#import "../../AppDeck.h"
#import "../../AppDeckUserProfile.h"
#import "../../AdManager.h"

@interface MobFoxAdViewController ()

@end

@implementation MobFoxAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(MobFoxAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.adType isEqualToString:@"banner"])
    {
        self.width = 320;
        self.height = 50;
    }
    else if ([self.adType isEqualToString:@"rectangle"])
    {
        self.width = 320;
        self.height = 320;
    }
    else
    {
        self.state = AppDeckAdStateFailed;
        return;
    }

    self.bannerView = [[MobFoxBannerView alloc] initWithFrame:CGRectZero];
    self.bannerView.allowDelegateAssigmentToRequestAd = NO; //use this if you don't want to trigger ad loading when setting delegate and intend to request it it manually
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    self.bannerView.requestURL = @"http://my.mobfox.com/request.php"; // Do Not Change this
    self.bannerView.adspaceWidth = self.width; // Optional, used to set the custom size of the banner placement. Without setting it, the Server will revert to default sizes (320x50 for iPhone, 728x90 for iPad).
    self.bannerView.adspaceHeight = self.height;
    self.bannerView.adspaceStrict = NO; // Optional, tells the server to only supply ads that are exactly of the desired size. Without setting it, the server could also supply smaller Ads when no ad of desired size is available.
    [self.bannerView requestAd]; // Request a Banner Ad manually
    
    
    /*
    // meta
    AppDeckUserProfile *profile = self.adManager.loader.appDeck.userProfile;
    if (profile.postal)
        [adView setExtraParameter:@"postal" value:profile.postal];
    if (profile.city)
        [adView setExtraParameter:@"city" value:profile.city];
    if (profile.age)
        [adView setExtraParameter:@"age" value:profile.age];
    if (profile.yearOfBirth)
        [adView setExtraParameter:@"yob" value:profile.yearOfBirth];
    if (profile.gender)
        [adView setExtraParameter:@"sex" value:(profile.gender == ProfileGenderMale ? @"1" : @"0")];
     */
    
    self.view.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    if (self.bannerView)
    {
        self.bannerView.delegate = nil;
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }

}

-(void)dealloc
{
    [self cancel];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _bannerView.frame = CGRectMake(0, 0, self.width, self.height);
}

#pragma mark - MobFox delegate

// Set the Publisher ID (mandatory)
- (NSString *)publisherIdForMobFoxBannerView:(MobFoxBannerView *)banner
{
    return self.adEngine.publisherID;
}

// Called if an Ad has been successfully retrieved and displayed the first time. Not called when an adView receives a "refreshed" Ad.
- (void)mobfoxBannerViewDidLoadMobFoxAd:(MobFoxBannerView *)banner
{
    NSLog(@"MobFox AdView: %ldx%ld", banner.adspaceWidth, banner.adspaceHeight);
    self.width = banner.adspaceWidth;
    self.height = banner.adspaceHeight;
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.height);
    self.state = AppDeckAdStateReady;    
}

// Called if an existing Ad view receives a "refreshed" Ad.
- (void)mobfoxBannerViewDidLoadRefreshedAd:(MobFoxBannerView *)banner
{
    
}

//Called if no banner is available or there is an error.
- (void)mobfoxBannerView:(MobFoxBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.state = AppDeckAdStateFailed;
}

// Called when user taps on a banner
- (BOOL)mobfoxBannerViewActionShouldBegin:(MobFoxBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

// Called when the modal web view will be displayed
- (void)mobfoxBannerViewActionWillPresent:(MobFoxBannerView *)banner
{
    
}

// Called when the modal web view is about to be cancelled
// Restart any foreground activities paused as part of mobfoxBannerViewActionWillPresent.
- (void)mobfoxBannerViewActionWillFinish:(MobFoxBannerView *)banner
{
    
}

// Called when the modal web view is cancelled and the user is returning to the app.
- (void)mobfoxBannerViewActionDidFinish:(MobFoxBannerView *)banner
{
    self.state = AppDeckAdStateClose;
}

// Called when a user tap results in Application Switching.
- (void)mobfoxBannerViewActionWillLeaveApplication:(MobFoxBannerView *)banner
{
    
}

@end
