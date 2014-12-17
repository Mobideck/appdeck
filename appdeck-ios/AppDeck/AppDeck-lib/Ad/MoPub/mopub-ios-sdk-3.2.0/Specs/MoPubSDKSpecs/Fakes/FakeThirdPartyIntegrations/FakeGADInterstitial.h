//
//  FakeGADInterstitial.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GADInterstitial;
@class GADRequest;

@protocol GADInterstitialDelegate;

@interface FakeGADInterstitial : NSObject <FakeInterstitialAd>

@property (nonatomic, copy) NSString *adUnitID;
@property (nonatomic, weak) id<GADInterstitialDelegate> delegate;
@property (nonatomic, strong) GADRequest *loadedRequest;
@property (nonatomic, strong) UIViewController *presentingViewController;

- (GADInterstitial *)masquerade;
- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserDismissingAd;
- (void)simulateUserInteraction;

@end
