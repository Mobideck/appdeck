//
//  WideSpaceBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MobFoxVideoInterstitialAdViewController.h"
#import "MobFoxAdEngine.h"
#import "../../LoaderChildViewController.h"
#import "../../AppDeck.h"
#import "../../AppDeckUserProfile.h"
#import "../../AdManager.h"

@interface MobFoxVideoInterstitialAdViewController ()

@end

@implementation MobFoxVideoInterstitialAdViewController

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

    if (![self.adType isEqualToString:@"interstitial"])
    {
        self.state = AppDeckAdStateFailed;
        return;
    }

    // Create, add Interstitial/Video Ad View Controller and add view to view hierarchy
    self.videoInterstitialViewController = [[MobFoxVideoInterstitialViewController alloc] init];
    
    // Assign delegate
    self.videoInterstitialViewController.delegate = self;
    
    // Add view. Note when it is created is transparent, with alpha = 0.0 and hidden
    // Only when an ad is being presented it become visible
    [self.view addSubview:self.videoInterstitialViewController.view];
    
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
        [adView setExtraParameter:@"sex" value:(profile.gender == ProfileGenderMale ? @"1" : @"0")];*/
    
    self.view.clipsToBounds = YES;
    
    self.videoInterstitialViewController.requestURL = @"http://my.mobfox.com/request.php";
    
    [self.videoInterstitialViewController requestAd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    if (self.videoInterstitialViewController)
    {
        self.videoInterstitialViewController.delegate = nil;
        self.videoInterstitialViewController = nil;
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

#pragma mark - MobFox delegate

// Set the Publisher ID (mandatory)
- (NSString *)publisherIdForMobFoxBannerView:(MobFoxBannerView *)banner
{
    return self.adEngine.publisherID;
}

// Called if an Ad has been successfully retrieved and is ready to be displayed via - (void)presentAd(MobFoxAdType)advertType
- (void)mobfoxVideoInterstitialViewDidLoadMobFoxAd:(MobFoxVideoInterstitialViewController *)videoInterstitial advertTypeLoaded:(MobFoxAdType)advertType
{
    
    NSLog(@"MobFox Interstitial: did load ad");
    
    // Means an advert has been retrieved and configured.
    // Display the ad using the presentAd method and ensure you pass back the advertType

    self.state = AppDeckAdStateReady;
    [videoInterstitial presentAd:advertType];
}

// Called if no Video/Interstitial is available or there was an error.
- (void)mobfoxVideoInterstitialView:(MobFoxVideoInterstitialViewController *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"MobFox Interstitial: did fail to load ad: %@", [error localizedDescription]);
            self.state = AppDeckAdStateFailed;
}

// Sent immediately before Video/Interstitial is shown to the user. At this point pause any animations, timers or other activities that assume user interaction and save app state, much like on UIApplicationDidEnterBackgroundNotification. Remember that the user may press Home or touch links to other apps like AppStore or iTunes within the interstitial, thus leaving your app.
- (void)mobfoxVideoInterstitialViewActionWillPresentScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    
}

// Sent immediately before interstitial leaves the screen. At this point restart any foreground activities paused as part of interstitialWillPresentScreen.
- (void)mobfoxVideoInterstitialViewWillDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    
}

// Sent when the user has dismissed interstitial and it has left the screen.
- (void)mobfoxVideoInterstitialViewDidDismissScreen:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    self.state = AppDeckAdStateClose;
}

// Called when a user tap results in Application Switching.
- (void)mobfoxVideoInterstitialViewActionWillLeaveApplication:(MobFoxVideoInterstitialViewController *)videoInterstitial
{
    
}

@end
