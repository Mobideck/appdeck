//
//  MPCollectionViewAdPlacer+Specs.h
//  MoPubSDK
//
//  Created by Evan Davis on 8/19/14.
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPCollectionViewAdPlacer.h"

@interface MPCollectionViewAdPlacer (Specs)

@property (nonatomic, readonly) MPStreamAdPlacer *streamAdPlacer;
@property (nonatomic, readonly) id<UICollectionViewDataSource> originalDataSource;
@property (nonatomic, readonly) id<UICollectionViewDelegate> originalDelegate;

- (void)updateVisibleCells;

@end
