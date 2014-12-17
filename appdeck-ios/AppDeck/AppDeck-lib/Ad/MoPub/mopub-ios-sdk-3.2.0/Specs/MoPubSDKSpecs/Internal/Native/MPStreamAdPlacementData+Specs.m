//
//  MPStreamAdPlacementData+Specs.m
//  MoPubSDK
//
//  Created by Evan Davis on 8/19/14.
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPStreamAdPlacementData+Specs.h"

@interface MPStreamAdPlacementData ()

@property (nonatomic, retain) NSMutableDictionary *desiredOriginalPositions;
@property (nonatomic, retain) NSMutableDictionary *desiredInsertionPositions;
@property (nonatomic, retain) NSMutableDictionary *originalAdIndexPaths;
@property (nonatomic, retain) NSMutableDictionary *adjustedAdIndexPaths;
@property (nonatomic, retain) NSMutableDictionary *adDataObjects;

@end

@implementation MPStreamAdPlacementData (Private)

- (NSArray *)originalAdIndexPathsForSection:(NSInteger)section
{
    return [self.originalAdIndexPaths objectForKey:@(section)];
}

- (NSArray *)adjustedAdIndexPathsForSection:(NSInteger)section
{
    return [self.adjustedAdIndexPaths objectForKey:@(section)];
}

- (NSArray *)desiredOriginalAdIndexPathsForSection:(NSInteger)section
{
    return [self.desiredOriginalPositions objectForKey:@(section)];
}

- (NSArray *)desiredInsertionAdIndexPathsForSection:(NSInteger)section
{
    return [self.desiredInsertionPositions objectForKey:@(section)];
}
@end
