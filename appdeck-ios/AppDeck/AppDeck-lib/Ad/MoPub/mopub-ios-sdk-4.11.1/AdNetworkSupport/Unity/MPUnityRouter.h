//
//  MPUnityRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>

@protocol MPUnityRouterDelegate;
@class UnityAdsInstanceMediationSettings;

@interface MPUnityRouter : NSObject <UnityAdsDelegate>

@property (nonatomic, weak) id<MPUnityRouterDelegate> delegate;

+ (MPUnityRouter *)sharedRouter;

- (void)requestRewardedVideoAdWithGameId:(NSString *)gameId zoneId:(NSString *)zoneId delegate:(id<MPUnityRouterDelegate>)delegate;
- (BOOL)isAdAvailableForZoneId:(NSString *)zoneId;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId zoneId:(NSString *)zoneId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate;
- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate;

@end

@protocol MPUnityRouterDelegate <NSObject>

- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped;
- (void)unityAdsWillShow;
- (void)unityAdsDidShow;
- (void)unityAdsWillHide;
- (void)unityAdsDidHide;
- (void)unityAdsWillLeaveApplication;
- (void)unityAdsFetchCompleted;
- (void)unityAdsDidFailWithError:(NSError *)error;

@end
