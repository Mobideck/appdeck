//
//  MPAdPersistenceManager.m
//  MoPubSampleApp
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdPersistenceManager.h"
#import "MPAdInfo.h"

#define kSavedAdsInfoKey @"com.mopub.adunitids"

@implementation MPAdPersistenceManager

@synthesize savedAds = _savedAds;

static MPAdPersistenceManager *sharedManager = nil;

+ (MPAdPersistenceManager *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _savedAds = [NSMutableArray array];
        [self loadSavedAds];
    }
    return self;
}

- (void)loadSavedAds
{
    NSData *persistedData = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedAdsInfoKey];
    if (persistedData != nil) {
        NSArray *persistedArray = [NSKeyedUnarchiver unarchiveObjectWithData:persistedData];
        if (persistedArray != nil) {
            [_savedAds addObjectsFromArray:persistedArray];
        }
    }
}

- (void)persistSavedAds
{
    NSData *persistData = [NSKeyedArchiver archivedDataWithRootObject:_savedAds];
    
    [[NSUserDefaults standardUserDefaults] setObject:persistData forKey:kSavedAdsInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (MPAdInfo *)savedAdForID:(NSString *)adID
{
    MPAdInfo *target = nil;
    
    for (MPAdInfo *ad in self.savedAds) {
        if ([ad.ID isEqualToString:adID]) {
            target = ad;
            break;
        }
    }
    
    return target;
}

- (void)addSavedAd:(MPAdInfo *)adInfo
{
    // overwrite if this ad unit id already exists
    [self removeSavedAd:adInfo];
    
    [_savedAds addObject:adInfo];
    
    [self persistSavedAds];
}

- (void)removeSavedAd:(MPAdInfo *)adInfo
{
    MPAdInfo *target = [self savedAdForID:adInfo.ID];
    if (target != nil) {
        [_savedAds removeObject:target];
        [self persistSavedAds];
    }
}

@end
