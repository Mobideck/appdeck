//
//  MPRewardedVideoAdManager+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPRewardedVideoAdManager.h"
#import "MPAdServerCommunicator.h"
#import "MPRewardedVideoAdapter.h"

@interface MPRewardedVideoAdManager (MPSpecs) <MPAdServerCommunicatorDelegate, MPRewardedVideoAdapterDelegate>

@property (nonatomic, readwrite) BOOL ready;
@property (nonatomic, readonly) BOOL loading;
@property (nonatomic, readonly) BOOL playedAd;

@end
