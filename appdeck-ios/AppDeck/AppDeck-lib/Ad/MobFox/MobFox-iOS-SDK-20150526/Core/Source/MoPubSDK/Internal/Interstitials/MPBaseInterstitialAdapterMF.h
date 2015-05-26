//
//  MPBaseInterstitialAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MPAdConfigurationMF, CLLocation;

@protocol MPInterstitialAdapterDelegateMF;

@interface MPBaseInterstitialAdapterMF : NSObject

@property (nonatomic, assign) id<MPInterstitialAdapterDelegateMF> delegate;

/*
 * Creates an adapter with a reference to an MPInterstitialAdManager.
 */
- (id)initWithDelegate:(id<MPInterstitialAdapterDelegateMF>)delegate;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

- (void)getAdWithConfiguration:(MPAdConfigurationMF *)configuration;
- (void)_getAdWithConfiguration:(MPAdConfigurationMF *)configuration;

- (void)didStopLoading;

/*
 * Presents the interstitial from the specified view controller.
 */
- (void)showInterstitialFromViewController:(UIViewController *)controller;

@end

@interface MPBaseInterstitialAdapterMF (ProtectedMethods)

- (void)trackImpression;
- (void)trackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@class MPInterstitialAdControllerMF;

@protocol MPInterstitialAdapterDelegateMF

- (MPInterstitialAdControllerMF *)interstitialAdController;
- (id)interstitialDelegate;
- (CLLocation *)location;

- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapterMF *)adapter;
- (void)adapter:(MPBaseInterstitialAdapterMF *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapterMF *)adapter;
- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapterMF *)adapter;
- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapterMF *)adapter;
- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapterMF *)adapter;
- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapterMF *)adapter;
- (void)interstitialWillLeaveApplicationForAdapter:(MPBaseInterstitialAdapterMF *)adapter;

@end
