//
//  MPInterstitialAdManagerDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPInterstitialAdManagerMF;
@class MPInterstitialAdControllerMF;
@class CLLocation;

@protocol MPInterstitialAdManagerDelegateMF <NSObject>

- (MPInterstitialAdControllerMF *)interstitialAdController;
- (CLLocation *)location;
- (id)interstitialDelegate;
- (void)managerDidLoadInterstitial:(MPInterstitialAdManagerMF *)manager;
- (void)manager:(MPInterstitialAdManagerMF *)manager
didFailToLoadInterstitialWithError:(NSError *)error;
- (void)managerWillPresentInterstitial:(MPInterstitialAdManagerMF *)manager;
- (void)managerDidPresentInterstitial:(MPInterstitialAdManagerMF *)manager;
- (void)managerWillDismissInterstitial:(MPInterstitialAdManagerMF *)manager;
- (void)managerDidDismissInterstitial:(MPInterstitialAdManagerMF *)manager;
- (void)managerDidExpireInterstitial:(MPInterstitialAdManagerMF *)manager;

@end
