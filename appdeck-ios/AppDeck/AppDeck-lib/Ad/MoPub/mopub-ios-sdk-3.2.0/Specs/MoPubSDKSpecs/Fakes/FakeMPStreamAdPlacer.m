//
//  FakeMPStreamAdPlacer.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeMPStreamAdPlacer.h"

@implementation FakeMPStreamAdPlacer

- (NSString *)reuseIdentifierForRenderingClassAtIndexPath:(NSIndexPath *)indexPath
{
    return @"FAKE_reuse_identifier";
}

- (void)insertItemsAtIndexPaths:(NSArray *)originalIndexPaths
{
    self.didInsertItems = YES;
}

- (NSIndexPath *)adjustedIndexPathForOriginalIndexPath:(NSIndexPath *)indexPath
{
    if (!self.didInsertItems) {
        return indexPath;
    } else {
        NSUInteger indexes[2] = {[indexPath indexAtPosition:0], [indexPath indexAtPosition:1] + 1};
        return [NSIndexPath indexPathWithIndexes:indexes length:2];
    }
}

- (NSArray *)adjustedIndexPathsForOriginalIndexPaths:(NSArray *)indexPaths
{
    if (!self.didInsertItems) {
        return indexPaths;
    }

    NSMutableArray *array = [NSMutableArray array];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [array addObject:[self adjustedIndexPathForOriginalIndexPath:indexPath]];
    }];
    return array;
}

@end
