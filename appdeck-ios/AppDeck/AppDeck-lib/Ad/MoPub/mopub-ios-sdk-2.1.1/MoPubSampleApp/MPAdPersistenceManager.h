//
//  MPAdPersistenceManager.h
//  MoPubSampleApp
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdInfo;

@interface MPAdPersistenceManager : NSObject
{
    NSMutableArray *_savedAds;
}

@property (nonatomic, readonly) NSArray *savedAds;

+ (MPAdPersistenceManager *)sharedManager;

- (void)addSavedAd:(MPAdInfo *)adInfo;
- (void)removeSavedAd:(MPAdInfo *)adInfo;
- (MPAdInfo *)savedAdForID:(NSString *)adID;

@end
