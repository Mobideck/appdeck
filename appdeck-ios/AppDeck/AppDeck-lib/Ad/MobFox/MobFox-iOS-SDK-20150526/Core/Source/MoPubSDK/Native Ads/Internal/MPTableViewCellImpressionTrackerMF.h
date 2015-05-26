//
//  MPTableViewCellImpressionTracker.h
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MPTableViewCellImpressionTrackerDelegateMF;

@interface MPTableViewCellImpressionTrackerMF : NSObject

- (id)initWithTableView:(UITableView *)tableView delegate:(id<MPTableViewCellImpressionTrackerDelegateMF>)delegate;
- (void)startTracking;
- (void)stopTracking;

@end

@protocol MPTableViewCellImpressionTrackerDelegateMF <NSObject>

- (void)tracker:(MPTableViewCellImpressionTrackerMF *)tracker didDetectVisibleRowsAtIndexPaths:(NSArray *)indexPaths;

@end