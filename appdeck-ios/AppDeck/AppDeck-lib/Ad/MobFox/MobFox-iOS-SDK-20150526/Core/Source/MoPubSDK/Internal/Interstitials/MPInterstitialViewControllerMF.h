//
//  MPInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGlobalMF.h"

@class CLLocation;

@protocol MPInterstitialViewControllerDelegateMF;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPInterstitialViewControllerMF : UIViewController

@property (nonatomic, assign) MPInterstitialCloseButtonStyle closeButtonStyle;
@property (nonatomic, assign) MPInterstitialOrientationType orientationType;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, assign) id<MPInterstitialViewControllerDelegateMF> delegate;

- (void)presentInterstitialFromViewController:(UIViewController *)controller;
- (void)dismissInterstitialAnimated:(BOOL)animated;
- (BOOL)shouldDisplayCloseButton;
- (void)willPresentInterstitial;
- (void)didPresentInterstitial;
- (void)willDismissInterstitial;
- (void)didDismissInterstitial;
- (void)layoutCloseButton;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPInterstitialViewControllerDelegateMF <NSObject>

- (NSString *)adUnitId;
- (CLLocation *)location;
- (void)interstitialDidLoadAd:(MPInterstitialViewControllerMF *)interstitial;
- (void)interstitialDidFailToLoadAd:(MPInterstitialViewControllerMF *)interstitial;
- (void)interstitialWillAppear:(MPInterstitialViewControllerMF *)interstitial;
- (void)interstitialDidAppear:(MPInterstitialViewControllerMF *)interstitial;
- (void)interstitialWillDisappear:(MPInterstitialViewControllerMF *)interstitial;
- (void)interstitialDidDisappear:(MPInterstitialViewControllerMF *)interstitial;
- (void)interstitialWillLeaveApplication:(MPInterstitialViewControllerMF *)interstitial;

@end
