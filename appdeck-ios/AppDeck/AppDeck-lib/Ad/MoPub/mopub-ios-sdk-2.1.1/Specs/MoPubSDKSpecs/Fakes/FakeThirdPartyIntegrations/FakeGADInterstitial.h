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

@property (nonatomic, assign) NSString *adUnitID;
@property (nonatomic, assign) id<GADInterstitialDelegate> delegate;
@property (nonatomic, assign) GADRequest *loadedRequest;
@property (nonatomic, assign) UIViewController *presentingViewController;

- (GADInterstitial *)masquerade;
- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserDismissingAd;
- (void)simulateUserInteraction;

@end
