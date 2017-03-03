#import "MPTableViewAdPlacer.h"
#import "MPNativeAdRendering.h"
#import "MPAdPositioning.h"
#import "MPNativeAdRendererConfiguration.h"
#import "FakeNativeAdRenderingClass.h"
#import "MPTableViewAdPlacerCell.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static NSString *const kReuseIdentifier = @"reuseCell";

@interface TableViewDataSourceDelegateHelper : NSObject <UITableViewDataSource, UITableViewDelegate>

@end

@implementation TableViewDataSourceDelegateHelper

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

SPEC_BEGIN(MPTableViewAdPlacerCategoriesSpec)

describe(@"MPTableViewAdPlacerCategories", ^{
    __block MPTableViewAdPlacer *placer;
    __block UITableView *tableView;
    __block id<UITableViewDataSource> dataSource;
    __block id<UITableViewDelegate> delegate;
    __block UITableView *placerlessTableView;
    __block MPStaticNativeAdRenderer *renderer;
    __block NSArray *nativeAdRendererConfigurations;

    beforeEach(^{
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];

        settings.renderingViewClass = [FakeNativeAdRenderingClass class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) {
            return CGSizeMake(70, 113);
        };

        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

        MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
        nativeAdRendererConfigurations = @[config];

        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];

        TableViewDataSourceDelegateHelper *helper = [[TableViewDataSourceDelegateHelper alloc] init];
        delegate = helper;
        dataSource = helper;

        tableView.delegate = delegate;
        tableView.dataSource = dataSource;

        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];

        UIViewController *viewController = [[UIViewController alloc] init];

        MPAdPositioning *fakePositioning = nice_fake_for([MPAdPositioning class]);
        FakeMPStreamAdPlacer *fakeStreamAdPlacer = [FakeMPStreamAdPlacer placerWithViewController:viewController adPositioning:fakePositioning rendererConfigurations:nativeAdRendererConfigurations];
        fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;

        placer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:viewController adPositioning:fakePositioning rendererConfigurations:nativeAdRendererConfigurations];

        placerlessTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        placerlessTableView.delegate = delegate;
        placerlessTableView.dataSource = dataSource;

        [placerlessTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];

        spy_on(placerlessTableView);
        spy_on(fakeStreamAdPlacer);
    });

    it(@"should return the original delegate", ^{
        [tableView mp_delegate] should be_same_instance_as(delegate);
    });

    it(@"should return the original datasource", ^{
        [tableView mp_dataSource] should be_same_instance_as(dataSource);
    });

    describe(@"mp_setDelegate", ^{
        __block id<UITableViewDelegate> newDelegate;

        beforeEach(^{
            newDelegate = nice_fake_for(@protocol(UITableViewDelegate));
        });

        it(@"should return the new delegate when calling mp_delegate", ^{
            [tableView mp_setDelegate: newDelegate];
            [tableView mp_delegate] should be_same_instance_as(newDelegate);
        });

        it(@"should function as setDelegate when there is no adplacer", ^{
            [placerlessTableView mp_setDelegate:newDelegate];
            placerlessTableView.delegate should be_same_instance_as(newDelegate);
        });
    });

    describe(@"mp_setDataSource", ^{
        __block id<UITableViewDataSource> newDataSource;

        beforeEach(^{
            newDataSource = nice_fake_for(@protocol(UITableViewDataSource));
        });

        it(@"should return the new dataSource when calling mp_dataSource", ^{
            [tableView mp_setDataSource: newDataSource];
            [tableView mp_dataSource] should be_same_instance_as(newDataSource);
        });

        it(@"should function as setDataSource when there is no adplacer", ^{
            [placerlessTableView mp_setDataSource:newDataSource];
            placerlessTableView.dataSource should be_same_instance_as(newDataSource);
        });
    });

    describe(@"mp_cellForRowAtIndexPath:", ^{
        it(@"should call cellForRowAtIndexPath on the original tableview with adjusted indexpaths", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(10, 0));

            spy_on(tableView);
            [tableView mp_cellForRowAtIndexPath:_IP(8, 0)];
            tableView should have_received(@selector(cellForRowAtIndexPath:)).with(_IP(10, 0));
        });

        it(@"should call cellForRowAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessTableView mp_cellForRowAtIndexPath:_IP(8, 0)];
            placerlessTableView should have_received(@selector(cellForRowAtIndexPath:)).with(_IP(8, 0));
        });
    });

    describe(@"mp_rectForRowAtIndexPath:", ^{
        it(@"should call rectForRowAtIndexPath on the original tableview with adjusted indexpaths", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(2, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(tableView);
            [tableView mp_rectForRowAtIndexPath:_IP(1, 0)];
            tableView should have_received(@selector(rectForRowAtIndexPath:)).with(_IP(2, 0));
        });

        it(@"should call rectForRowAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessTableView mp_rectForRowAtIndexPath:_IP(1, 0)];
            placerlessTableView should have_received(@selector(rectForRowAtIndexPath:)).with(_IP(1, 0));
        });
    });

    describe(@"mp_indexPathForRowAtPoint:", ^{
        xit(@"should get the original index path for the row, if the row is not an ad", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(_IP(0, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(tableView);
            // TODO: this tableview isn't in the view hierarchy so indexPathForRowAtPoint: will always return nill unless reloadData is called (and spy_on seems to interfere with that as well).
            [tableView reloadData];
            [tableView mp_indexPathForRowAtPoint:CGPointMake(20, 60)] should equal(_IP(0, 0));
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(_IP(1, 0));
        });

        xit(@"should return nil, if the row is an ad", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(nil);

            spy_on(tableView);
            [tableView reloadData];
            [tableView mp_indexPathForRowAtPoint:CGPointMake(20, 20)] should be_nil;
        });

        xit(@"should call indexPathForRowAtPoint: with the given index path when there is no ad placer", ^{
            [placerlessTableView mp_indexPathForRowAtPoint:CGPointMake(20, 20)];
            placerlessTableView should have_received(@selector(indexPathForRowAtPoint:)).with(CGPointMake(20, 20));
        });
    });

    describe(@"mp_indexPathForSelectedRow", ^{
        it(@"should get the original index path for the row, if the row is not an ad", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(_IP(0, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            [tableView selectRowAtIndexPath:_IP(1,0) animated:YES scrollPosition:UITableViewScrollPositionMiddle];

            spy_on(tableView);
            [tableView mp_indexPathForSelectedRow] should equal(_IP(0, 0));
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(_IP(1, 0));
        });

        it(@"should return nil, if the row is an ad", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(nil);

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            [tableView selectRowAtIndexPath:_IP(2,0) animated:YES scrollPosition:UITableViewScrollPositionMiddle];

            spy_on(tableView);
            [tableView mp_indexPathForSelectedRow] should be_nil;
        });

        it(@"should be the same as the selected indexpath when there is no ad placer", ^{
            [placerlessTableView selectRowAtIndexPath:_IP(2,0) animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [placerlessTableView mp_indexPathForSelectedRow] should equal(_IP(2,0));
        });
    });

    describe(@"mp_selectRowAtIndexPath:animated:scrollPosition:", ^{
        it(@"should call selectRowAtIndexPath on the original tableview with adjusted indexpaths", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(10, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(tableView);
            [tableView mp_selectRowAtIndexPath:_IP(8, 0) animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            tableView should have_received(@selector(selectRowAtIndexPath:animated:scrollPosition:)).with(_IP(10, 0)).and_with(YES).and_with(UITableViewScrollPositionMiddle);
        });

        it(@"should call selectRowAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessTableView mp_selectRowAtIndexPath:_IP(8, 0) animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            placerlessTableView should have_received(@selector(selectRowAtIndexPath:animated:scrollPosition:)).with(_IP(8, 0)).and_with(YES).and_with(UITableViewScrollPositionMiddle);
        });
    });

    describe(@"mp_deselectRowAtIndexPath:animated:", ^{
        it(@"should call deselectRowAtIndexPath on the original tableview with adjusted indexpaths", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(10, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(tableView);
            [tableView mp_deselectRowAtIndexPath:_IP(8, 0) animated:YES];
            tableView should have_received(@selector(deselectRowAtIndexPath:animated:)).with(_IP(10, 0)).and_with(YES);
        });

        it(@"should call deselectRowAtIndexPath: with the given index path when there is no ad placer", ^{
            [placerlessTableView mp_deselectRowAtIndexPath:_IP(8, 0) animated:YES];
            placerlessTableView should have_received(@selector(deselectRowAtIndexPath:animated:)).with(_IP(8, 0)).and_with(YES);
        });
    });

    describe(@"mp_scrollToRowAtIndexPath:atScrollPosition:animated:", ^{
        it(@"should call scrollToRowAtIndexPath on the original tableview with adjusted indexpaths", ^{
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(_IP(10, 0));

            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(tableView);
            [tableView mp_scrollToRowAtIndexPath:_IP(8, 0) atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            tableView should have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with(_IP(10, 0)).and_with(UITableViewScrollPositionMiddle).and_with(YES);
        });

        it(@"should call scrollToRowAtIndexPath with the given index path when there is no ad placer", ^{
            [placerlessTableView mp_selectRowAtIndexPath:_IP(8, 0) animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            placerlessTableView should have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with(_IP(8, 0)).and_with(UITableViewScrollPositionMiddle).and_with(YES);
        });

        it(@"should call mp_scrollToRowAtIndexPath with the given index path when the row is NSNotFound", ^{
            // TODO: we need this right now because the implementation isn't there yet.
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)22);

            spy_on(tableView);
            [tableView mp_scrollToRowAtIndexPath:_IP(NSNotFound, 0) atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            tableView should have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with(_IP(NSNotFound, 0)).and_with(UITableViewScrollPositionMiddle).and_with(YES);
        });
    });

    describe(@"mp_insertSections:withRowAnimation:", ^{
        __block NSIndexSet *toInsert;

        beforeEach(^{
            toInsert = [NSIndexSet indexSetWithIndex:4];
        });

        it(@"should forward the message to the underlying StreamAdPlacer and then to the TableView", ^{
            spy_on(tableView);
            [tableView mp_insertSections:toInsert withRowAnimation:UITableViewRowAnimationAutomatic];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(insertSections:)).with(toInsert);
            tableView should have_received(@selector(insertSections:withRowAnimation:)).with(toInsert).and_with(UITableViewRowAnimationAutomatic);
        });

        it(@"should forward the message to the TableView when there is no AdPlacer", ^{
            [placerlessTableView mp_insertSections:toInsert withRowAnimation:UITableViewRowAnimationAutomatic];
            placerlessTableView should have_received(@selector(insertSections:withRowAnimation:)).with(toInsert).and_with(UITableViewRowAnimationAutomatic);
        });
    });

    describe(@"mp_deleteSections:withRowAnimation:", ^{
        __block NSIndexSet *toDelete;

        beforeEach(^{
            toDelete = [NSIndexSet indexSetWithIndex:4];
        });

        it(@"should forward the message to the underlying StreamAdPlacer and then to the TableView", ^{
            spy_on(tableView);
            [tableView mp_deleteSections:toDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(deleteSections:)).with(toDelete);
            tableView should have_received(@selector(deleteSections:withRowAnimation:)).with(toDelete).and_with(UITableViewRowAnimationAutomatic);
        });

        it(@"should forward the message to the TableView when there is no AdPlacer", ^{
            [placerlessTableView mp_deleteSections:toDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            placerlessTableView should have_received(@selector(deleteSections:withRowAnimation:)).with(toDelete).and_with(UITableViewRowAnimationAutomatic);
        });
    });

    describe(@"mp_moveSection:toSection:", ^{
        __block int from;
        __block int to;

        beforeEach(^{
            from = 0;
            to = 5;
        });

        it(@"should forward the message to the underlying StreamAdPlacer and then to the TableView", ^{
            spy_on(tableView);
            [tableView mp_moveSection:from toSection:to];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(moveSection:toSection:)).with(from).and_with(to);
            tableView should have_received(@selector(moveSection:toSection:)).with(from).and_with(to);
        });

        it(@"should forward the message to the TableView when there is no AdPlacer", ^{
            [placerlessTableView mp_moveSection:from toSection:to];
            placerlessTableView should have_received(@selector(moveSection:toSection:)).with(from).and_with(to);
        });
    });


    describe(@"mp_deleteRowsAtIndexPaths:withRowAnimation:", ^{
        __block NSArray *toDelete;

        beforeEach(^{
            toDelete = @[_IP(0, 0), _IP(1, 0)];
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *originalIndexPath) {
                return _IP(originalIndexPath.row + 1, originalIndexPath.section);
            });
        });

        it(@"should forward the message to the underlying stream ad placer", ^{
            [tableView mp_deleteRowsAtIndexPaths:toDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(deleteItemsAtIndexPaths:)).with(toDelete);
        });

        xit(@"should delete rows from the table view using adjusted index paths", ^{
            spy_on(tableView);
            [tableView mp_deleteRowsAtIndexPaths:toDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            // TODO: come back and fix this once we implement a real StreamAdPlacer
            tableView should have_received(@selector(deleteRowsAtIndexPaths:withRowAnimation:)).with(@[_IP(1, 0), _IP(2, 0)]).and_with(UITableViewRowAnimationAutomatic);
        });

        it(@"should delete rows from the table view without adjusting the index paths when there is no ad placer", ^{
            [placerlessTableView mp_deleteRowsAtIndexPaths:toDelete withRowAnimation:UITableViewRowAnimationAutomatic];
            placerlessTableView should have_received(@selector(deleteRowsAtIndexPaths:withRowAnimation:)).with(toDelete).and_with(UITableViewRowAnimationAutomatic);
        });
    });

    describe(@"mp_insertRowsAtIndexPaths:withRowAnimation:", ^{
        __block NSArray *toInsert;

        beforeEach(^{
            toInsert = @[_IP(0, 0), _IP(1, 0)];
        });

        it(@"should forward the message to the underlying stream ad placer", ^{
            [tableView mp_insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationAutomatic];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(insertItemsAtIndexPaths:)).with(toInsert);
        });

        it(@"should insert rows from the table view using adjusted index paths", ^{
            spy_on(tableView);
            [tableView mp_insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationAutomatic];

            // Test to see if the index paths have been incremented by one item. For simplicity, the
            // fake stream ad placer increments index paths by one item as long as it has received
            // any -insertItemsAtIndexPaths: calls.
            tableView should have_received(@selector(insertRowsAtIndexPaths:withRowAnimation:)).with(@[_IP(1, 0), _IP(2, 0)]).and_with(UITableViewRowAnimationAutomatic);
        });

        it(@"should insert rows from the table view without adjusting the index paths when there is no ad placer", ^{
            [placerlessTableView mp_insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationAutomatic];
            placerlessTableView should have_received(@selector(insertRowsAtIndexPaths:withRowAnimation:)).with(toInsert).and_with(UITableViewRowAnimationAutomatic);
        });
    });


    describe(@"mp_moveRowAtIndexPath:toIndexPath:", ^{
        __block NSIndexPath *from;
        __block NSIndexPath *to;

        beforeEach(^{
            from = _IP(0,0);
            to = _IP(5,0);
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *originalIndexPath) {
                return _IP(originalIndexPath.row + 1, originalIndexPath.section);
            });
        });

        it(@"should forward the message to the underlying stream ad placer", ^{
            [tableView mp_moveRowAtIndexPath:from toIndexPath:to];
            fakeProvider.fakeStreamAdPlacer should have_received(@selector(moveItemAtIndexPath:toIndexPath:)).with(from).and_with(to);
        });

        it(@"should move rows in the table view using adjusted index paths", ^{
            spy_on(tableView);
            [tableView mp_moveRowAtIndexPath:from toIndexPath:to];
            tableView should have_received(@selector(moveRowAtIndexPath:toIndexPath:)).with(_IP(1, 0)).and_with(_IP(6, 0));
        });

        it(@"should move rows in the table view without adjusting the index paths when there is no ad placer", ^{
            [placerlessTableView mp_moveRowAtIndexPath:from toIndexPath:to];
            placerlessTableView should have_received(@selector(moveRowAtIndexPath:toIndexPath:)).with(from).and_with(to);
        });
    });

    describe(@"mp_reloadRowsAtIndexPaths:withRowAnimation:", ^{
        __block NSArray *toReload;

        beforeEach(^{
            toReload = @[_IP(0, 0), _IP(1, 0)];
            fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *originalIndexPath) {
                return _IP(originalIndexPath.row + 1, originalIndexPath.section);
            });
        });


        xit(@"should reload rows from the table view using adjusted index paths", ^{
            spy_on(tableView);
            // TODO: come back and fix this once we implement a real StreamAdPlacer

            [tableView mp_reloadRowsAtIndexPaths:toReload withRowAnimation:UITableViewRowAnimationAutomatic];
            tableView should have_received(@selector(reloadRowsAtIndexPaths:withRowAnimation:)).with(@[_IP(1, 0), _IP(2, 0)]).and_with(UITableViewRowAnimationAutomatic);
        });

        it(@"should reload rows from the table view without adjusting the index paths when there is no ad placer", ^{
            [placerlessTableView mp_reloadRowsAtIndexPaths:toReload withRowAnimation:UITableViewRowAnimationAutomatic];
            placerlessTableView should have_received(@selector(reloadRowsAtIndexPaths:withRowAnimation:)).with(toReload).and_with(UITableViewRowAnimationAutomatic);
        });
    });

    describe(@"mp_dequeueReusableCellWithIdentifier:forIndexPath:", ^{
        // TODO: not sure what to use for the identifier and what cell to return to verify
        xit(@"should get the proper cell for the row, if the row is not an ad", ^{

        });

        xit(@"should return nil, if the row is an ad", ^{

        });

        xit(@"should call dequeueReusableCellWithIdentifier:forIndexPath: with the given index path when there is no ad placer", ^{

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

    describe(@"mp_indexPathsForSelectedRows:", ^{
        // TODO
        xit(@"should get the original index paths for the rows, if the rows are not ads", ^{

        });

        xit(@"should not include indexpaths for rows that are ads", ^{

        });

        xit(@"should forward to indexPathsForSelectedRows when there is no ad placer", ^{

        });
    });

    describe(@"mp_indexPathsForRowsInRect:", ^{
        // TODO
        xit(@"should get the original index paths for the rows, if the rows are not ads", ^{

        });

        xit(@"should not include indexpaths for rows that are ads", ^{

        });

        xit(@"should forward to indexPathsForRowsInRect: when there is no ad placer", ^{

        });
    });

    describe(@"mp_indexPathsForVisibleRows", ^{
        // TODO
        xit(@"should get the original index paths for the rows, if the rows are not ads", ^{

        });

        xit(@"should not include indexpaths for rows that are ads", ^{

        });

        xit(@"should forward to indexPathsForVisibleRow: when there is no ad placer", ^{

        });
    });

    describe(@"mp_visibleCells", ^{
        context(@"when there is an ad placer", ^{
            beforeEach(^{
                fakeProvider.fakeStreamAdPlacer stub_method(@selector(originalIndexPathsForAdjustedIndexPaths:)).and_return(@[_IP(0, 0)]);
                fakeProvider.fakeStreamAdPlacer stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).with(_IP(0, 0)).and_return(_IP(1, 0));
                spy_on(tableView);
                tableView stub_method(@selector(visibleCells)).and_return(@[[MPTableViewAdPlacerCell new], [UITableViewCell new]]);
                tableView stub_method(@selector(indexPathsForVisibleRows)).and_return(@[_IP(0, 0), _IP(1, 0)]);
                tableView stub_method(@selector(cellForRowAtIndexPath:)).and_return([UITableViewCell new]);
            });

            it(@"should get the cells for the rows, if the rows are not ads", ^{
                NSArray *visibleCells = [tableView mp_visibleCells];
                visibleCells.count should equal(1);
            });

            it(@"should not include cells for rows that are ads", ^{
                NSArray *visibleCells = [tableView mp_visibleCells];
                for (UITableViewCell *cell in visibleCells) {
                    [cell isKindOfClass:[UITableViewCell class]] should be_truthy;
                }
            });
        });

        context(@"when there is no ad placer", ^{
            it(@"should forward to visibleCells when there is no ad placer", ^{
                NSArray *visibleCells = [placerlessTableView mp_visibleCells];
                visibleCells = nil;
                placerlessTableView should have_received(@selector(visibleCells));
            });
        });
    });
});

SPEC_END
