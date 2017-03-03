//
//  MPVungleRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>

@protocol MPVungleRouterDelegate;
@class VungleInstanceMediationSettings;

@interface MPVungleRouter : NSObject <VungleSDKDelegate>

@property (nonatomic, weak) id<MPVungleRouterDelegate> delegate;

+ (void)setAppId:(NSString *)appId;

+ (MPVungleRouter *)sharedRouter;

- (void)requestInterstitialAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate;
- (void)requestRewardedVideoAdWithCustomEventInfo:(NSDictionary *)info delegate:(id<MPVungleRouterDelegate>)delegate;
- (BOOL)isAdAvailable;
- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController withDelegate:(id<MPVungleRouterDelegate>)delegate;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId settings:(VungleInstanceMediationSettings *)settings delegate:(id<MPVungleRouterDelegate>)delegate;
- (void)clearDelegate:(id<MPVungleRouterDelegate>)delegate;
@end

@protocol MPVungleRouterDelegate <NSObject>

- (void)vungleAdDidLoad;
- (void)vungleAdWillAppear;
- (void)vungleAdWillDisappear;
- (void)vungleAdWasTapped;
- (void)vungleAdDidFailToPlay:(NSError *)error;
- (void)vungleAdDidFailToLoad:(NSError *)error;

@optional

- (void)vungleAdShouldRewardUser;

@end
