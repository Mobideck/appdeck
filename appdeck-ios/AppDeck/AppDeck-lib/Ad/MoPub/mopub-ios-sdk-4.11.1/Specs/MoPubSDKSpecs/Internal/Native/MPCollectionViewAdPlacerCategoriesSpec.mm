#import "MPCollectionViewAdPlacer.h"
#import "MPAdPositioning.h"
#import "MPNativeAdRendering.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPCollectionNativeAdCell : UICollectionViewCell <MPNativeAdRendering>
@end

@implementation MPCollectionNativeAdCell
@end

static NSString *const kReuseIdentifier = @"reuseCell";

@interface CollectionViewDataSourceDelegateHelper : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, retain) NSMutableArray *content;
- (void)resetDataSource;
- (void)addItemToSection:(NSInteger)section;
@end

@implementation CollectionViewDataSourceDelegateHelper
- (id)init {
    self = [super init];
    if (self) {
        [self resetDataSource];
    }
    return self;
}

- (void)resetDataSource
{
    self.content = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        NSMutableArray *section = [NSMutableArray array];

        for (int j = 0; j < 10; j++) {
            [section addObject:@(j)];
        }

        [self.content addObject:section];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.content count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.content[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)addItemToSection:(NSInteger)section
{
    [self.content[section] addObject:@"new item"];
}

@end

SPEC_BEGIN(MPCollectionViewAdPlacerCategoriesSpec)

describe(@"MPCollectionViewAdPlacerCategories", ^{
    __block MPCollectionViewAdPlacer *placer;
    __block UICollectionView *collectionView;
    __block CollectionViewDataSourceDelegateHelper *helper;
    __block id<UICollectionViewDataSource> dataSource;
    __block id<UICollectionViewDelegate> delegate;
    __block UICollectionView *placerlessCollectionView;
    __block MPStaticNativeAdRenderer *renderer;
    __block NSArray *nativeAdRendererConfigurations;

    beforeEach(^{
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];

        settings.renderingViewClass = [MPCollectionNativeAdCell class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) {
            return CGSizeMake(70, 113);
        };

        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

        MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
        nativeAdRendererConfigurations = @[config];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(320, 44);

        collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) collectionViewLayout:layout];

        helper = [[CollectionViewDataSourceDelegateHelper alloc] init];
        delegate = helper;
        dataSource = helper;

        collectionView.delegate = delegate;
        collectionView.dataSource = dataSource;

        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kReuseIdentifier];

        UIViewController *viewController = [[UIViewController alloc] init];

        MPAdPositioning *fakePositioning = nice_fake_for([MPAdPositioning class]);

        FakeMPStreamAdPlacer *fakeStreamAdPlacer = [FakeMPStreamAdPlacer placerWithViewController:viewController adPositioning:fakePositioning rendererConfigurations:nativeAdRendererConfigurations];
        fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;

        placer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:viewController adPositioning:fakePositioning rendererConfigurations:nativeAdRendererConfigurations];

        UICollectionViewFlowLayout *secondLayout = [[UICollectionViewFlowLayout alloc] init];
        secondLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        secondLayout.itemSize = CGSizeMake(320, 44);

        placerlessCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) collectionViewLayout:secondLayout];
        placerlessCollectionView.delegate = delegate;
        placerlessCollectionView.dataSource = dataSource;

        [placerlessCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kReuseIdentifier];


        [collectionView numberOfSections];
        [placerlessCollectionView numberOfSections];

        spy_on(placerlessCollectionView);
        spy_on(fakeStreamAdPlacer);
    });

    it(@"should return the original delegate", ^{
        [collectionView mp_delegate] should be_same_instance_as(delegate);
    });

    it(@"should return the original datasource", ^{
        [collectionView mp_dataSource] should be_same_instance_as(dataSource);
    });

    describe(@"mp_setDelegate", ^{
        __block id<UICollectionViewDelegate> newDelegate;

        beforeEach(^{
            newDelegate = nice_fake_for(@protocol(UICollectionViewDelegate));
        });

        it(@"should return the new delegate when calling mp_delegate", ^{
            [collectionView mp_setDelegate: newDelegate];
            [collectionView mp_delegate] should be_same_instance_as(newDelegate);
        });

        it(@"should function as setDelegate when there is no adplacer", ^{
            [placerlessCollectionView mp_setDelegate:newDelegate];
            placerlessCollectionView.delegate should be_same_instance_as(newDelegate);
        });
    });

    describe(@"mp_setDataSource", ^{
        __block id<UICollectionViewDataSource> newDataSource;

        beforeEach(^{
            newDataSource = nice_fake_for(@protocol(UICollectionViewDataSource));
        });

        it(@"should return the new dataSource when calling mp_dataSource", ^{
            [collectionView mp_setDataSource: newDataSource];
            [collectionView mp_dataSource] should be_same_instance_as(newDataSource);
        });

        it(@"should function as setDataSource when there is no adplacer", ^{
            [placerlessCollectionView mp_setDataSource:newDataSource];
            placerlessCollectionView.dataSource should be_same_instance_as(newDataSource);
        });
    });

    describe(@"mp_dequeueReusableCellWithReuseIdentifier:forIndexPath:", ^{
        // TODO

        xit(@"should get the proper cell for the row, if the row is not an ad", ^{

        });

        xit(@"should return nil, if the row is an ad", ^{

        });

        xit(@"should call dequeueReusableCellWithReuseIdentifier:forIndexPath: with the given index path when there is no ad placer", ^{
        });
    });

    describe(@"mp_indexPathsForSelectedItems:", ^{
        // TODO

        xit(@"should get the original index paths for the items, if the items are not ads", ^{

        });

        xit(@"should not include indexpaths for items that are ads", ^{

        });

        xit(@"should forward to indexPathsForSelectedItems when there is no ad placer", ^{

        });
    });

    describe(@"mp_selectItemAtIndexPath:animated:scrollPosition:", ^{
        xit(@"should call selectItemAtIndexPath on the original collection view with adjusted indexpath", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(9, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(collectionView);
            [collectionView mp_selectItemAtIndexPath:_IP(8, 0) animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            collectionView should have_received(@selector(selectItemAtIndexPath:animated:scrollPosition:)).with(_IP(9, 0)).and_with(YES).and_with(UICollectionViewScrollPositionCenteredVertically);
        });

        it(@"should call selectItemAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessCollectionView mp_selectItemAtIndexPath:_IP(8, 0) animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            placerlessCollectionView should have_received(@selector(selectItemAtIndexPath:animated:scrollPosition:)).with(_IP(8, 0)).and_with(YES).and_with(UICollectionViewScrollPositionCenteredVertically);
        });
    });

    describe(@"mp_deselectItemAtIndexPath:animated:", ^{
        it(@"should call deselectItemAtIndexPath on the original collection view with adjusted indexpath", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(9, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(collectionView);
            [collectionView mp_deselectItemAtIndexPath:_IP(8, 0) animated:YES];
            collectionView should have_received(@selector(deselectItemAtIndexPath:animated:)).with(_IP(9, 0)).and_with(YES);
        });

        it(@"should call deselectItemAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessCollectionView mp_deselectItemAtIndexPath:_IP(8, 0) animated:YES];
            placerlessCollectionView should have_received(@selector(deselectItemAtIndexPath:animated:)).with(_IP(8, 0)).and_with(YES);
        });
    });

    describe(@"mp_layoutAttributesForItemAtIndexPath:", ^{
        xit(@"should call layoutAttributesForItemAtIndexPath: on the original collection view with adjusted indexpath", ^{\
            // TODO: figure out why this is breaking

            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(9, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(collectionView);
            [collectionView mp_layoutAttributesForItemAtIndexPath:_IP(8, 0)];
            collectionView should have_received(@selector(layoutAttributesForItemAtIndexPath:)).with(_IP(9, 0));
        });

        it(@"should call layoutAttributesForItemAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessCollectionView mp_layoutAttributesForItemAtIndexPath:_IP(8, 0)];
            placerlessCollectionView should have_received(@selector(layoutAttributesForItemAtIndexPath:)).with(_IP(8, 0));
        });
    });

    describe(@"mp_indexPathForItemAtPoint:", ^{
        it(@"should get the original index path for the item, if the item is not an ad", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(_IP(0, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(collectionView);
            [collectionView mp_indexPathForItemAtPoint:CGPointMake(60, 60)] should equal(_IP(0, 0));

            // TODO: figure out why this isn't working
            // fakeProvider.fakeStreamAdPlacer should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(_IP(1, 0));
        });

        it(@"should return nil, if the item is an ad", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(nil);

            spy_on(collectionView);
            [collectionView mp_indexPathForItemAtPoint:CGPointMake(20, 20)] should be_nil;
        });

        it(@"should call indexPathForItemAtPoint: with the given index path when there is no ad placer", ^{
            [placerlessCollectionView mp_indexPathForItemAtPoint:CGPointMake(20, 20)];
            placerlessCollectionView should have_received(@selector(indexPathForItemAtPoint:)).with(CGPointMake(20, 20));
        });
    });

    describe(@"mp_indexPathForCell:", ^{
        // TODO: not sure what to use for the Cell argument
        xit(@"should get the original index path for the row, if the row is not an ad", ^{

        });

        xit(@"should return nil, if the row is an ad", ^{

        });

        xit(@"should call indexPathForCell: with the given cell when there is no ad placer", ^{

        });
    });

    describe(@"mp_cellForItemAtIndexPath:", ^{
        it(@"should call cellForItemAtIndexPath on the original collection view with adjusted indexpaths", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(9, 0));

            spy_on(collectionView);
            [collectionView mp_cellForItemAtIndexPath:_IP(8, 0)];
            collectionView should have_received(@selector(cellForItemAtIndexPath:)).with(_IP(9, 0));
        });

        it(@"should call cellForItemAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessCollectionView mp_cellForItemAtIndexPath:_IP(8, 0)];
            placerlessCollectionView should have_received(@selector(cellForItemAtIndexPath:)).with(_IP(8, 0));
        });
    });

    describe(@"mp_visibleCells", ^{
        context(@"when there is an ad placer", ^{
            beforeEach(^{
                fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathsForAdjustedIndexPaths:)).and_return(@[_IP(0, 0)]);
                fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).with(_IP(0, 0)).and_return(_IP(1, 0));
                spy_on(collectionView);
                collectionView stub_method(@selector(visibleCells)).and_return(@[[MPCollectionNativeAdCell new], [UICollectionViewCell new]]);
                collectionView stub_method(@selector(indexPathsForVisibleItems)).and_return(@[_IP(0, 0), _IP(1, 0)]);
                collectionView stub_method(@selector(cellForItemAtIndexPath:)).and_return([UICollectionViewCell new]);
            });

            it(@"should get the cells for the rows, if the rows are not ads", ^{
                NSArray *visibleCells = [collectionView mp_visibleCells];
                visibleCells.count should equal(1);
            });

            it(@"should not include cells for rows that are ads", ^{
                NSArray *visibleCells = [collectionView mp_visibleCells];
                for (UICollectionViewCell *cell in visibleCells) {
                    [cell isKindOfClass:[UICollectionViewCell class]] should be_truthy;
                }
            });
        });

        context(@"when there is no ad placer", ^{
            it(@"should forward to visibleCells when there is no ad placer", ^{
                NSArray *visibleCells = [placerlessCollectionView mp_visibleCells];
                visibleCells = nil;
                placerlessCollectionView should have_received(@selector(visibleCells));
            });
        });
    });

    describe(@"mp_indexPathsForVisibleItems", ^{
        // TODO
        xit(@"should get the original index paths for the rows, if the rows are not ads", ^{

        });

        xit(@"should not include indexpaths for rows that are ads", ^{

        });

        xit(@"should forward to indexPathsForVisibleItem: when there is no ad placer", ^{

        });
    });

    describe(@"mp_scrollToItemAtIndexPath:atScrollPosition:animated:", ^{
        xit(@"should call scrollToItemAtIndexPath on the original collection view with adjusted indexpaths", ^{
            // TODO: fix this test

            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(9, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(collectionView);
            [collectionView mp_scrollToItemAtIndexPath:_IP(8, 0) atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            collectionView should have_received(@selector(scrollToItemAtIndexPath:atScrollPosition:animated:)).with(_IP(9, 0)).and_with(UICollectionViewScrollPositionTop).and_with(YES);
        });

        it(@"should call scrollToItemAtIndexPath with the given index path when there is no ad placer", ^{
            [placerlessCollectionView mp_selectItemAtIndexPath:_IP(8, 0) animated:YES scrollPosition:UICollectionViewScrollPositionTop];
            placerlessCollectionView should have_received(@selector(scrollToItemAtIndexPath:atScrollPosition:animated:)).with(_IP(8, 0)).and_with(UICollectionViewScrollPositionTop).and_with(YES);
        });
    });

    describe(@"mp_insertSections:", ^{
        __block NSIndexSet *toInsert;

        beforeEach(^{
            toInsert = [NSIndexSet indexSetWithIndex:4];

            NSUInteger index = [toInsert firstIndex];
            while (index != NSNotFound) {
                [helper.content insertObject:[NSMutableArray array] atIndex:index];
                index = [toInsert indexGreaterThanIndex:index];
            }
        });

        it(@"should forward the message to the underlying StreamAdPlacer and then to the CollectionView", ^{
            spy_on(collectionView);

            [collectionView mp_insertSections:toInsert];

            fakeProvider.fakeStreamAdPlacer should have_received(@selector(insertSections:)).with(toInsert);
            collectionView should have_received(@selector(insertSections:)).with(toInsert);
        });

        it(@"should forward the message to the CollectionView when there is no AdPlacer", ^{
            [placerlessCollectionView mp_insertSections:toInsert];
            placerlessCollectionView should have_received(@selector(insertSections:)).with(toInsert);
        });
    });

    describe(@"mp_deleteSections:", ^{
        __block NSIndexSet *toDelete;

        beforeEach(^{
            toDelete = [NSIndexSet indexSetWithIndex:4];

            [helper.content removeObjectsAtIndexes:toDelete];
        });

        it(@"should forward the message to the underlying StreamAdPlacer and then to the CollectionView", ^{
            spy_on(collectionView);
            [collectionView mp_deleteSections:toDelete];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(deleteSections:)).with(toDelete);
            collectionView should have_received(@selector(deleteSections:)).with(toDelete);
        });

        it(@"should forward the message to the CollectionView when there is no AdPlacer", ^{
            [placerlessCollectionView mp_deleteSections:toDelete];
            placerlessCollectionView should have_received(@selector(deleteSections:)).with(toDelete);
        });
    });

    describe(@"mp_moveSection:toSection:", ^{
        __block int from;
        __block int to;

        beforeEach(^{
            from = 0;
            to = 5;

            id object = [helper.content objectAtIndex:from];
            [helper.content removeObjectAtIndex:from];
            [helper.content insertObject:object atIndex:to];
        });

        it(@"should forward the message to the underlying StreamAdPlacer and then to the CollectionView", ^{
            spy_on(collectionView);
            [collectionView mp_moveSection:from toSection:to];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(moveSection:toSection:)).with(from).and_with(to);
            collectionView should have_received(@selector(moveSection:toSection:)).with(from).and_with(to);
        });

        it(@"should forward the message to the CollectionView when there is no AdPlacer", ^{
            [placerlessCollectionView mp_moveSection:from toSection:to];
            placerlessCollectionView should have_received(@selector(moveSection:toSection:)).with(from).and_with(to);
        });
    });

    describe(@"mp_insertItemsAtIndexPaths:", ^{
        __block NSArray *toInsert;

        beforeEach(^{
            toInsert = @[_IP(0, 0), _IP(1, 0)];

            // Modify our data source to actually add items, otherwise UICollectionView complains about internal inconsistency.
            [helper addItemToSection:0];
            [helper addItemToSection:0];
        });

        it(@"should forward the message to the underlying stream ad placer", ^{
            [collectionView mp_insertItemsAtIndexPaths:toInsert];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(insertItemsAtIndexPaths:)).with(toInsert);
        });

        it(@"should insert items from the collection view using adjusted index paths", ^{
            spy_on(collectionView);
            [collectionView mp_insertItemsAtIndexPaths:toInsert];

            // Test to see if the index paths have been incremented by one item. For simplicity, the
            // fake stream ad placer increments index paths by one item as long as it has received
            // any -insertItemsAtIndexPaths: calls.
            collectionView should have_received(@selector(insertItemsAtIndexPaths:)).with(@[_IP(1, 0), _IP(2, 0)]);
        });

        it(@"should insert items into the collection view without adjusting the index paths when there is no ad placer", ^{
            [placerlessCollectionView mp_insertItemsAtIndexPaths:toInsert];
            placerlessCollectionView should have_received(@selector(insertItemsAtIndexPaths:)).with(toInsert);
        });
    });

    describe(@"mp_deleteItemsAtIndexPaths:", ^{
        __block NSArray *toDelete;

        beforeEach(^{
            toDelete = @[_IP(0, 0), _IP(1, 0)];

            for (NSIndexPath *index in toDelete) {
                [helper.content[index.section] removeObjectAtIndex:index.item];
            }

            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *originalIndexPath) {
                return _IP(originalIndexPath.item + 1, originalIndexPath.section);
            });
        });

        it(@"should forward the message to the underlying stream ad placer", ^{
            [collectionView mp_deleteItemsAtIndexPaths:toDelete];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(deleteItemsAtIndexPaths:)).with(toDelete);
        });

        xit(@"should delete items from the collection view using adjusted index paths", ^{
            spy_on(collectionView);
            [collectionView mp_deleteItemsAtIndexPaths:toDelete];
            // TODO: come back and fix this once we implement a real StreamAdPlacer
            collectionView should have_received(@selector(deleteItemsAtIndexPaths:)).with(@[_IP(1, 0), _IP(2, 0)]);
        });

        it(@"should delete items from the collection view without adjusting the index paths when there is no ad placer", ^{
            [placerlessCollectionView mp_deleteItemsAtIndexPaths:toDelete];
            placerlessCollectionView should have_received(@selector(deleteItemsAtIndexPaths:)).with(toDelete);
        });
    });

    describe(@"mp_moveItemAtIndexPath:toIndexPath:", ^{
        __block NSIndexPath *from;
        __block NSIndexPath *to;

        beforeEach(^{
            from = _IP(0,0);
            to = _IP(5,0);

            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *originalIndexPath) {
                return _IP(originalIndexPath.item + 1, originalIndexPath.section);
            });

            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_do_block(^NSUInteger (NSUInteger numberOfItems, NSUInteger section) {
                return numberOfItems + 1;
            });

            id object = [helper.content[from.section] objectAtIndex:from.item];
            [helper.content[from.section] removeObjectAtIndex:from.item];
            [helper.content[to.section] insertObject:object atIndex:to.item];

            // calling these so that the counts are updated
            [placerlessCollectionView numberOfItemsInSection:0];
            [collectionView numberOfItemsInSection:0];
        });

        xit(@"should forward the message to the underlying stream ad placer", ^{
            [collectionView mp_moveItemAtIndexPath:from toIndexPath:to];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(moveItemAtIndexPath:toIndexPath:)).with(from).and_with(to);
        });

        xit(@"should move items in the collection view using adjusted index paths", ^{
            spy_on(collectionView);
            [collectionView mp_moveItemAtIndexPath:from toIndexPath:to];
            collectionView should have_received(@selector(moveItemAtIndexPath:toIndexPath:)).with(_IP(1, 0)).and_with(_IP(6, 0));
        });

        it(@"should move items in the collection view without adjusting the index paths when there is no ad placer", ^{
            [placerlessCollectionView mp_moveItemAtIndexPath:from toIndexPath:to];
            placerlessCollectionView should have_received(@selector(moveItemAtIndexPath:toIndexPath:)).with(from).and_with(to);
        });
    });

    describe(@"mp_reloadItemsAtIndexPaths:", ^{
        __block NSArray *toReload;

        beforeEach(^{
            toReload = @[_IP(0, 0), _IP(1, 0)];
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *originalIndexPath) {
                return _IP(originalIndexPath.item + 1, originalIndexPath.section);
            });
        });


        xit(@"should reload items from the collection view using adjusted index paths", ^{
            spy_on(collectionView);
            // TODO: come back and fix this once we implement a real StreamAdPlacer

            [collectionView mp_reloadItemsAtIndexPaths:toReload];
            collectionView should have_received(@selector(reloadItemsAtIndexPaths:)).with(@[_IP(1, 0), _IP(2, 0)]);
        });

        it(@"should reload items from the collection view without adjusting the index paths when there is no ad placer", ^{
            [placerlessCollectionView mp_reloadItemsAtIndexPaths:toReload];
            placerlessCollectionView should have_received(@selector(reloadItemsAtIndexPaths:)).with(toReload);
        });
    });
});

SPEC_END
