//
//  FakeFBInterstitialAd.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FakeFBInterstitialAd : NSObject <FakeInterstitialAd>

@property (nonatomic, weak) id <FBInterstitialAdDelegate> delegate;
@property (nonatomic, assign) BOOL isAdValid;
@property (nonatomic, strong) UIViewController *presentingViewController;

- (FBInterstitialAd *)masquerade;
- (void)loadAd;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;

- (void)simulateFailingToLoad;
- (void)simulateLoadingAd;
- (void)simulateUserDismissingAd;
- (void)simulateUserDismissedAd;
- (void)simulateUserInteraction;
@end
