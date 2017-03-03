#import "MPCollectionViewAdPlacer+Specs.h"
#import "MPAdPositioning.h"
#import "MPAdPlacerSharedExamplesSpec.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPClientAdPositioning.h"
#import "MPNativeAdRendering.h"
#import "CedarAsync.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPCollectionViewAdPlacerCell.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FakeMPNativeAdRenderingClassCollectionView : UICollectionViewCell <MPNativeAdRendering>
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeMPNativeAdRenderingClassCollectionView

- (void)layoutAdAssets:(MPNativeAd *)adObject
{

}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FakeMPNativeAdRenderingClassCollectionViewXIB : FakeMPNativeAdRenderingClassCollectionView

+ (void)setNibForAd:(UINib *)nib;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeMPNativeAdRenderingClassCollectionViewXIB

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

@interface FakeCollectionViewProtocolDataSource : NSObject <UICollectionViewDataSource, UITabBarDelegate>
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeCollectionViewProtocolDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FakeCollectionViewProtocolDelegate : NSObject <UICollectionViewDelegate, UITabBarDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FakeCollectionViewProtocolDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeZero;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPCollectionViewAdPlacer () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MPStreamAdPlacerDelegate>
@end

SPEC_BEGIN(MPCollectionViewAdPlacerSpec)

describe(@"MPCollectionViewAdPlacer", ^{
    __block MPCollectionViewAdPlacer *collectionViewAdPlacer;
    __block UICollectionView *collectionView;
    __block id<UICollectionViewDelegate, CedarDouble> collectionViewDelegate;
    __block id<UICollectionViewDataSource, CedarDouble> collectionViewDataSource;
    __block UIViewController *presentingViewController;
    __block UICollectionViewFlowLayout *collectionViewLayout;
    __block MPClientAdPositioning *adPositioning;
    __block MPStreamAdPlacer<CedarDouble> *fakeStreamAdPlacer;
    __block UICollectionView *fakeCollectionView;
    __block MPStaticNativeAdRenderer *renderer;
    __block NSArray *nativeAdRendererConfigurations;

    beforeEach(^{
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];

        settings.renderingViewClass = [FakeMPNativeAdRenderingClassCollectionView class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) {
            return CGSizeMake(70, 113);
        };

        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

        MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
        nativeAdRendererConfigurations = @[config];

        fakeStreamAdPlacer = nice_fake_for([MPStreamAdPlacer class]);

        fakeCollectionView = nice_fake_for([UICollectionView class]);
        adPositioning = [MPClientAdPositioning positioning];
        [adPositioning addFixedIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [adPositioning enableRepeatingPositionsWithInterval:3];
        collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewDelegate = nice_fake_for(@protocol(UICollectionViewDelegate));
        collectionViewDataSource = nice_fake_for(@protocol(UICollectionViewDataSource));
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        collectionView.delegate = collectionViewDelegate;
        collectionView.dataSource = collectionViewDataSource;
        presentingViewController = nice_fake_for([UIViewController class]);
        collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
    });

    describe(@"method forwarding", ^{
        __block NSIndexPath *indexPath;

        beforeEach(^{
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        });

        describe(@"-isKindOfClass:", ^{
            it(@"should be the kind of class the data source is", ^{
                [collectionViewAdPlacer isKindOfClass:[FakeCollectionViewProtocolDataSource class]] should be_falsy;
                collectionView.dataSource = nice_fake_for([FakeCollectionViewProtocolDataSource class]);
                collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [collectionViewAdPlacer isKindOfClass:[FakeCollectionViewProtocolDataSource class]] should be_truthy;
            });

            it(@"should be the kind of class the delegate is", ^{
                [collectionViewAdPlacer isKindOfClass:[FakeCollectionViewProtocolDelegate class]] should be_falsy;
                collectionView.delegate = nice_fake_for([FakeCollectionViewProtocolDelegate class]);
                collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [collectionViewAdPlacer isKindOfClass:[FakeCollectionViewProtocolDelegate class]] should be_truthy;
            });
        });

        describe(@"-conformsToProtocol:", ^{
            it(@"should conform to the UICollectionViewDataSource protocol", ^{
                [collectionViewAdPlacer conformsToProtocol:@protocol(UICollectionViewDataSource)] should be_truthy;
            });

            it(@"should conform to the UICollectionViewDelegate protocol", ^{
                [collectionViewAdPlacer conformsToProtocol:@protocol(UICollectionViewDelegate)] should be_truthy;
            });

            it(@"should conform to the MPStreamAdPlacerDelegate protocol", ^{
                [collectionViewAdPlacer conformsToProtocol:@protocol(MPStreamAdPlacerDelegate)] should be_truthy;
            });

            it(@"should conform to all of the original delegate's protocols", ^{
                // FakeCollectionViewProtocolDataSource implements UITabBarDelegate.
                collectionView.delegate = nice_fake_for([FakeCollectionViewProtocolDelegate class]);
                collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [collectionViewAdPlacer conformsToProtocol:@protocol(UITabBarDelegate)] should be_truthy;
            });

            it(@"should conform to all of the original data source's protocols", ^{
                // FakeCollectionViewProtocolDataSource implements UITabBarDelegate.
                collectionView.dataSource = nice_fake_for([FakeCollectionViewProtocolDataSource class]);
                collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [collectionViewAdPlacer conformsToProtocol:@protocol(UITabBarDelegate)] should be_truthy;
            });
        });

        describe(@"-respondsToSelector:", ^{
            context(@"when the given selector is implemented by the original delegate but not by the collectionViewAdPlacer", ^{
                beforeEach(^{
                    collectionViewDelegate stub_method(@selector(collectionView:transitionLayoutForOldLayout:newLayout:));
                });

                it(@"should respond to the selector", ^{
                    [collectionViewAdPlacer respondsToSelector:@selector(collectionView:transitionLayoutForOldLayout:newLayout:)] should be_truthy;
                });
            });

            context(@"when the given selector is implemented by the original data source but not by the collectionViewAdPlacer", ^{
                beforeEach(^{
                    collectionViewDataSource stub_method(@selector(numberOfSectionsInCollectionView:));
                });

                it(@"should respond to the selector", ^{
                    [collectionViewAdPlacer respondsToSelector:@selector(numberOfSectionsInCollectionView:)] should be_truthy;
                });
            });

            context(@"when the given selector isn't implemented by the original delegate, data source, or collectionViewAdPlacer", ^{
                it(@"should not respond", ^{
                    [collectionViewAdPlacer respondsToSelector:@selector(hargau)] should be_falsy;
                });
            });
        });

        describe(@"-forwardingTargetForSelector:", ^{
            context(@"when forwarding a selector that is implemented by the original delegate but not by the collectionViewAdPlacer", ^{
                beforeEach(^{
                    collectionViewDelegate stub_method(@selector(collectionView:transitionLayoutForOldLayout:newLayout:));
                });

                it(@"should call the selector on the original delegate", ^{
                    [collectionViewAdPlacer collectionView:collectionView transitionLayoutForOldLayout:nil newLayout:nil];
                    collectionViewDelegate should have_received(@selector(collectionView:transitionLayoutForOldLayout:newLayout:));
                });
            });

            context(@"when forwarding a selector that is implemented by the original data source but not by the collectionViewAdPlacer", ^{
                beforeEach(^{
                    collectionViewDataSource stub_method(@selector(numberOfSectionsInCollectionView:));
                });

                it(@"should call the selector on the original data source", ^{
                    [collectionViewAdPlacer numberOfSectionsInCollectionView:collectionView];
                    collectionViewDataSource should have_received(@selector(numberOfSectionsInCollectionView:));
                });
            });
        });
    });

    describe(@"delegate methods", ^{
        __block id<MPCollectionViewAdPlacerDelegate, CedarDouble> delegate;

        it(@"should forward delegate methods to the delegate if the delegate implements them", ^{
            delegate = nice_fake_for(@protocol(MPCollectionViewAdPlacerDelegate));
            collectionViewAdPlacer.delegate = delegate;

            [collectionViewAdPlacer nativeAdWillPresentModalForStreamAdPlacer:nil];
            delegate should have_received(@selector(nativeAdWillPresentModalForCollectionViewAdPlacer:)).with(collectionViewAdPlacer);

            [collectionViewAdPlacer nativeAdDidDismissModalForStreamAdPlacer:nil];
            delegate should have_received(@selector(nativeAdDidDismissModalForCollectionViewAdPlacer:)).with(collectionViewAdPlacer);

            [collectionViewAdPlacer nativeAdWillLeaveApplicationFromStreamAdPlacer:nil];
            delegate should have_received(@selector(nativeAdWillLeaveApplicationFromCollectionViewAdPlacer:)).with(collectionViewAdPlacer);
        });

        it(@"should not forward delegate methods that the delegate doesn't respond to", ^{
            delegate = fake_for(@protocol(MPCollectionViewAdPlacerDelegate));
            collectionViewAdPlacer.delegate = delegate;

            [collectionViewAdPlacer nativeAdWillPresentModalForStreamAdPlacer:nil];
            delegate should_not have_received(@selector(nativeAdWillPresentModalForCollectionViewAdPlacer:)).with(collectionViewAdPlacer);

            [collectionViewAdPlacer nativeAdDidDismissModalForStreamAdPlacer:nil];
            delegate should_not have_received(@selector(nativeAdDidDismissModalForCollectionViewAdPlacer:)).with(collectionViewAdPlacer);

            [collectionViewAdPlacer nativeAdWillLeaveApplicationFromStreamAdPlacer:nil];
            delegate should_not have_received(@selector(nativeAdWillLeaveApplicationFromCollectionViewAdPlacer:)).with(collectionViewAdPlacer);
        });
    });

    describe(@"instantiation", ^{
        it(@"should make the collection view ad placer the stream ad placer's delegate", ^{
            collectionViewAdPlacer.streamAdPlacer.delegate should equal(collectionViewAdPlacer);
        });

        it(@"should make the ad placer the collectionView's delegate/datasource", ^{
            collectionView.delegate should equal(collectionViewAdPlacer);
            collectionView.dataSource should equal(collectionViewAdPlacer);
        });

        it(@"should store the original data source/delegate", ^{
            collectionViewAdPlacer.originalDataSource should equal(collectionViewDataSource);
            collectionViewAdPlacer.originalDelegate should equal(collectionViewDelegate);
        });

        it(@"should forward the controller and ad positioning to the streamAdPlacer", ^{
            MPStreamAdPlacer *adPlacer = collectionViewAdPlacer.streamAdPlacer;
            MPAdPositioning *placerPositioning = adPlacer.adPositioning;

            placerPositioning.repeatingInterval should equal(adPositioning.repeatingInterval);
            placerPositioning.fixedPositions should equal(adPositioning.fixedPositions);
            adPlacer.viewController should equal(presentingViewController);
        });

        it(@"should pass on the renderers to the stream ad placer", ^{
            MPStreamAdPlacer *adPlacer = collectionViewAdPlacer.streamAdPlacer;
            adPlacer.rendererConfigurations should equal(nativeAdRendererConfigurations);
        });

        context(@"when using the server-side positioning convenience method", ^{
            __block MPCollectionViewAdPlacer *placerWithServerPositioning;

            beforeEach(^{
                placerWithServerPositioning = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController rendererConfigurations:nativeAdRendererConfigurations];
            });

            it(@"should ask the server for positions when requesting ads", ^{
                [placerWithServerPositioning loadAdsForAdUnitID:@"ID_WITH_SERVER_POSITIONING"];
                [[[[NSURLConnection lastConnection] request] URL] absoluteString] should contain(@"/m/pos");
            });
        });

        describe(@"registering cells for reuse", ^{
            it(@"should register MPCollectionViewAdPlacerCell as the class with the collection view", ^{
                collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:fakeCollectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                fakeCollectionView should have_received(@selector(registerClass:forCellWithReuseIdentifier:)).with([MPCollectionViewAdPlacerCell class]).and_with(@"MPCollectionViewAdPlacerReuseIdentifier");
                fakeCollectionView should_not have_received(@selector(registerNib:forCellWithReuseIdentifier:)).with(Arguments::anything).and_with(Arguments::anything);
            });
        });
    });

    describe(@"loading ads", ^{
        beforeEach(^{
            fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;
            collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
        });

        it(@"should forward loadAdsForAdUnitID to the stream ad placer", ^{
            fakeStreamAdPlacer should_not have_received(@selector(loadAdsForAdUnitID:));
            [collectionViewAdPlacer loadAdsForAdUnitID:@"booger"];
            fakeStreamAdPlacer should have_received(@selector(loadAdsForAdUnitID:));
        });

        it(@"should forward loadAdsForAdUnitID:targeting to the stream ad placer", ^{
            fakeStreamAdPlacer should_not have_received(@selector(loadAdsForAdUnitID:targeting:));
            [collectionViewAdPlacer loadAdsForAdUnitID:@"booger" targeting:[[MPNativeAdRequestTargeting alloc] init]];
            fakeStreamAdPlacer should have_received(@selector(loadAdsForAdUnitID:targeting:));
        });
    });

    xdescribe(@"should make sure updateVisibleCells is called at some time interval", ^{

    });

    describe(@"-updateVisibleCells", ^{
        __block UICollectionView *collectionView;
        __block MPStreamAdPlacer *streamAdPlacer;

        beforeEach(^{
            streamAdPlacer = [MPStreamAdPlacer placerWithViewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
            spy_on(streamAdPlacer);
            fakeProvider.fakeStreamAdPlacer = streamAdPlacer;
            collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
            spy_on(collectionView);
        });

        context(@"when the collection view has no visible cells", ^{
            beforeEach(^{
                collectionView stub_method(@selector(indexPathsForVisibleItems)).and_return(@[]);
                collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                [collectionViewAdPlacer updateVisibleCells];
            });

            it(@"should not set visible index paths on the stream ad placer", ^{
                streamAdPlacer should_not have_received(@selector(setVisibleIndexPaths:));
            });
        });

        context(@"when the collection view has visible cells", ^{
            __block NSArray *visiblePaths;

            beforeEach(^{
                visiblePaths = @[
                                 [NSIndexPath indexPathForItem:1 inSection:1],
                                 [NSIndexPath indexPathForItem:2 inSection:1],
                                 [NSIndexPath indexPathForItem:3 inSection:1]
                                 ];
                collectionView stub_method(@selector(indexPathsForVisibleItems)).and_return(visiblePaths);
                streamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_do_block(^NSIndexPath * (NSIndexPath *adjustedIndexPath) {
                    if ([streamAdPlacer isAdAtIndexPath:adjustedIndexPath]) {
                        return nil;
                    }
                    return [NSIndexPath indexPathForRow:adjustedIndexPath.row+5 inSection:adjustedIndexPath.section];
                });
                collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
            });

            it(@"should set visible index paths on the stream ad placer without an explicit updateVisibleCells call", ^{
                in_time(streamAdPlacer should have_received(@selector(setVisibleIndexPaths:)).with(visiblePaths));
            });

            it(@"should set visible index paths on the stream ad placer with original index paths", ^{
                NSArray *originalIndexPaths = [NSMutableArray arrayWithObjects:[NSIndexPath indexPathForRow:6 inSection:1],
                                               [NSIndexPath indexPathForRow:7 inSection:1],
                                               [NSIndexPath indexPathForRow:8 inSection:1],
                                               nil];

                [collectionViewAdPlacer updateVisibleCells];
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

                    [collectionViewAdPlacer updateVisibleCells];
                });

                it(@"should exclude ad cells when setting visible index paths on the stream ad placer", ^{
                    NSArray *contentIndexPaths = [NSMutableArray arrayWithObjects:[NSIndexPath indexPathForRow:6 inSection:1],
                                                  [NSIndexPath indexPathForRow:8 inSection:1],
                                                  nil];

                    streamAdPlacer should have_received(@selector(setVisibleIndexPaths:)).with(contentIndexPaths);
                });
            });
        });
    });

    describe(@"MPStreamAdPlacerDelegate", ^{
        beforeEach(^{
            fakeCollectionView stub_method(@selector(performBatchUpdates:completion:)).and_do(^(NSInvocation *inv) {
                void (^executionBlock)() = nil;
                [inv getArgument:&executionBlock atIndex:2];
                executionBlock();
            });
            fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;
            collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:fakeCollectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
        });

        describe(@"-adPlacer:didLoadAdAtIndexPath:", ^{
            __block NSIndexPath *insertedIndexPath;

            beforeEach(^{
                insertedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            });

            context(@"when there's an ad at the given index path", ^{
                beforeEach(^{
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                    [collectionViewAdPlacer adPlacer:fakeStreamAdPlacer didLoadAdAtIndexPath:insertedIndexPath];
                });
                it(@"should insert items into the collection view", ^{
                    fakeCollectionView should have_received(@selector(insertItemsAtIndexPaths:)).with(@[insertedIndexPath]);
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
                [collectionViewAdPlacer adPlacer:nice_fake_for([MPStreamAdPlacer class]) didRemoveAdsAtIndexPaths:ads];
            });

            it(@"should perform operations using performBatchUpdates", ^{
                fakeCollectionView should have_received(@selector(performBatchUpdates:completion:));
            });

            it(@"should remove items from the collection view", ^{
                fakeCollectionView should have_received(@selector(deleteItemsAtIndexPaths:)).with(ads);
            });
        });
    });

    describe(@"delegate / data source methods", ^{
        __block NSIndexPath *indexPath;

        beforeEach(^{
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
            collectionView.delegate = collectionViewDelegate;
            collectionView.dataSource = collectionViewDataSource;
            fakeProvider.fakeStreamAdPlacer = fakeStreamAdPlacer;
            collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:fakeStreamAdPlacer forKey:@"fakeStreamAdPlacer"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:collectionViewAdPlacer forKey:@"uiCollectionAdPlacer"];
        });

        describe(@"data source", ^{
            beforeEach(^{
                indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                [[CDRSpecHelper specHelper].sharedExampleContext setObject:collectionViewDataSource forKey:@"fakeOriginalObject"];
            });

            describe(@"-collectionView:numberOfItemsInSection:", ^{
                __block NSInteger numItemsStubbed;
                __block NSUInteger adjustedItemsStubbed;
                __block NSInteger section;

                beforeEach(^{
                    section = 1;
                    numItemsStubbed = 39;
                    adjustedItemsStubbed = 32;
                    collectionViewDataSource stub_method(@selector(collectionView:numberOfItemsInSection:)).and_return(numItemsStubbed);
                    fakeStreamAdPlacer stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return(adjustedItemsStubbed);
                });

                it(@"should call adjustedNumberOfItems:inSection: on the stream ad placer", ^{
                    [collectionViewAdPlacer collectionView:collectionView numberOfItemsInSection:section];
                    fakeStreamAdPlacer should have_received(@selector(adjustedNumberOfItems:inSection:)).with(numItemsStubbed).and_with(section);
                });

                it(@"should get the final result from adjustedNumberOfItems:inSection:", ^{
                    [collectionViewAdPlacer collectionView:collectionView numberOfItemsInSection:section] should equal(adjustedItemsStubbed);
                });

                it(@"should call setItemCount:forSection on the stream ad placer ", ^{
                    [collectionViewAdPlacer collectionView:collectionView numberOfItemsInSection:section];
                    fakeStreamAdPlacer should have_received(@selector(setItemCount:forSection:)).with(numItemsStubbed).and_with(section);
                });
            });

            describe(@"-collectionView:cellForItemAtIndexPath:", ^{
                context(@"when there is an ad at the index path", ^{
                    __block UICollectionViewCell *cell;
                    __block NSIndexPath *indexPath;
                    __block FakeMPNativeAdRenderingClassCollectionView *fakeNativeAdView;

                    beforeEach(^{
                        fakeNativeAdView = [[FakeMPNativeAdRenderingClassCollectionView alloc] init];
                        fakeCollectionView stub_method(@selector(dequeueReusableCellWithReuseIdentifier:forIndexPath:)).and_return(fakeNativeAdView);
                        indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                        cell = [collectionViewAdPlacer collectionView:fakeCollectionView cellForItemAtIndexPath:indexPath];
                    });

                    it(@"should render the ad and pass the cell's content view as the view to render to", ^{
                        fakeStreamAdPlacer should have_received(@selector(renderAdAtIndexPath:inView:)).with(indexPath).with(cell.contentView);
                    });

                    it(@"should return something equal to what dequeueReusableCellWithReuseIdentifier:forIndexPath: returns", ^{
                        fakeNativeAdView should equal(cell);
                    });

                    it(@"should set clipsToBounds to YES on the returned cell", ^{
                        cell.clipsToBounds should equal(YES);
                    });
                });

                context(@"when there isn't an ad at the index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    });

                    it(@"should get the original index path and pass that to the original data source's cellForItemAtIndexPath", ^{
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:30 inSection:1];
                        NSIndexPath *originalPath = [NSIndexPath indexPathForRow:1 inSection:1];

                        fakeStreamAdPlacer stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(originalPath);

                        [collectionViewAdPlacer collectionView:collectionView cellForItemAtIndexPath:indexPath];
                        fakeStreamAdPlacer should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(indexPath);
                        collectionViewDataSource should have_received(@selector(collectionView:cellForItemAtIndexPath:)).with(collectionView).and_with(originalPath);
                    });

                    it(@"should return whatever the original data source returns", ^{
                        UIView *bogusView = [[UIView alloc] init];

                        collectionViewDataSource stub_method(@selector(collectionView:cellForItemAtIndexPath:)).and_return(bogusView);
                        [collectionViewAdPlacer collectionView:collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should equal(bogusView);
                    });
                });
            });
        });

        describe(@"delegate", ^{
            __block UICollectionViewCell *cell;
            beforeEach(^{
                cell = [[UICollectionViewCell alloc] init];
                [[CDRSpecHelper specHelper].sharedExampleContext setObject:collectionViewDelegate forKey:@"fakeOriginalObject"];
            });

            describe(@"-collectionView:canPerformAction:forItemAtIndexPath:withSender:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:canPerformAction:forItemAtIndexPath:withSender:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"backgroundColor" forKey:@"argumentSelector"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:collectionView forKey:@"view"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethodThatContainsASelector);

                context(@"when there isn't an ad at the given index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    });
                    context(@"when the delegate doesn't respond to the selector", ^{
                        beforeEach(^{
                            collectionViewDelegate reject_method(@selector(collectionView:canPerformAction:forItemAtIndexPath:withSender:));
                        });

                        it(@"should return NO", ^{
                            [collectionViewAdPlacer collectionView:collectionView canPerformAction:@selector(backgroundColor) forItemAtIndexPath:indexPath withSender:nil] should be_falsy;
                        });

                    });
                });
            });

            describe(@"-collectionView:didSelectItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:didSelectItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);

                context(@"when there is an ad at the index path", ^{
                    beforeEach(^{
                        fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                        collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:fakeCollectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];
                        [collectionViewAdPlacer collectionView:fakeCollectionView didSelectItemAtIndexPath:indexPath];
                    });

                    it(@"should should deselect the item immediately", ^{
                        fakeCollectionView should have_received(@selector(deselectItemAtIndexPath:animated:)).with(indexPath).and_with(NO);
                    });
                });
            });

            describe(@"-collectionView:didEndDisplayingCell:forItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:didEndDisplayingCell:forItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, cell, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aThreeArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-collectionView:didSelectItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:didSelectItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-collectionView:didUnhighlightItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:didUnhighlightItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, indexPath] forKey:@"arguments"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-collectionView:performAction:forItemAtIndexPath:withSender:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:performAction:forItemAtIndexPath:withSender:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"backgroundColor" forKey:@"argumentSelector"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethodThatContainsASelector);
            });

            describe(@"-collectionView:shouldDeselectItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:shouldDeselectItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@YES forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-collectionView:shouldHighlightItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:shouldHighlightItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@YES forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-collectionView:shouldSelectItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:shouldSelectItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@(collectionView.allowsSelection) forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-collectionView:shouldShowMenuForItemAtIndexPath:", ^{
                beforeEach(^{
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@"collectionView:shouldShowMenuForItemAtIndexPath:" forKey:@"methodName"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@[collectionView, indexPath] forKey:@"arguments"];
                    [[CDRSpecHelper specHelper].sharedExampleContext setObject:@NO forKey:@"defaultReturnValue"];
                });

                itShouldBehaveLike(aDelegateOrDataSourceMethod);
                itShouldBehaveLike(aDelegateOrDataSourceMethodThatReturnsABOOL);
                itShouldBehaveLike(aTwoArgumentDelegateOrDataSourceMethod);
            });

            describe(@"-collectionView:layout:sizeForItemAtIndexPath:", ^{
                __block CGSize stubbedSize;

                beforeEach(^{
                    stubbedSize = CGSizeMake(10.0f, 11.0f);
                });

                it(@"should call through to the original data source when there is no ad at index path and return whatever the original returns", ^{
                    collectionViewDelegate = nice_fake_for([FakeCollectionViewProtocolDelegate class]);
                    collectionView.delegate = collectionViewDelegate;
                    collectionViewAdPlacer = [MPCollectionViewAdPlacer placerWithCollectionView:collectionView viewController:presentingViewController adPositioning:adPositioning rendererConfigurations:nativeAdRendererConfigurations];

                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);
                    collectionViewDelegate stub_method(@selector(collectionView:layout:sizeForItemAtIndexPath:)).and_return(stubbedSize);

                    [collectionViewAdPlacer collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath] should equal(stubbedSize);
                    collectionViewDelegate should have_received(@selector(collectionView:layout:sizeForItemAtIndexPath:));
                });

                it(@"should not call through to the original data source when there is an ad at index path and return whatever the ad placer dictates to be the size", ^{
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(YES);
                    fakeStreamAdPlacer stub_method(@selector(sizeForAdAtIndexPath:withMaximumWidth:)).and_return(stubbedSize);

                    [collectionViewAdPlacer collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath] should equal(stubbedSize);
                    collectionViewDelegate should_not have_received(@selector(collectionView:layout:sizeForItemAtIndexPath:));
                });

                it(@"should return the collection view's itemSize when there is no ad at index path and the delegate doesn't respond to the sizeForItemAtIndexPath method", ^{
                    CGSize itemSize = CGSizeMake(56.0f, 12.0f);
                    collectionViewLayout.itemSize = itemSize;
                    fakeStreamAdPlacer stub_method(@selector(isAdAtIndexPath:)).and_return(NO);

                    [collectionViewAdPlacer collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath] should equal(itemSize);
                });
            });
        });
    });
});

SPEC_END

#pragma clang diagnostic pop
