#import "MPTableViewAdPlacer.h"
#import "MPAdPositioning.h"
#import "MPTableViewAdPlacer+Specs.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPAdPlacerSharedExamplesSpec.h"
#import "MPClientAdPositioning.h"
#import "MPNativeAdRendering.h"
#import "CedarAsync.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPTableViewAdPlacerCell.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FakeMPNativeAdRenderingClassTableView : UITableViewCell <MPNativeAdRendering>

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeMPNativeAdRenderingClassTableView

- (void)layoutAdAssets:(MPNativeAd *)adObject
{

}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FakeMPNativeAdRenderingClassTableViewXIB : FakeMPNativeAdRenderingClassTableView

+ (void)setNibForAd:(UINib *)nib;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeMPNativeAdRenderingClassTableViewXIB

static UINib *sNib = nil;

+ (UINib *)nibForAd
{
    return sNib;
}

+ (void)setNibForAd:(UINib *)nib
{
    sNib = nib;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FakeTableViewProtocolDataSource : NSObject <UITableViewDataSource, UITabBarDelegate>
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeTableViewProtocolDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FakeTableViewProtocolDelegate : NSObject <UITableViewDelegate, UITabBarDelegate>
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeTableViewProtocolDelegate
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPTableViewAdPlacer () <UITableViewDataSource, UITableViewDelegate, MPStreamAdPlacerDelegate>
@end

SPEC_BEGIN(MPTableViewAdPlacerSpec)

describe(@"MPTableViewAdPlacer", ^{
    __block MPTableViewAdPlacer *tableViewAdPlacer;
    __block UITableView *tableView;
    __block id<UITableViewDelegate, CedarDouble> tableViewDelegate;
    __block id<UITableViewDataSource, CedarDouble> tableViewDataSource;
    __block UIViewController *presentingViewController;
    __block MPClientAdPositioning *adPositioning;
    __block UITableView<CedarDouble> *fakeTableView;
    __block MPStreamAdPlacer<CedarDouble> *fakeStreamAdPlacer;
    __block MPNativeAdRendererConfiguration *rendererConfiguration;
    __block NSArray *nativeAdRendererConfigurations;

    beforeEach(^{
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
        settings.renderingViewClass = [FakeMPNativeAdRenderingClassTableView class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) {
            return CGSizeMake(70, 113);
        };

        rendererConfiguration = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];

        nativeAdRendererConfigurations = @[rendererConfiguration];

        fakeStreamAdPlacer = nice_fake_for([MPStreamAdPlacer class]);

        adPositioning = [MPClientAdPositioning positioning];
        [adPositioning addFixedIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [adPositioning enableRepeatingPositionsWithInterval:3];
        tableViewDelegate = nice_fake_for(@protocol(UITableViewDelegate));
        tableViewDataSource = nice_fake_for(@protocol(UITableViewDataSource));
        tableView = [[UITableView alloc] init];
        tableView.delegate = tableViewDelegate;
        tableView.dataSource = tableViewDataSource;
        presentingViewController = nice_fake_for([UIViewController class]);
        tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
        fakeTableView = nice_fake_for([UITableView class]);
    });

    describe(@"method forwarding", ^{
        __block NSIndexPath *indexPath;

        beforeEach(^{
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        });

        describe(@"-isKindOfClass:", ^{
            it(@"should be the kind of class the data source is", ^{
                [tableViewAdPlacer isKindOfClass:[FakeTableViewProtocolDataSource class]] should be_falsy;
                tableView.dataSource = nice_fake_for([FakeTableViewProtocolDataSource class]);
                tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [tableViewAdPlacer isKindOfClass:[FakeTableViewProtocolDataSource class]] should be_truthy;
            });

            it(@"should be the kind of class the delegate is", ^{
                [tableViewAdPlacer isKindOfClass:[FakeTableViewProtocolDelegate class]] should be_falsy;
                tableView.delegate = nice_fake_for([FakeTableViewProtocolDelegate class]);
                tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [tableViewAdPlacer isKindOfClass:[FakeTableViewProtocolDelegate class]] should be_truthy;
            });
        });

        describe(@"delegate methods", ^{
            __block id<MPTableViewAdPlacerDelegate, CedarDouble> delegate;

            it(@"should forward delegate methods to the delegate if the delegate implements them", ^{
                delegate = nice_fake_for(@protocol(MPTableViewAdPlacerDelegate));
                tableViewAdPlacer.delegate = delegate;

                [tableViewAdPlacer nativeAdWillPresentModalForStreamAdPlacer:nil];
                delegate should have_received(@selector(nativeAdWillPresentModalForTableViewAdPlacer:)).with(tableViewAdPlacer);

                [tableViewAdPlacer nativeAdDidDismissModalForStreamAdPlacer:nil];
                delegate should have_received(@selector(nativeAdDidDismissModalForTableViewAdPlacer:)).with(tableViewAdPlacer);

                [tableViewAdPlacer nativeAdWillLeaveApplicationFromStreamAdPlacer:nil];
                delegate should have_received(@selector(nativeAdWillLeaveApplicationFromTableViewAdPlacer:)).with(tableViewAdPlacer);
            });

            it(@"should not forward delegate methods that the delegate doesn't respond to", ^{
                delegate = fake_for(@protocol(MPTableViewAdPlacerDelegate));
                tableViewAdPlacer.delegate = delegate;

                [tableViewAdPlacer nativeAdWillPresentModalForStreamAdPlacer:nil];
                delegate should_not have_received(@selector(nativeAdWillPresentModalForTableViewAdPlacer:)).with(tableViewAdPlacer);

                [tableViewAdPlacer nativeAdDidDismissModalForStreamAdPlacer:nil];
                delegate should_not have_received(@selector(nativeAdDidDismissModalForTableViewAdPlacer:)).with(tableViewAdPlacer);

                [tableViewAdPlacer nativeAdWillLeaveApplicationFromStreamAdPlacer:nil];
                delegate should_not have_received(@selector(nativeAdWillLeaveApplicationFromTableViewAdPlacer:)).with(tableViewAdPlacer);
            });
        });
        describe(@"-conformsToProtocol:", ^{
            it(@"should conform to the UITableViewDataSource protocol", ^{
                [tableViewAdPlacer conformsToProtocol:@protocol(UITableViewDataSource)] should be_truthy;
            });

            it(@"should conform to the UITableViewDelegate protocol", ^{
                [tableViewAdPlacer conformsToProtocol:@protocol(UITableViewDelegate)] should be_truthy;
            });

            it(@"should conform to the MPStreamAdPlacerDelegate protocol", ^{
                [tableViewAdPlacer conformsToProtocol:@protocol(MPStreamAdPlacerDelegate)] should be_truthy;
            });

            it(@"should conform to all of the original delegate's protocols", ^{
                // FakeTableViewProtocolDataSource implements UITabBarDelegate.
                tableView.delegate = nice_fake_for([FakeTableViewProtocolDelegate class]);
                tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [tableViewAdPlacer conformsToProtocol:@protocol(UITabBarDelegate)] should be_truthy;
            });

            it(@"should conform to all of the original data source's protocols", ^{
                // FakeTableViewProtocolDataSource implements UITabBarDelegate.
                tableView.dataSource = nice_fake_for([FakeTableViewProtocolDataSource class]);
                tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [tableViewAdPlacer conformsToProtocol:@protocol(UITabBarDelegate)] should be_truthy;
            });
        });

        describe(@"-respondsToSelector:", ^{
            context(@"when the given selector is implemented by the original delegate but not by the tableViewAdPlacer", ^{
                beforeEach(^{
                    tableViewDelegate stub_method(@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:));
                });

                it(@"should respond to the selector", ^{
                    [tableViewAdPlacer respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)] should be_truthy;
                });
            });

            context(@"when the given selector is implemented by the original data source but not by the tableViewAdPlacer", ^{
                beforeEach(^{
                    tableViewDataSource stub_method(@selector(sectionIndexTitlesForTableView:));
                });

                it(@"should respond to the selector", ^{
                    [tableViewAdPlacer respondsToSelector:@selector(sectionIndexTitlesForTableView:)] should be_truthy;
                });
            });

            context(@"when the given selector isn't implemented by the original delegate, data source, or tableViewAdPlacer", ^{
                it(@"should not respond", ^{
                    [tableViewAdPlacer respondsToSelector:@selector(hargau)] should be_falsy;
                });
            });
        });

        describe(@"-forwardingTargetForSelector:", ^{
            context(@"when forwarding a selector that is implemented by the original delegate but not by the tableViewAdPlacer", ^{
                beforeEach(^{
                    tableViewDelegate stub_method(@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:));
                });

                it(@"should call the selector on the original delegate", ^{
                    [tableViewAdPlacer tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:indexPath toProposedIndexPath:indexPath];
                    tableViewDelegate should have_received(@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:));
                });
            });

            context(@"when forwarding a selector that is implemented by the original data source but not by the tableViewAdPlacer", ^{
                beforeEach(^{
                    tableViewDataSource stub_method(@selector(sectionIndexTitlesForTableView:));
                });

                it(@"should call the selector on the original data source", ^{
                    [tableViewAdPlacer sectionIndexTitlesForTableView:tableView];
                    tableViewDataSource should have_received(@selector(sectionIndexTitlesForTableView:));
                });
            });
        });
    });

    describe(@"instantiation", ^{
        it(@"should make the ad placer the tableview's delegate/datasource", ^{
            tableView.delegate should equal(tableViewAdPlacer);
            tableView.dataSource should equal(tableViewAdPlacer);
        });

        it(@"should store the original data source/delegate", ^{
            tableViewAdPlacer.originalDataSource should equal(tableViewDataSource);
            tableViewAdPlacer.originalDelegate should equal(tableViewDelegate);
        });

        it(@"should forward the controller and ad positioning to the streamAdPlacer", ^{
            MPStreamAdPlacer *adPlacer = tableViewAdPlacer.streamAdPlacer;
            MPAdPositioning *placerPositioning = adPlacer.adPositioning;

            placerPositioning.repeatingInterval should equal(adPositioning.repeatingInterval);
            placerPositioning.fixedPositions should equal(adPositioning.fixedPositions);
            adPlacer.viewController should equal(presentingViewController);
        });

        it(@"should pass the renderers to the stream ad placer", ^{
            MPStreamAdPlacer *adPlacer = tableViewAdPlacer.streamAdPlacer;
            adPlacer.rendererConfigurations should equal(nativeAdRendererConfigurations);
        });

        context(@"when using the server-side positioning convenience method", ^{
            __block MPTableViewAdPlacer *placerWithServerPositioning;

            beforeEach(^{
                placerWithServerPositioning = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController rendererConfigurations:nativeAdRendererConfigurations];
            });

            it(@"should ask the server for positions when requesting ads", ^{
                [placerWithServerPositioning loadAdsForAdUnitID:@"ID_WITH_SERVER_POSITIONING"];
                [[[[NSURLConnection lastConnection] request] URL] absoluteString] should contain(@"/m/pos");
            });
        });

        describe(@"registering cells for reuse", ^{
            it(@"should register the MPTableViewAdPlacerCell class with the table view", ^{
                tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:fakeTableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                fakeTableView should have_received(@selector(registerClass:forCellReuseIdentifier:)).with([MPTableViewAdPlacerCell class]).and_with(@"MPTableViewAdPlacerReuseIdentifier");

                // Make sure we don't also call registerNib:forCellReuseIdentifier:.
                fakeTableView should_not have_received(@selector(registerNib:forCellReuseIdentifier:)).with(Arguments::anything).and_with(Arguments::anything);
            });
        });
    });

    describe(@"loading ads", ^{
        beforeEach(^{
            fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;
            tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
        });

        it(@"should forward loadAdsForAdUnitID to the stream ad placer", ^{
            fakeStreamAdPlacer should_not have_received(@selector(loadAdsForAdUnitID:));
            [tableViewAdPlacer loadAdsForAdUnitID:@"booger"];
            fakeStreamAdPlacer should have_received(@selector(loadAdsForAdUnitID:targeting:));
        });

        it(@"should forward loadAdsForAdUnitID:targeting to the stream ad placer", ^{
            fakeStreamAdPlacer should_not have_received(@selector(loadAdsForAdUnitID:targeting:));
            [tableViewAdPlacer loadAdsForAdUnitID:@"booger" targeting:[[MPNativeAdRequestTargeting alloc] init]];
            fakeStreamAdPlacer should have_received(@selector(loadAdsForAdUnitID:targeting:));
        });
    });

    describe(@"MPStreamAdPlacerDelegate", ^{
        beforeEach(^{
            fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;
            tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:fakeTableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
        });

        describe(@"-adPlacer:didLoadAdAtIndexPath:", ^{
            __block NSIndexPath *insertedIndexPath;

            beforeEach(^{
                insertedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            });

            context(@"when there's an ad at the given index path", ^{
                beforeEach(^{
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                    [tableViewAdPlacer adPlacer:fakeStreamAdPlacer didLoadAdAtIndexPath:insertedIndexPath];
                });

                it(@"should insert items into the table view", ^{
                    fakeTableView should have_received(@selector(insertRowsAtIndexPaths:withRowAnimation:)).with(@[insertedIndexPath]).and_with(UITableViewRowAnimationMiddle);
                });

                xit(@"should call the other animation calls", ^{

                });
            });
        });

        describe(@"-adPlacer:didRemoveAdsAtIndexPaths:", ^{
            __block NSArray *ads;
            beforeEach(^{
                ads = @[
                        [NSIndexPath indexPathForItem:1 inSection:1],
                        [NSIndexPath indexPathForItem:2 inSection:2]
                        ];
                [tableViewAdPlacer adPlacer:nice_fake_for([MPStreamAdPlacer class]) didRemoveAdsAtIndexPaths:ads];
            });

            it(@"should remove items from the table view", ^{
                fakeTableView should have_received(@selector(deleteRowsAtIndexPaths:withRowAnimation:)).with(ads).and_with(UITableViewRowAnimationNone);
            });

            xit(@"should call the other animation calls", ^{

            });
        });
    });

    describe(@"-updateVisibleCells", ^{
        __block UITableView *tableView;
        __block MPStreamAdPlacer *streamAdPlacer;

        beforeEach(^{
            streamAdPlacer = [MPStreamAdPlacer placerWithViewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
            spy_on(streamAdPlacer);
            fakeProvider.fakeStreamAdPlacer = streamAdPlacer;
            tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            spy_on(tableView);
        });

        context(@"when the table view has no visible cells", ^{
            beforeEach(^{
                tableView stub_method(@selector(indexPathsForVisibleRows)).and_return(@[]);
                tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
            });

            it(@"should not set visible index paths on the stream ad placer", ^{
                in_time(streamAdPlacer should_not have_received(@selector(setVisibleIndexPaths:)));
            });
        });

        context(@"when the table view has visible cells", ^{
            __block NSArray *visiblePaths;
            beforeEach(^{
                visiblePaths = @[
                                 [NSIndexPath indexPathForItem:1 inSection:1],
                                 [NSIndexPath indexPathForItem:2 inSection:1],
                                 [NSIndexPath indexPathForItem:3 inSection:1]
                                 ];
                tableView stub_method(@selector(indexPathsForVisibleRows)).and_return(visiblePaths);
                streamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *adjustedIndexPath) {
                    if ([streamAdPlacer isAdAtIndexPath:adjustedIndexPath]) {
                        return nil;
                    }
                    return [NSIndexPath indexPathForRow:adjustedIndexPath.row+5 inSection:adjustedIndexPath.section];
                });
                tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
            });

            it(@"should set visible index paths on the stream ad placer", ^{
                in_time(streamAdPlacer should have_received(@selector(setVisibleIndexPaths:)).with(visiblePaths));
            });

            it(@"should set visible index paths on the stream ad placer with original index paths", ^{
                NSArray *originalIndexPaths = [NSMutableArray arrayWithObjects:[NSIndexPath indexPathForRow:6 inSection:1],
                                               [NSIndexPath indexPathForRow:7 inSection:1],
                                               [NSIndexPath indexPathForRow:8 inSection:1],
                                               nil];
                [tableViewAdPlacer updateVisibleCells];
                streamAdPlacer should have_received(@selector(setVisibleIndexPaths:)).with(originalIndexPaths);
            });

            // Not such a great test since we're stubbing out originalIndexPathForAdjustedIndexPath.
            context(@"when the visible index paths contain an ad", ^{
                beforeEach(^{
                    streamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_do_block(^BOOL(NSIndexPath *indexPath) {
                        if ([indexPath isEqual:[NSIndexPath indexPathForRow:2 inSection:1]]) {
                            return YES;
                        }

                        return NO;
                    });

                    [tableViewAdPlacer updateVisibleCells];
                });

                it(@"should set visible index paths on the stream ad placer with no ad cells", ^{
                    NSArray *contentIndexPaths = [NSMutableArray arrayWithObjects:[NSIndexPath indexPathForRow:6 inSection:1],
                                                  [NSIndexPath indexPathForRow:8 inSection:1],
                                                  nil];

                    streamAdPlacer should have_received(@selector(setVisibleIndexPaths:)).with(contentIndexPaths);
                });
            });

        });
    });

    describe(@"delegate / data source methods", ^{
        __block NSIndexPath *indexPath;

        beforeEach(^{
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
            tableView = [[UITableView alloc] init];
            tableView.delegate = tableViewDelegate;
            tableView.dataSource = tableViewDataSource;

            fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;
            tableViewAdPlacer = [MPTableViewAdPlacer placerWithTableView:tableView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:fakeStreamAdPlacer forKey:@"fakeStreamAdPlacer"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:tableViewAdPlacer forKey:@"uiCollectionAdPlacer"];
        });

        describe(@"data source", ^{
            beforeEach(^{
                indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                [[CDRSpecHelper specHelper].sharedExampleContext setObject:tableViewDataSource forKey:@"fakeOriginalObject"];
            });

            describe(@"-tableView:numberOfRowsInSection:", ^{
                __block NSInteger numRowsStubbed;
                __block NSUInteger adjustedItemsStubbed;
                __block NSInteger section;

                beforeEach(^{
                    section = 1;
                    numRowsStubbed = 39;
                    adjustedItemsStubbed = 32;
                    tableViewDataSource stub_method(@selector(tableView:numberOfRowsInSection:)).and_return(numRowsStubbed);
                    fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return(adjustedItemsStubbed);
                });

                it(@"should call adjustedNumberOfItems:inSection: on the stream ad placer", ^{
                    [tableViewAdPlacer tableView:tableView numberOfRowsInSection:section];
                    fakeStreamAdPlacer should have_received(@selector(adjustedNumberOfItems:inSection:)).with(numRowsStubbed).and_with(section);
                });

                it(@"should get the final result from adjustedNumberOfItems:inSection:", ^{
                    [tableViewAdPlacer tableView:tableView numberOfRowsInSection:section] should equal(adjustedItemsStubbed);
                });
            });

            describe(@"-tableView:cellForRowAtIndexPath:", ^{
                context(@"when there is an ad at the index path", ^{
                    __block UITableViewCell *cell;
                    __block FakeMPNativeAdRenderingClassTableView *fakeView;

                    beforeEach(^{
                        fakeView = [[FakeMPNativeAdRenderingClassTableView alloc] init];
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                        fakeTableView stub_method(@selector(dequeueReusableCellWithIdentifier:forIndexPath:)).and_return(fakeView);
                        cell = [tableViewAdPlacer tableView:fakeTableView cellForRowAtIndexPath:indexPath];
                    });

                    it(@"should always render the ad and pass the cell's content view as the view to render to", ^{
                        fakeStreamAdPlacer should have_received(@selector(renderAdAtIndexPath:inView:)).with(indexPath).with(cell.contentView);
                    });
                    context(@"if a nib or class was previously registered for the reuse identifier", ^{
                        it(@"should return something equal to what -dequeueReusableCellWithIdentifier:forIndexPath: returns", ^{
                            cell should equal(fakeView);
                        });
                    });
                });

                context(@"when there isn't an ad at the index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    });

                    it(@"should get the original index path and pass that to the original data source's cellForRowAtIndexPath", ^{
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:30 inSection:1];
                        NSIndexPath *originalPath = [NSIndexPath indexPathForRow:1 inSection:1];

                        fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(originalPath);

                        [tableViewAdPlacer tableView:tableView cellForRowAtIndexPath:indexPath];
                        fakeStreamAdPlacer should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(indexPath);
                        tableViewDataSource should have_received(@selector(tableView:cellForRowAtIndexPath:)).with(tableView).and_with(originalPath);
                    });

                    it(@"should return whatever the original data source returns", ^{
                        UIView *bogusView = [[UIView alloc] init];

                        tableViewDataSource stub_method(@selector(tableView:cellForRowAtIndexPath:)).and_return(bogusView);
                        [tableViewAdPlacer tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should equal(bogusView);
                    });
                });
            });

            describe(@"-tableView:canEditRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:canEditRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@NO forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);

                context(@"when there is not an ad at the index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    });

                    context(@"when the data source doesn't respond to the tableView:canEditRowAtIndexPath:", ^{
                        beforeEach(^{
                            tableViewDataSource reject_method(@selector(tableView:canEditRowAtIndexPath:));
                        });

                        it(@"should return YES", ^{
                            [tableViewAdPlacer tableView:fakeTableView canEditRowAtIndexPath:indexPath] should be_truthy;
                        });
                    });

                    context(@"when the data source does respond to tableView:canEditRowAtIndexPath:", ^{
                        beforeEach(^{
                            tableViewDataSource stub_method(@selector(tableView:canEditRowAtIndexPath:)).and_return(NO);
                        });

                        it(@"should return whatever the data source returns", ^{
                            [tableViewAdPlacer tableView:fakeTableView canEditRowAtIndexPath:indexPath] should be_falsy;
                        });
                    });
                });

                describe(@"when there is an ad at the index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                    });

                    context(@"when the data source doesn't respond to the tableView:canEditRowAtIndexPath:", ^{
                        beforeEach(^{
                            tableViewDataSource reject_method(@selector(tableView:canEditRowAtIndexPath:));
                        });

                        it(@"should return NO", ^{
                            [tableViewAdPlacer tableView:fakeTableView canEditRowAtIndexPath:indexPath] should be_falsy;
                        });
                    });

                    context(@"when the data source does respond to tableView:canEditRowAtIndexPath:", ^{
                        beforeEach(^{
                            tableViewDataSource stub_method(@selector(tableView:canEditRowAtIndexPath:)).and_return(YES);
                        });

                        it(@"should return NO", ^{
                            [tableViewAdPlacer tableView:fakeTableView canEditRowAtIndexPath:indexPath] should be_falsy;
                        });
                    });
                });
            });

            describe(@"-tableView:canMoveRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:canMoveRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@NO forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
            });

            describe(@"-tableView:commitEditingStyle:forRowAtIndexPath:", ^{
                __block NSInteger editingStyle;

                beforeEach(^{
                    editingStyle = UITableViewCellEditingStyleInsert;

                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:commitEditingStyle:forRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, @(editingStyle), indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aThreeArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:moveRowAtIndexPath:toIndexPath:", ^{
                __block NSIndexPath *origin;
                __block NSIndexPath *destination;

                beforeEach(^{
                    origin = [NSIndexPath indexPathForRow:3 inSection:1];
                    destination = [NSIndexPath indexPathForRow:4 inSection:1];

                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:moveRowAtIndexPath:toIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, origin, destination] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aThreeArgumentDelegateOrDataSourceMethod);

                it(@"should retrieve the original index paths to pass to data source method when relying on the original data source", ^{
                    SEL selector = @selector(tableView:moveRowAtIndexPath:toIndexPath:);
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    tableViewDataSource stub_method(selector);

                    __block NSIndexPath *testOrigin = [NSIndexPath indexPathForRow:2 inSection:1];
                    __block NSIndexPath *testDestination = [NSIndexPath indexPathForRow:23 inSection:1];

                    fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_do(^(NSInvocation *invocation) {
                        static NSInteger calls = 0;
                        if (calls == 0) {
                            [invocation setReturnValue:&testOrigin];
                        } else {
                            [invocation setReturnValue:&testDestination];
                        }
                        ++calls;
                    });

                    [tableViewAdPlacer tableView:tableView moveRowAtIndexPath:origin toIndexPath:destination];

                    // Assumes we get the originalIndexPath on the origin first.
                    fakeStreamAdPlacer should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(origin);
                    fakeStreamAdPlacer should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(destination);
                    tableViewDataSource should have_received(selector).with(tableView).with(testOrigin).and_with(testDestination);
                });

                it(@"should be able to move an ad if there isn't one at source but there is one at destination", ^{
                    SEL selector = @selector(tableView:moveRowAtIndexPath:toIndexPath:);
                    tableViewDataSource stub_method(selector);
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_do(^(NSInvocation *invocation) {
                        __unsafe_unretained NSIndexPath *indexPath;
                        [invocation getArgument:&indexPath atIndex:2];

                        BOOL answer = NO;
                        if (indexPath == destination) {
                            answer = YES;
                        }

                        [invocation setReturnValue:&answer];
                    });

                    [tableViewAdPlacer tableView:tableView moveRowAtIndexPath:origin toIndexPath:destination];
                    tableViewDataSource should have_received(selector);
                });
            });
        });

        describe(@"delegate", ^{
            __block UITableViewCell *cell;

            beforeEach(^{
                cell = [[UITableViewCell alloc] init];
                [[CDRSpecHelper specHelper].sharedExampleContext setObject:tableViewDelegate forKey:@"fakeOriginalObject"];
            });

            describe(@"-tableView:heightForRowAtIndexPath:", ^{
                it(@"should call through to the original data source when there is no ad at index path and return whatever the original returns", ^{
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    tableViewDelegate stub_method(@selector(tableView:heightForRowAtIndexPath:)).and_return((CGFloat)77.3);

                    [tableViewAdPlacer tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should equal((CGFloat)77.3);
                    tableViewDelegate should have_received(@selector(tableView:heightForRowAtIndexPath:));
                });

                it(@"should not call through to the original data source when there is an ad at index path and return whatever the ad placer dictates to be the size", ^{
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                    fakeStreamAdPlacer stub_method(@selector(sizeForAdAtIndexPath:withMaximumWidth:)).and_return(CGSizeMake((CGFloat)55.4, (CGFloat)89.3));

                    [tableViewAdPlacer tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should equal((CGFloat)89.3);
                    tableViewDelegate should_not have_received(@selector(tableView:heightForRowAtIndexPath:));
                });

                it(@"should return the table view's height when there is no ad at index path and the delegate doesn't respond to the heightForRowAtIndexPath method", ^{
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    tableViewDelegate reject_method(@selector(tableView:heightForRowAtIndexPath:));

                    UITableView *fakeTableView = nice_fake_for([UITableView class]);
                    fakeTableView stub_method(@selector(rowHeight)).and_return((CGFloat)777.0);
                    [tableViewAdPlacer tableView:fakeTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should equal((CGFloat)777.0);
                });
            });

            describe(@"-tableView:willDisplayCell:forRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:willDisplayCell:forRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, cell, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aThreeArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:didEndDisplayingCell:forRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:didEndDisplayingCell:forRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, cell, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aThreeArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:accessoryButtonTappedForRowWithIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:accessoryButtonTappedForRowWithIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:shouldHighlightRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:shouldHighlightRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@YES forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
            });

            describe(@"-tableView:didHighlightRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:didHighlightRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:didUnhighlightRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:didUnhighlightRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:willSelectRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:willSelectRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aSelectOrDeselectRowAtIndexPathMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);

            });

            describe(@"-tableView:willDeselectRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:willDeselectRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aSelectOrDeselectRowAtIndexPathMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);

            });

            describe(@"-tableView:didSelectRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:didSelectRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:didDeselectRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:didDeselectRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:editingStyleForRowAtIndexPath:", ^{
                __block NSInteger editingStyle;
                beforeEach(^{
                    editingStyle = UITableViewCellEditingStyleNone;
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:editingStyleForRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@(editingStyle) forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);

                context(@"when there is not an ad at the index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    });

                    context(@"when the delegate doesn't respond to tableView:editingStyleForRowAtIndexPath:", ^{
                        beforeEach(^{
                            tableViewDelegate reject_method(@selector(tableView:editingStyleForRowAtIndexPath:));
                        });
                        context(@"when the cell is editable", ^{
                            beforeEach(^{
                                tableViewDataSource stub_method(@selector(tableView:canEditRowAtIndexPath:)).and_return(YES);
                            });

                            it(@"should return style delete", ^{
                                [tableViewAdPlacer tableView:fakeTableView editingStyleForRowAtIndexPath:indexPath] should equal(UITableViewCellEditingStyleDelete);
                            });
                        });

                        context(@"when the cell is not editable", ^{
                            beforeEach(^{
                                tableViewDataSource stub_method(@selector(tableView:canEditRowAtIndexPath:)).and_return(NO);
                            });

                            it(@"should return style none", ^{
                                [tableViewAdPlacer tableView:fakeTableView editingStyleForRowAtIndexPath:indexPath] should equal(UITableViewCellEditingStyleNone);
                            });
                        });
                    });

                    context(@"when the delegate does respond to tableView:editingStyleForRowAtIndexPath:", ^{
                        beforeEach(^{
                            tableViewDelegate stub_method(@selector(tableView:editingStyleForRowAtIndexPath:)).and_return(UITableViewCellEditingStyleInsert);
                        });

                        it(@"should return what the original data source returns", ^{
                            [tableViewAdPlacer tableView:fakeTableView editingStyleForRowAtIndexPath:indexPath] should equal(UITableViewCellEditingStyleInsert);
                        });
                    });
                });

                describe(@"when there is an ad at the index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                    });

                    context(@"when the delegate doesn't respond to tableView:editingStyleForRowAtIndexPath:", ^{
                        beforeEach(^{
                            tableViewDelegate reject_method(@selector(tableView:editingStyleForRowAtIndexPath:));
                        });

                        it(@"should return style none", ^{
                            [tableViewAdPlacer tableView:fakeTableView editingStyleForRowAtIndexPath:indexPath] should equal(UITableViewCellEditingStyleNone);
                        });
                    });

                    context(@"when the delegate does respond to the method", ^{
                        beforeEach(^{
                            tableViewDelegate stub_method(@selector(tableView:editingStyleForRowAtIndexPath:)).and_return(UITableViewCellEditingStyleInsert);
                        });

                        it(@"should return style none", ^{
                            [tableViewAdPlacer tableView:fakeTableView editingStyleForRowAtIndexPath:indexPath] should equal(UITableViewCellEditingStyleNone);
                        });
                    });
                });
            });

            describe(@"-tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"Delete" forKey:@"defaultReturnValue"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"Burp" forKey:@"defaultTestValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsAnObject);
            });

            describe(@"-tableView:shouldIndentWhileEditingRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:shouldIndentWhileEditingRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@YES forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
            });

            describe(@"-tableView:willBeginEditingRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:willBeginEditingRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:didEndEditingRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:didEndEditingRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-tableView:indentationLevelForRowAtIndexPath:", ^{
                __block NSInteger indentationLevel;
                beforeEach(^{
                    indentationLevel = UITableViewCellEditingStyleNone;
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:indentationLevelForRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@(indentationLevel) forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsAnNSInteger);
            });

            describe(@"-tableView:shouldShowMenuForRowAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:shouldShowMenuForRowAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[tableView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@NO forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
            });

            describe(@"-tableView:canPerformAction:forRowAtIndexPath:withSender:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:canPerformAction:forRowAtIndexPath:withSender:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"backgroundColor" forKey:@"argumentSelector"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:tableView forKey:@"view"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethodThatContainsASelector);

                context(@"when there isn't an ad at the given index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    });
                    context(@"when the delegate doesn't respond to the selector", ^{
                        beforeEach(^{
                            tableViewDelegate reject_method(@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:));
                        });

                        it(@"should return NO", ^{
                            [tableViewAdPlacer tableView:tableView canPerformAction:@selector(backgroundColor) forRowAtIndexPath:indexPath withSender:nil] should be_falsy;
                        });

                    });
                });
            });

            describe(@"-tableView:performAction:forRowAtIndexPath:withSender:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"tableView:performAction:forRowAtIndexPath:withSender:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"backgroundColor" forKey:@"argumentSelector"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethodThatContainsASelector);
            });
        });
    });
});

SPEC_END
