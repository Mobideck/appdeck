//
//  MPTableViewAdPlacer+Specs.h
//  MoPubSDK
//
//  Created by Evan Davis on 8/19/14.
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPTableViewAdPlacer.h"

@interface MPTableViewAdPlacer (Specs)

@property (nonatomic, readonly) MPStreamAdPlacer *streamAdPlacer;
@property (nonatomic, readonly) id<UITableViewDataSource> originalDataSource;
@property (nonatomic, readonly) id<UITableViewDelegate> originalDelegate;

- (void)updateVisibleCells;

@end
