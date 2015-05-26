//
//  MPTableViewAdManager.m
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPTableViewAdManagerMF.h"

#import "MPTableViewCellImpressionTrackerMF.h"
#import "MPNativeAdMF+Internal.h"
#import "MpLoggingMF.h"
#import "MPNativeAdRenderingMF.h"
#import "UITableViewCell+MPNativeAdMF.h"

@interface MPTableViewAdManagerMF () <MPTableViewCellImpressionTrackerDelegateMF>

@property (nonatomic, retain) NSMutableSet *ads;
@property (nonatomic, retain) NSMutableSet *cells;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) MPTableViewCellImpressionTrackerMF *impressionTracker;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPTableViewAdManagerMF

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        _tableView = [tableView retain];
        _impressionTracker = [[MPTableViewCellImpressionTrackerMF alloc] initWithTableView:tableView
                                                                                 delegate:self];
        [_impressionTracker startTracking];

        _ads = [[NSMutableSet alloc] init];
        _cells = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self removeAssociatedAdObjectsFromCells];

    [_tableView release];
    [_impressionTracker stopTracking];
    [_impressionTracker release];
    [_ads release];
    [_cells release];

    [super dealloc];
}

- (void)removeAssociatedAdObjectsFromCells
{
    for (UITableViewCell *cell in _cells) {
        [cell mp_removeNativeAd];
    }
}

- (UITableViewCell *)adCellForAd:(MPNativeAdMF *)adObject cellClass:(Class)cellClass
{
    NSString *identifier = [NSString stringWithFormat:@"MP_Cell_Class_%@", NSStringFromClass(cellClass)];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [self.cells addObject:cell];
    }

    [self.ads addObject:adObject];
    [cell mp_setNativeAd:adObject];

    if ([cell conformsToProtocol:@protocol(MPNativeAdRenderingMF)]) {
        [adObject willAttachToView:cell];
        [(id<MPNativeAdRenderingMF>)cell layoutAdAssets:adObject];
    } else {
        MPLogWarnMF(@"A cell class (%@) passed to -adCellForAd:cellClass: does not conform to the "
                  @"MPNativeAdRendering protocol. The resultant cell will not display any ad assets.",
                  NSStringFromClass(cellClass));
    }

    return cell;
}

#pragma mark - <MPTableViewCellImpressionTracker>

- (void)tracker:(MPTableViewCellImpressionTrackerMF *)tracker didDetectVisibleRowsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableSet *visibleAds = [NSMutableSet set];

    for (NSIndexPath *path in indexPaths) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        if ([self.cells containsObject:cell]) {
            MPNativeAdMF *ad = [cell mp_nativeAd];

            // Edge case: if the same ad is being displayed in multiple on-screen cells,
            // simultaneously, don't set its visibility more than once (side effects).
            if (![visibleAds containsObject:ad]) {
                ad.visible = YES;
                [visibleAds addObject:ad];
            }
        }
    }

    NSMutableSet *invisibleAds = [NSMutableSet setWithSet:self.ads];
    [invisibleAds minusSet:visibleAds];

    for (MPNativeAdMF *ad in invisibleAds) {
        ad.visible = NO;
    }
}

@end
