//
//  MoPubInterstitialAdViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 09/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "MoPubInterstitialAdViewController.h"
#import "MoPubAdEngine.h"
#import "../../LoaderChildViewController.h"
#import "../../LoaderViewController.h"
#import "../../PageViewController.h"

@interface MoPubInterstitialAdViewController ()

@end

@implementation MoPubInterstitialAdViewController

- (id)initWithAdRation:(AdRation *)adRation engine:(MoPubAdEngine *)adEngine config:(NSDictionary *)config
{
    self = [super initWithAdRation:adRation engine:adEngine config:config];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
        self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:self.adEngine.InterstitialTabletAdUnitId];
    else
        self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:self.adEngine.InterstitialAdUnitId];
    
    self.interstitial.delegate = self;
    
    [self.adEngine setInterstitialMetaData:self.interstitial];
    
    [self.interstitial loadAd];
    
    //self.interstitial.testing = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    self.interstitial.delegate = nil;
    [MPInterstitialAdController removeSharedInterstitialAdController:self.interstitial];
    self.interstitial = nil;
}

#pragma mark - default Ad Life Cycle implementation

-(void)adIsReady
{
    
}

-(void)adDidFailed
{
    
}

-(void)adDidCancel
{
    
}

-(void)adWillLoadInViewController:(LoaderChildViewController *)ctl
{
    
}


-(void)adWillAppearInViewController:(LoaderChildViewController *)ctl
{
    if (self.interstitial.ready)
    {
        /*[ctl.loader.tabBarController setSelectedIndex:1];
         [ctl.loader dismissViewControllerAnimated:NO completion:^{
         [self.interstitial showFromViewController:ctl.loader];
         }];*/
        [self.interstitial showFromViewController:self.adManager.loader];
    }
    else
        NSLog(@"Ad was not ready ...");
}

-(void)adWillDisappearInViewController:(LoaderChildViewController *)ctl
{
    
}

-(void)adDidUnloadFromViewController:(LoaderChildViewController *)ctl
{
    
}

#pragma mark - <MPInterstitialAdControllerDelegate>

/**
 * Sent when an interstitial ad object successfully loads an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    self.state = AppDeckAdStateReady;
}

/**
 * Sent when an interstitial ad object fails to load an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    self.state = AppDeckAdStateFailed;
}

/** @name Detecting When an Interstitial Ad is Presented */

/**
 * Sent immediately before an interstitial ad object is presented on the screen.
 *
 * Your implementation of this method should pause any application activity that requires user
 * interaction.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    
}

/**
 * Sent after an interstitial ad object has been presented on the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    //self.page.isFullScreen = YES;
}

/** @name Detecting When an Interstitial Ad is Dismissed */

/**
 * Sent immediately before an interstitial ad object will be dismissed from the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    
}

/**
 * Sent after an interstitial ad object has been dismissed from the screen, returning control
 * to your application.
 *
 * Your implementation of this method should resume any application activity that was paused
 * prior to the interstitial being presented on-screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    self.page.isFullScreen = NO;
    self.state = AppDeckAdStateClose;
}

/** @name Detecting When an Interstitial Ad Expires */

/**
 * Sent when a loaded interstitial ad is no longer eligible to be displayed.
 *
 * Interstitial ads from certain networks (such as iAd) may expire their content at any time,
 * even if the content is currently on-screen. This method notifies you when the currently-
 * loaded interstitial has expired and is no longer eligible for display.
 *
 * If the ad was on-screen when it expired, you can expect that the ad will already have been
 * dismissed by the time this message is sent.
 *
 * Your implementation may include a call to `loadAd` to fetch a new ad, if desired.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    self.state = AppDeckAdStateFailed;
}

@end