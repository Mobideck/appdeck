//
//  MPStreamAdPlacer+Specs.h
//  MoPubSDK
//
//  Created by Evan Davis on 8/19/14.
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPStreamAdPlacer.h"
@class MPNativeAdData;

@interface MPStreamAdPlacer (Specs)

@property (nonatomic, retain) NSString *adUnitID;
@property (nonatomic, retain) NSMutableDictionary *sectionCounts;
@property (nonatomic, retain) NSIndexPath *topConsideredIndexPath;
@property (nonatomic, retain) NSIndexPath *bottomConsideredIndexPath;
@property (nonatomic, retain) MPStreamAdPlacementData *adPlacementData;

- (NSIndexPath *)furthestValidIndexPathAfterIndexPath:(NSIndexPath *)startingPath withinDistance:(NSUInteger)numberOfItems;
- (NSIndexPath *)earliestValidIndexPathBeforeIndexPath:(NSIndexPath *)startingPath withinDistance:(NSUInteger)numberOfItems;
- (BOOL)shouldPlaceAdAtIndexPath:(NSIndexPath *)insertionPath;
- (MPNativeAdData *)retrieveAdDataForInsertionPath:(NSIndexPath *)insertionPath;
- (void)fillAdsInConsideredRange;

@end
