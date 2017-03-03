//
//  MPRewardedVideo+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <MoPub/MoPub.h>
#import "MPRewardedVideoAdManager.h"

@interface MPRewardedVideo (MPSpecs) <MPRewardedVideoAdManagerDelegate>

@property (nonatomic, readonly) NSMutableDictionary *rewardedVideoAdManagers;
@property (nonatomic, readwrite) id<MPRewardedVideoDelegate> delegate;

+ (MPRewardedVideo *)sharedInstance;

@end
