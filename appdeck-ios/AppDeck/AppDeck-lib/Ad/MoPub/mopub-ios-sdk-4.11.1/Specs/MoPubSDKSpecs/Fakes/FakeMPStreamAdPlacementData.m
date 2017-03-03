//
//  FakeMPStreamAdPlacementData.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeMPStreamAdPlacementData.h"

@interface FakeMPStreamAdPlacementData ()

@property (nonatomic, strong) NSMutableDictionary *indexPathToAdDataDictionary;

@end

@implementation FakeMPStreamAdPlacementData

- (instancetype)init
{
    if (self = [super init]) {
        _indexPathToAdDataDictionary = [[NSMutableDictionary alloc] init];
    }

    return self;
}


- (MPStreamAdPlacementData *)masquerade
{
    return (MPStreamAdPlacementData *)self;
}

- (void)insertAdData:(MPNativeAdData *)data atIndexPath:(NSIndexPath *)originalIndexPath
{
    NSUInteger adCountBeforeIndexPath = 0;

    for (NSIndexPath *adIndexPath in [self.indexPathToAdDataDictionary allKeys]) {
        if (adIndexPath.section == originalIndexPath.section && adIndexPath.row <= originalIndexPath.row) {
            ++adCountBeforeIndexPath;
        }
    }

    NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:adCountBeforeIndexPath+originalIndexPath.row inSection:originalIndexPath.section];
    self.indexPathToAdDataDictionary[adjustedIndexPath] = data;
}

- (BOOL)isAdAtAdjustedIndexPath:(NSIndexPath *)adjustedIndexPath
{
    return NO;
}

@end
