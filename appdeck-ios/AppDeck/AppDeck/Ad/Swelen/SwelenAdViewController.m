//
//  WideSpaceBannerAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "SwelenAdViewController.h"
#import "SwelenAdEngine.h"
#import "../../LoaderChildViewController.h"
#import "../../AppDeck.h"
#import "../../AppDeckUserProfile.h"
#import "../../AdManager.h"

@interface SwelenAdViewController ()

@end

@implementation SwelenAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(SwelenAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(SwelenAdEngine *)engine
{
    self = [super initWithAdManager:adManager type:adType engine:engine];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.adType isEqualToString:@"banner"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 768;
        self.height = 90;
//        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.leaderboardSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"banner"])
    {
        self.width = 320;
        self.height = 48;
//        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.bannerSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"rectangle"] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        self.width = 300;
        self.height = 300;
//        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.squareSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"rectangle"])
    {
        self.width = 320;
        self.height = 320;
//        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.rectangleSID autoStart:YES autoUpdate:NO delegate:self GPSEnabled:NO];
    }
    else if ([self.adType isEqualToString:@"interstitial"])
    {
        self.width = 320;
        self.height = 480;
//        adView = [[WSAdSpace alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) sid:self.adEngine.interstitialSID autoStart:NO autoUpdate:NO delegate:self GPSEnabled:NO];
    }

/*    // meta
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    adView.delegate = nil;
//    [adView closeAd];
//    [adView stop];
    [adView removeFromSuperview];
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

@end
