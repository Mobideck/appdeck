//
//  MPStreamAdPlacementData+Specs.h
//  MoPubSDK
//
//  Created by Evan Davis on 8/19/14.
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPStreamAdPlacementData.h"

@interface MPStreamAdPlacementData (Specs)

- (NSArray *)originalAdIndexPathsForSection:(NSInteger)section;
- (NSArray *)adjustedAdIndexPathsForSection:(NSInteger)section;
- (NSArray *)desiredOriginalAdIndexPathsForSection:(NSInteger)section;
- (NSArray *)desiredInsertionAdIndexPathsForSection:(NSInteger)section;

@end
