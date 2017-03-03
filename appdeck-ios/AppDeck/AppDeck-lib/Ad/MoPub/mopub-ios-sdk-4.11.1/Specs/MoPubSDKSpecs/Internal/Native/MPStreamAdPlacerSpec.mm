#import "MPStreamAdPlacer+Specs.h"
#import "MPAdPositioning.h"
#import "MPNativeAdSource.h"
#import "MPNativeAd+Internal.h"
#import "MPStreamAdPlacementData+Specs.h"
#import "MPNativeAdRendering.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdData.h"
#import "MPClientAdPositioning.h"
#import "MPServerAdPositioning.h"
#import "MPNativePositionSource.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPMoPubNativeAdAdapter.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPNativeAdRendererConstants.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPNativeView.h"
#import "MPNativeAdDelegate.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

CGSize gStubbedRenderingSize = CGSizeMake(70, 113);

@interface MPStreamAdPlacer () <MPNativeAdSourceDelegate, MPNativeAdDelegate>
@end

@interface FakeMPNativeAdRenderingClassView : UIView <MPNativeAdRendering>

@property (nonatomic, readonly) NSUInteger retrieveAdViewCallCount;

- (void)resetRetrieveViewCallCount;

@end

@implementation FakeMPNativeAdRenderingClassView

- (void)layoutAdAssets:(MPNativeAd *)adObject
{
    ++_retrieveAdViewCallCount;
}

- (void)resetRetrieveViewCallCount
{
    _retrieveAdViewCallCount = 0;
}

+ (CGSize)sizeWithMaximumWidth:(CGFloat)maxWidth
{
    return gStubbedRenderingSize;
}

@end

@interface FakeMPDynamicHeightNativeAdRenderingClassView : UIView<MPNativeAdRendering>
@end

@implementation FakeMPDynamicHeightNativeAdRenderingClassView

// just 2x the size to demonstrate that it is dynamic
- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, size.width * 2);
}

@end


@interface FakeMPNativeAdRenderingClass : NSObject <MPNativeAdRendering>

@end

@implementation FakeMPNativeAdRenderingClass

- (void)layoutAdAssets:(MPNativeAd *)adObject
{

}

@end

@interface FakeMPNativeAdRenderingClassViewNoSize : UIView <MPNativeAdRendering>

@end

@implementation FakeMPNativeAdRenderingClassViewNoSize

- (void)layoutAdAssets:(MPNativeAd *)adObject
{
}

@end

SPEC_BEGIN(MPStreamAdPlacerSpec)

describe(@"MPStreamAdPlacer", ^{
    __block MPStreamAdPlacer *placer;
    __block id<MPStreamAdPlacerDelegate, CedarDouble> placerDelegate;
    __block UIViewController *viewController;
    __block MPClientAdPositioning *positioning;
    __block MPStreamAdPlacementData *placementData;
    __block MPNativeAdSource *adSource;
    __block MPNativePositionSource *positioningSource;
    __block MPNativeAdRendererConfiguration *rendererConfiguration;
    __block MPStaticNativeAdRendererSettings *rendererSettings;
    __block NSArray *nativeAdRendererConfigurations;

    beforeEach(^{
        rendererSettings = [[MPStaticNativeAdRendererSettings alloc] init];
        rendererSettings.renderingViewClass = [FakeMPNativeAdRenderingClassView class];
        rendererSettings.viewSizeHandler = ^(CGFloat maxWidth) {
            return gStubbedRenderingSize;
        };

        rendererConfiguration = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:rendererSettings];

        nativeAdRendererConfigurations = @[rendererConfiguration];

        positioning = [MPClientAdPositioning positioning];
        [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [positioning enableRepeatingPositionsWithInterval:3];
        viewController = nice_fake_for([UIViewController class]);
        placerDelegate = nice_fake_for(@protocol(MPStreamAdPlacerDelegate));
        placementData = nice_fake_for([MPStreamAdPlacementData class]);
        adSource = nice_fake_for([MPNativeAdSource class]);
        positioningSource = nice_fake_for([MPNativePositionSource class]);
        fakeProvider.fakeNativeAdSource = adSource;
        fakeProvider.fakeNativePositioningSource = positioningSource;
        fakeProvider.fakeStreamAdPlacementData = placementData;
        placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:positioning rendererConfigurations:nativeAdRendererConfigurations];
        placer.delegate = placerDelegate;
    });

    describe(@"instantiation failure cases", ^{
        it(@"should throw an exception if no view controller is passed", ^{
            ^{
                placer = [MPStreamAdPlacer placerWithViewController:nil adPositioning:positioning rendererConfigurations:nativeAdRendererConfigurations];
            } should raise_exception;
        });

        it(@"should throw an exception if no ad positioning object is passed", ^{
            ^{
                placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:nil rendererConfigurations:nativeAdRendererConfigurations];
            } should raise_exception;
        });

        xit(@"should throw an exception if the rendering configuration array is nil", ^{
            ^{
                placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:nil rendererConfigurations:nativeAdRendererConfigurations];
            } should raise_exception;
        });

        xit(@"should throw an exception if any of the rendering configurations aren't of type MPNativeAdRendererConfiguration", ^{
            ^{
                placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:nil rendererConfigurations:nativeAdRendererConfigurations];
            } should raise_exception;
        });
    });

    it(@"should instantiate properly", ^{
        MPAdPositioning *placerPositioning = placer.adPositioning;
        placerPositioning.repeatingInterval should equal(positioning.repeatingInterval);
        placerPositioning.fixedPositions should equal(positioning.fixedPositions);
        placer.viewController should equal(viewController);
        placer.rendererConfigurations should equal(nativeAdRendererConfigurations);
        fakeProvider.fakeNativeAdSource should have_received(@selector(setDelegate:)).with(placer);
    });

    describe(@"delegate methods", ^{
        __block id<MPStreamAdPlacerDelegate, CedarDouble> delegate;

        it(@"should forward delegate methods to the delegate if the delegate implements them", ^{
            MPNativeAd *ad = [MPNativeAd new];
            delegate = nice_fake_for(@protocol(MPStreamAdPlacerDelegate));
            placer.delegate = delegate;

            [placer willPresentModalForNativeAd:ad];
            delegate should have_received(@selector(nativeAdWillPresentModalForStreamAdPlacer:)).with(placer);

            [placer didDismissModalForNativeAd:ad];
            delegate should have_received(@selector(nativeAdDidDismissModalForStreamAdPlacer:)).with(placer);

            [placer willLeaveApplicationFromNativeAd:ad];
            delegate should have_received(@selector(nativeAdWillLeaveApplicationFromStreamAdPlacer:)).with(placer);
        });

        it(@"should not forward delegate methods that the delegate doesn't respond to", ^{
            MPNativeAd *ad = [MPNativeAd new];
            delegate = fake_for(@protocol(MPStreamAdPlacerDelegate));
            placer.delegate = delegate;

            [placer willPresentModalForNativeAd:ad];
            delegate should_not have_received(@selector(nativeAdWillPresentModalForStreamAdPlacer:)).with(placer);

            [placer didDismissModalForNativeAd:ad];
            delegate should_not have_received(@selector(nativeAdDidDismissModalForStreamAdPlacer:)).with(placer);

            [placer willLeaveApplicationFromNativeAd:ad];
            delegate should_not have_received(@selector(nativeAdWillLeaveApplicationFromStreamAdPlacer:)).with(placer);
        });
    });

    describe(@"-furthestValidIndexPathAfterIndexPath:withinDistance:", ^{
        beforeEach(^{
            [placer setItemCount:3 forSection:0];
            [placer setItemCount:0 forSection:1];
            [placer setItemCount:14 forSection:2];
        });

        describe(@"testing basic functionality ignoring adjusted number of items", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_do(^(NSInvocation *invocation) {
                    NSUInteger count;
                    [invocation getArgument:&count atIndex:2];
                    [invocation setReturnValue:&count];
                });
            });

            it(@"should retrieve the index path at furthest range when possible", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:2];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:2] should equal([NSIndexPath indexPathForItem:4 inSection:2]);
            });

            it(@"should retrieve the furthest index path in the collection when the distance expands outside of the collection", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:60] should equal([NSIndexPath indexPathForItem:13 inSection:2]);
            });

            it(@"should be able to retrieve an index path with 0 item index", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:2] should equal([NSIndexPath indexPathForItem:0 inSection:2]);
            });

            it(@"should not count empty sections as items", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:3] should equal([NSIndexPath indexPathForItem:1 inSection:2]);
            });

            it(@"should retrieve the indexPath passed in when distance is zero", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:12 inSection:2];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:0] should equal(indexPath);
            });

            it(@"should retrieve the next indexPath when distance is 1", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:1] should equal([NSIndexPath indexPathForItem:2 inSection:0]);
            });

            context(@"when the last sections have 0 items", ^{
                beforeEach(^{
                    [placer setItemCount:0 forSection:3];
                    [placer setItemCount:0 forSection:4];
                });

                it(@"should use the last index path from the last non-0 sized section", ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:10 inSection:2];
                    [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:10] should equal([NSIndexPath indexPathForItem:13 inSection:2]);
                });
            });
        });

        context(@"when there are ads in the stream", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_do(^(NSInvocation *invocation) {
                    // Just add 2 to whatever count is passed in.
                    NSUInteger count;
                    [invocation getArgument:&count atIndex:2];
                    count += 2;
                    [invocation setReturnValue:&count];
                });
            });

            it(@"should retrieve the last item in a section", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:2] should equal([NSIndexPath indexPathForItem:2 inSection:0]);
            });

            it(@"should traverse sections and retrieve the 0th index item in the next section", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                [placer furthestValidIndexPathAfterIndexPath:indexPath withinDistance:3] should equal([NSIndexPath indexPathForItem:0 inSection:2]);
            });
        });
    });

    describe(@"-earliestValidIndexPathBeforeIndexPath:withinDistance:", ^{
        beforeEach(^{
            [placer setItemCount:3 forSection:0];
            [placer setItemCount:0 forSection:1];
            [placer setItemCount:14 forSection:2];
        });

        describe(@"testing basic functionality ignoring adjusted number of items", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_do(^(NSInvocation *invocation) {
                    NSUInteger count;
                    [invocation getArgument:&count atIndex:2];
                    [invocation setReturnValue:&count];
                });
            });

            it(@"should retrieve the index path at earliest range when possible", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:12 inSection:2];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:4] should equal([NSIndexPath indexPathForItem:8 inSection:2]);
            });

            it(@"should retrieve the earliest index path in the collection when the distance expands outside of the collection", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:13 inSection:2];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:60] should equal([NSIndexPath indexPathForItem:0 inSection:0]);
            });

            it(@"should not count empty sections as items", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:2];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:2] should equal([NSIndexPath indexPathForItem:2 inSection:0]);
            });

            it(@"should correctly retrieve an index path with the last item index in a section", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:2];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:3] should equal([NSIndexPath indexPathForItem:2 inSection:0]);
            });

            it(@"should retrieve the indexPath passed in when distance is zero", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:12 inSection:2];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:0] should equal(indexPath);
            });

            it(@"should retrieve the previous indexPath when distance is 1", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:2];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:1] should equal([NSIndexPath indexPathForItem:0 inSection:2]);
            });

            context(@"when the first sections have 0 items", ^{
                beforeEach(^{
                    [placer setItemCount:0 forSection:0];
                    [placer setItemCount:0 forSection:1];
                });

                it(@"should use the last index path from the last non-0 sized section", ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:10 inSection:2];
                    [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:20] should equal([NSIndexPath indexPathForItem:0 inSection:2]);
                });
            });
        });

        context(@"when there are ads in the stream", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_do(^(NSInvocation *invocation) {
                    // Just add 2 to whatever count is passed in.
                    NSUInteger count;
                    [invocation getArgument:&count atIndex:2];
                    count += 2;
                    [invocation setReturnValue:&count];
                });
            });

            it(@"should traverse sections and retrieve the last index path in the previous section", ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:1];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:2] should equal([NSIndexPath indexPathForItem:2 inSection:0]);
            });

            it(@"should retrieve the correct index path, before an index path that extends beyond the original item count", ^{
                // This is valid even though we set item count to 0 since the stubbed method adds 2 to the count of every section.
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
                [placer earliestValidIndexPathBeforeIndexPath:indexPath withinDistance:1] should equal([NSIndexPath indexPathForItem:3 inSection:0]);
            });
        });
    });

    describe(@"-setVisibleIndexPaths:", ^{
        __block NSArray *indexPaths;

        context(@"when we have unsorted index paths", ^{
            // Declare in ascending order.
            __block NSIndexPath *path1;
            __block NSIndexPath *path2;
            __block NSIndexPath *path3;
            __block NSIndexPath *path4;
            beforeEach(^{
                [placer setItemCount:1 forSection:0];
                [placer setItemCount:6 forSection:1];
                [placer setItemCount:0 forSection:2];
                [placer setItemCount:2 forSection:3];
                path1 = [NSIndexPath indexPathForRow:1 inSection:1];
                path2 = [NSIndexPath indexPathForRow:3 inSection:1];
                path3 = [NSIndexPath indexPathForRow:5 inSection:1];
                path4 = [NSIndexPath indexPathForRow:1 inSection:3];
                indexPaths = @[
                               path4,
                               path3,
                               path3,
                               path1,
                               path2
                               ];
                placer.visibleIndexPaths = indexPaths;
            });

            it(@"should sort the index paths", ^{
                NSArray *vps = placer.visibleIndexPaths;
                vps[0] should equal(path1);
                vps[1] should equal(path2);
                vps[2] should equal(path3);
                vps[3] should equal(path3);
                vps[4] should equal(path4);
            });

            it(@"should have the same amount of paths as indexPaths", ^{
                placer.visibleIndexPaths.count should equal(indexPaths.count);
            });

            it(@"should set the top considered index path to the first visible index path", ^{
                placer.topConsideredIndexPath should equal(placer.visibleIndexPaths.firstObject);
            });

            it(@"should set the bottom considered path using furthestValidIndexPathAfterIndexPath:withinDistance:", ^{
                NSIndexPath *calculatedBottom = [placer furthestValidIndexPathAfterIndexPath:placer.visibleIndexPaths.lastObject withinDistance:placer.visibleIndexPaths.count];

                calculatedBottom should equal(placer.bottomConsideredIndexPath);
            });
        });

        context(@"when we set visibleIndexPaths to nil", ^{
            beforeEach(^{
                placer.visibleIndexPaths = nil;
            });

            it(@"should set visibleIndexPaths to nil", ^{
                placer.visibleIndexPaths should be_nil;
            });

            it(@"should set topConsideredIndexPath to nil", ^{
                placer.topConsideredIndexPath should be_nil;
            });

            it(@"should set bottomConsideredIndexPath to nil", ^{
                placer.bottomConsideredIndexPath should be_nil;
            });
        });

        context(@"when we set visibleIndexPaths to an empty array", ^{
            beforeEach(^{
                placer.visibleIndexPaths = @[];
            });

            it(@"should set visibleIndexPaths to nil", ^{
                placer.visibleIndexPaths should be_nil;
            });

            it(@"should set topConsideredIndexPath to nil", ^{
                placer.topConsideredIndexPath should be_nil;
            });

            it(@"should set bottomConsideredIndexPath to nil", ^{
                placer.bottomConsideredIndexPath should be_nil;
            });
        });
    });

    describe(@"-setItemCount:forSection:", ^{
        it(@"should set the section count correctly", ^{
            placer.sectionCounts[@(3)] should_not equal(@(5));
            [placer setItemCount:5 forSection:3];
            placer.sectionCounts[@(3)] should equal(@(5));
        });
    });

    describe(@"-renderAdAtIndexPath:", ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        __block FakeMPNativeAdRenderingClassView *renderView;
        __block MPMoPubNativeAdAdapter *adapter;

        beforeEach(^{
            renderView = [[FakeMPNativeAdRenderingClassView alloc] init];
        });

        context(@"when there is no ad data at the index path", ^{
            beforeEach(^{
                placementData stub_method(@selector(adDataAtAdjustedIndexPath:)).and_return(nil);
                [placer renderAdAtIndexPath:indexPath inView:renderView];
            });

            it(@"should not add any subviews to the render view", ^{
                renderView.subviews.count should equal(0);
            });
        });

        context(@"when there is ad data at the index path", ^{
            __block MPNativeAd<CedarDouble> *fakeNativeAd;
            __block MPNativeView *renderedView;
            __block MPNativeAdData *adData;

            beforeEach(^{
                renderedView = [MPNativeView new];
                adapter = [[MPMoPubNativeAdAdapter alloc] init];
                adData = [[MPNativeAdData alloc] init];
                fakeNativeAd = nice_fake_for([MPNativeAd class]);
                fakeNativeAd stub_method(@selector(retrieveAdViewWithError:)).and_return(renderedView);

                adData.ad = fakeNativeAd;
                placementData stub_method(@selector(adDataAtAdjustedIndexPath:)).and_return(adData);
            });

            context(@"when no viewSizeHandler is provided", ^{
                beforeEach(^{
                    rendererSettings.viewSizeHandler = nil;
                    MPStaticNativeAdRenderer *renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:rendererSettings];
                    fakeNativeAd stub_method(@selector(renderer)).and_return(renderer);

                    renderView = [[FakeMPNativeAdRenderingClassView alloc] initWithFrame:CGRectMake(0, 0, 243, 100)];
                    [placer renderAdAtIndexPath:indexPath inView:renderView];
                });

                it(@"should default to a size of (maxWidth, 44)", ^{
                    fakeNativeAd should have_received(@selector(updateAdViewSize:)).with(CGSizeMake(renderView.bounds.size.width, 44.0f));
                });
            });

            context(@"when a viewSizeHandler is provided", ^{
                beforeEach(^{
                    MPStaticNativeAdRenderer *renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:rendererSettings];
                    fakeNativeAd stub_method(@selector(renderer)).and_return(renderer);

                    renderView = [[FakeMPNativeAdRenderingClassView alloc] initWithFrame:CGRectMake(0, 0, 243, 100)];
                    [placer renderAdAtIndexPath:indexPath inView:renderView];
                });

                it(@"should attach the rendered ad view to the render view", ^{
                    renderView.subviews.count should equal(1);
                    renderView.subviews[0] should equal(renderedView);
                });

                it(@"should retrieve the view through the native ad", ^{
                    fakeNativeAd should have_received(@selector(retrieveAdViewWithError:));
                });

                it(@"should tell the native ad to update the size of the ad view", ^{
                    fakeNativeAd should have_received(@selector(updateAdViewSize:)).with(gStubbedRenderingSize);
                });

                context(@"when the cell already has an ad and is reused", ^{
                    __block MPNativeView *renderedView2;
                    __block UIView *otherView;

                    beforeEach(^{
                        otherView = [UIView new];
                        renderedView2 = [MPNativeView new];
                        adapter = [[MPMoPubNativeAdAdapter alloc] init];
                        MPNativeAdData *adData = [[MPNativeAdData alloc] init];
                        fakeNativeAd = nice_fake_for([MPNativeAd class]);
                        fakeNativeAd stub_method(@selector(retrieveAdViewWithError:)).and_return(renderedView2);
                        adData.ad = fakeNativeAd;
                        placementData = nice_fake_for([MPStreamAdPlacementData class]);
                        placementData stub_method(@selector(adDataAtAdjustedIndexPath:)).and_return(adData);
                        fakeProvider.fakeStreamAdPlacementData = placementData;
                        [renderView addSubview:otherView];

                        placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:positioning rendererConfigurations:nativeAdRendererConfigurations];
                        [placer renderAdAtIndexPath:indexPath inView:renderView];
                    });

                    it(@"should remove the old ad view", ^{
                        renderView.subviews should_not contain(renderedView);
                        renderView.subviews should contain(renderedView2);
                    });

                    it(@"should not remove non-ad views", ^{
                        renderView.subviews should contain(otherView);
                    });
                });
            });
        });
    });

    describe(@"-sizeForAdAtIndexPath:withMaximumWidth:", ^{
        __block MPNativeAd *ad;

        context(@"when the rendering class implements the view size handler", ^{
            beforeEach(^{
                MPStaticNativeAdRenderer *renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:rendererSettings];
                ad = [[MPNativeAd alloc] initWithAdAdapter:nil];
                ad.renderer = renderer;
                MPNativeAdData *adData = [[MPNativeAdData alloc] init];

                adData.ad = ad;

                placementData stub_method(@selector(adDataAtAdjustedIndexPath:)).and_return(adData);
            });

            it(@"should return the size from the rendering class", ^{
                [placer sizeForAdAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] withMaximumWidth:3] should equal(gStubbedRenderingSize);
            });

            it(@"should tell the native ad to update the size of the ad view", ^{
                spy_on(ad);
                [placer sizeForAdAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] withMaximumWidth:3];

                ad should have_received(@selector(updateAdViewSize:));
            });
        });

        context(@"when the rendering class implements view size handler with dynamic height", ^{
            __block UIView<MPNativeAdRendering> *customAdView;

            beforeEach(^{
                customAdView = [[FakeMPDynamicHeightNativeAdRenderingClassView alloc] init];
                MPStaticNativeAdRendererSettings *rendererSettings = [[MPStaticNativeAdRendererSettings alloc] init];
                rendererSettings.renderingViewClass = [FakeMPDynamicHeightNativeAdRenderingClassView class];
                rendererSettings.viewSizeHandler = ^(CGFloat maxWidth) {
                    return CGSizeMake(maxWidth, MPNativeViewDynamicDimension);
                };
                MPStaticNativeAdRenderer *renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:rendererSettings];
                rendererConfiguration = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:rendererSettings];
                nativeAdRendererConfigurations = @[rendererConfiguration];
                UIView *adContainerView = [[UIView alloc] init];

                MPNativeAdData *adData = [[MPNativeAdData alloc] init];
                MPNativeAd *ad = nice_fake_for([MPNativeAd class]);
                ad stub_method(@selector(retrieveAdViewForSizeCalculationWithError:)).and_return(customAdView);
                ad stub_method(@selector(renderer)).and_return(renderer);
                adData.ad = ad;
                placementData stub_method(@selector(adDataAtAdjustedIndexPath:)).and_return(adData);

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:positioning rendererConfigurations:nativeAdRendererConfigurations];
                [placer renderAdAtIndexPath:indexPath inView:adContainerView];
            });

            it(@"should invoke sizeThatFits: on the rendering class to get height", ^{
                spy_on(customAdView);

                [placer sizeForAdAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] withMaximumWidth:400];
                customAdView should have_received("sizeThatFits:").with(CGSizeMake(400, CGFLOAT_MAX));
            });

            it(@"should return a dynamic height as determined by the ad view", ^{
                CGSize adSize = [placer sizeForAdAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] withMaximumWidth:400];
                adSize should equal(CGSizeMake(400, 800));
            });
        });

        context(@"when the rendering class doesn't implement the view size handler", ^{
            beforeEach(^{
                MPStaticNativeAdRenderer *renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:nil];
                MPNativeAd *ad = [[MPNativeAd alloc] initWithAdAdapter:nil];
                ad.renderer = renderer;
                MPNativeAdData *adData = [[MPNativeAdData alloc] init];

                adData.ad = ad;
            });

            it(@"should return size with the given maxWidth and default height of 44", ^{
                [placer sizeForAdAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] withMaximumWidth:320] should equal(CGSizeMake(320, 44));
            });
        });
    });

    xit(@"-loadAdsForAdUnitID:", ^{
        // Just need to verify it calls to the version that takes targeting as a parameter.
    });

    describe(@"-loadAdsForAdUnitID:targeting:", ^{
        __block MPNativeAdRequestTargeting *targeting;
        __block NSString *adUnitID;

        beforeEach(^{
            targeting = nice_fake_for([MPNativeAdRequestTargeting class]);
            adUnitID = @"wut";
            fakeProvider.fakeNativeAdSource = nice_fake_for([MPNativeAdSource class]);
            placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:positioning rendererConfigurations:nativeAdRendererConfigurations];
            placer.delegate = placerDelegate;
        });

        context(@"when trying to load with a nil ad unit ID", ^{
            it(@"should remove ads if ads exist", ^{
                [placer loadAdsForAdUnitID:adUnitID targeting:targeting];
                __block NSArray *section0Ads = @[
                                                 [NSIndexPath indexPathForItem:2 inSection:0],
                                                 [NSIndexPath indexPathForItem:8 inSection:0]
                                                 ];
                __block NSArray *section1Ads = @[
                                                 [NSIndexPath indexPathForItem:0 inSection:1],
                                                 [NSIndexPath indexPathForItem:3 inSection:1]
                                                 ];

                NSArray *expectedIndexPaths = [[NSArray arrayWithArray:section0Ads] arrayByAddingObjectsFromArray:section1Ads];

                [placer setItemCount:10 forSection:0];
                [placer setItemCount:2 forSection:2];

                placementData stub_method(@selector(adjustedIndexPathsWithAdsInSection:)).and_do(^(NSInvocation *inv) {
                    NSUInteger section;
                    [inv getArgument:&section atIndex:2];

                    if (section == 0) {
                        [inv setReturnValue:&section0Ads];
                    } else {
                        [inv setReturnValue:&section1Ads];
                    }
                });

                placerDelegate should_not have_received(@selector(adPlacer:didRemoveAdsAtIndexPaths:));
                [placer loadAdsForAdUnitID:nil targeting:targeting];
                placerDelegate should have_received(@selector(adPlacer:didRemoveAdsAtIndexPaths:)).with(placer).and_with(expectedIndexPaths);
            });

            it(@"should not remove ads if no ads exist", ^{
                [placer loadAdsForAdUnitID:nil];
                placerDelegate should_not have_received(@selector(adPlacer:didRemoveAdsAtIndexPaths:));
            });

            it(@"should reconstruct placement data with nil positioning", ^{
                fakeProvider.fakeStreamAdPlacementData = nil;

                [placer loadAdsForAdUnitID:adUnitID targeting:targeting];
                MPStreamAdPlacementData *adPlacementData = placer.adPlacementData;

                [adPlacementData desiredInsertionAdIndexPathsForSection:1] should_not be_nil;
                [adPlacementData desiredOriginalAdIndexPathsForSection:1] should_not be_nil;

                [placer loadAdsForAdUnitID:nil targeting:targeting];
                adPlacementData = placer.adPlacementData;

                // Not the best verification... just making sure we have nothing in section 1 (which originally had ad data).
                [adPlacementData desiredInsertionAdIndexPathsForSection:1] should be_nil;
                [adPlacementData desiredOriginalAdIndexPathsForSection:1] should be_nil;
            });

            it(@"should not load any ads", ^{
                [placer loadAdsForAdUnitID:nil targeting:targeting];
                fakeProvider.fakeNativeAdSource should_not have_received(@selector(loadAdsWithAdUnitIdentifier:rendererConfigurations:andTargeting:));
            });
        });

        context(@"when loading with a valid ad unit ID", ^{
            subjectAction(^{
                [placer loadAdsForAdUnitID:adUnitID targeting:targeting];
            });

            it(@"should set the ad unit id on the placer", ^{
                placer.adUnitID should equal(adUnitID);
            });

            it(@"should ask the ad source to load ads with targeting parameters", ^{
                fakeProvider.fakeNativeAdSource should have_received(@selector(loadAdsWithAdUnitIdentifier:rendererConfigurations:andTargeting:)).with(adUnitID).and_with(nativeAdRendererConfigurations).and_with(targeting);
            });

            context(@"if ads have never been placed in the stream", ^{
                it(@"should not notify the delegate that any ads were removed", ^{
                    placerDelegate should_not have_received(@selector(adPlacer:didRemoveAdsAtIndexPaths:));
                });
            });

            context(@"if ads have previously been placed in the stream", ^{
                __block NSArray *adjustedIndexPathsOfAds;

                beforeEach(^{
                    __block NSArray *section0Ads = @[
                                                     [NSIndexPath indexPathForItem:2 inSection:0],
                                                     [NSIndexPath indexPathForItem:8 inSection:0]
                                                     ];
                    __block NSArray *section1Ads = @[
                                                     [NSIndexPath indexPathForItem:0 inSection:1],
                                                     [NSIndexPath indexPathForItem:3 inSection:1]
                                                     ];

                    adjustedIndexPathsOfAds = [[NSArray arrayWithArray:section0Ads] arrayByAddingObjectsFromArray:section1Ads];

                    [placer setItemCount:10 forSection:0];
                    [placer setItemCount:2 forSection:2];

                    placementData stub_method(@selector(adjustedIndexPathsWithAdsInSection:)).and_do(^(NSInvocation *inv) {
                        NSUInteger section;
                        [inv getArgument:&section atIndex:2];

                        if (section == 0) {
                            [inv setReturnValue:&section0Ads];
                        } else {
                            [inv setReturnValue:&section1Ads];
                        }
                    });

                    placerDelegate should_not have_received(@selector(adPlacer:didRemoveAdsAtIndexPaths:));
                });

                it(@"should notify the delegate that those ads have been removed", ^{
                    placerDelegate should have_received(@selector(adPlacer:didRemoveAdsAtIndexPaths:)).with(placer).and_with(adjustedIndexPathsOfAds);
                });
            });

            context(@"when using client-side positioning", ^{
                beforeEach(^{
                    // Don't use a fake placement data; let it construct a real one.
                    fakeProvider.fakeStreamAdPlacementData = nil;
                });

                it(@"should reconstruct placement data", ^{
                    // Track the original one constructed...
                    MPStreamAdPlacementData *original = placer.adPlacementData;

                    // Assign a fake one and then reload.  If the new adPlacementData is the fake, we know it reconstructed it.
                    fakeProvider.fakeStreamAdPlacementData = placementData;
                    [placer loadAdsForAdUnitID:adUnitID targeting:targeting];

                    original should_not equal(placer.adPlacementData);
                    placementData should equal(placer.adPlacementData);
                });
            });

            context(@"when using server-side positioning", ^{
                beforeEach(^{
                    // Don't use a fake placement data; let it construct a real one.
                    fakeProvider.fakeStreamAdPlacementData = nil;

                    MPServerAdPositioning *serverPositioning = [[MPServerAdPositioning alloc] init];
                    placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:serverPositioning rendererConfigurations:nativeAdRendererConfigurations];
                    placer.delegate = placerDelegate;
                });

                it(@"should reset its placement data to be empty", ^{
                    // Save off the original placement data.
                    MPStreamAdPlacementData *original = placer.adPlacementData;

                    fakeProvider.fakeStreamAdPlacementData = placementData;
                    [placer loadAdsForAdUnitID:adUnitID targeting:targeting];

                    placer.adPlacementData should_not equal(original);
                    placer.adPlacementData should equal(placementData);
                });

                it(@"should request positioning information from the server", ^{
                    positioningSource should have_received(@selector(loadPositionsWithAdUnitIdentifier:completionHandler:)).with(adUnitID).and_with(Arguments::anything);
                });

                xcontext(@"when the server successfully returns positions", ^{
                    it(@"should create new placement data using those positions", ^{

                    });
                });

                xcontext(@"when the server fails to return positions", ^{

                });
            });
        });
    });

    describe(@"-isAdAtIndexPath:", ^{
        __block NSIndexPath *indexPath;

        beforeEach(^{
            indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        });

        it(@"should forward the message to the placement data", ^{
            [placer isAdAtIndexPath:indexPath];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(isAdAtAdjustedIndexPath:)).with(indexPath);
        });

        it(@"should return whatever placement data returns", ^{
            __block BOOL stubbedReturnValue = YES;

            placementData stub_method(@selector(isAdAtAdjustedIndexPath:)).and_do(^(NSInvocation *invocation){
                [invocation setReturnValue:&stubbedReturnValue];
            });

            [placer isAdAtIndexPath:indexPath] should be_truthy;
            stubbedReturnValue = NO;
            [placer isAdAtIndexPath:indexPath] should be_falsy;
        });
    });

    describe(@"-adjustedNumberOfItems:inSection:", ^{
        __block NSUInteger numberOfItems;
        __block NSUInteger section;

        beforeEach(^{
            numberOfItems = 3;
            section = 2;
        });

        it(@"should forward the message to the placement data", ^{
            [placer adjustedNumberOfItems:numberOfItems inSection:section];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(adjustedNumberOfItems:inSection:)).with(numberOfItems).and_with(section);
        });

        it(@"should return whatever placement data returns", ^{
            NSUInteger stubbedReturnValue = 27;
            placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return(stubbedReturnValue);
            [placer adjustedNumberOfItems:numberOfItems inSection:section] should equal(stubbedReturnValue);
        });
    });

    describe(@"-adjustedIndexPathForOriginalIndexPath:", ^{
        __block NSIndexPath *indexPath;

        beforeEach(^{
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        });

        it(@"should forward the message to the placement data", ^{
            [placer adjustedIndexPathForOriginalIndexPath:indexPath];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(adjustedIndexPathForOriginalIndexPath:)).with(indexPath);
        });

        it(@"should return whatever placement data returns", ^{
            NSIndexPath *stubbedReturnValue = [NSIndexPath indexPathForRow:2 inSection:1];
            placementData stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_return(stubbedReturnValue);
            [placer adjustedIndexPathForOriginalIndexPath:indexPath] should equal(stubbedReturnValue);
        });
    });

    describe(@"-originalIndexPathForAdjustedIndexPath:", ^{
        __block NSIndexPath *indexPath;

        beforeEach(^{
            indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        });

        it(@"should forward the message to the placement data", ^{
            [placer originalIndexPathForAdjustedIndexPath:indexPath];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(originalIndexPathForAdjustedIndexPath:)).with(indexPath);
        });

        it(@"should return whatever placement data returns", ^{
            NSIndexPath *stubbedReturnValue = [NSIndexPath indexPathForRow:2 inSection:1];
            placementData stub_method(@selector(originalIndexPathForAdjustedIndexPath:)).and_return(stubbedReturnValue);
            [placer originalIndexPathForAdjustedIndexPath:indexPath] should equal(stubbedReturnValue);
        });
    });

    describe(@"-insertItemsAtIndexPaths:", ^{
        it(@"should forward the message to the placement data", ^{
            NSArray *indexPaths = @[[NSIndexPath indexPathForItem:0 inSection:0], [NSIndexPath indexPathForItem:5 inSection:0]];
            [placer insertItemsAtIndexPaths:indexPaths];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(insertItemsAtIndexPaths:)).with(indexPaths);
        });
    });

    describe(@"-deleteItemsAtIndexPaths:", ^{
        it(@"should forward the message to the placement data", ^{
            NSArray *indexPaths = @[[NSIndexPath indexPathForItem:0 inSection:0], [NSIndexPath indexPathForItem:5 inSection:0]];
            [placer deleteItemsAtIndexPaths:indexPaths];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(deleteItemsAtIndexPaths:)).with(indexPaths);
        });

        context(@"deleting items", ^{
            //we need to use a real adPlacementData object here since our deleting functionality depends on the data it holds.
            beforeEach(^{
                fakeProvider.fakeStreamAdPlacementData = nil;

                positioning = [MPClientAdPositioning positioning];
                [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];

                placer = [MPStreamAdPlacer placerWithViewController:viewController adPositioning:positioning rendererConfigurations:nativeAdRendererConfigurations];
                placer.delegate = placerDelegate;
                [placer loadAdsForAdUnitID:@"fake ad unit"];
                [placer setItemCount:3 forSection:0];
                [placer setItemCount:3 forSection:1];
            });

            context(@"when there are no ads in the stream", ^{
                it(@"should not call the delegate method for removing ads", ^{
                    [placer deleteItemsAtIndexPaths:@[_IP(0, 0)]];
                    placerDelegate should_not have_received(@selector(adPlacer:didRemoveAdsAtIndexPaths:));
                });

                it(@"should decrement desired positions by the number of preceding content items deleted", ^{
                    [placer deleteItemsAtIndexPaths:@[_IP(0, 0)]];
                    NSArray *desiredPositions = [placer.adPlacementData desiredInsertionAdIndexPathsForSection:0];
                    desiredPositions should contain(_IP(0, 0));
                    desiredPositions should contain(_IP(1, 0));
                });
            });

            context(@"deleting a content item preceding placed ads", ^{
                it(@"should decrement placed positions by the number of preceding content items deleted", ^{
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(1, 0)];
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
                    NSArray *originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should contain(_IP(1, 0));
                    originalPositions should contain(_IP(2, 0));

                    [placer deleteItemsAtIndexPaths:@[_IP(0, 0)]];

                    originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should contain(_IP(0, 0));
                    originalPositions should contain(_IP(1, 0));
                });

                it (@"should decrement placed positions after the deleted content item, but not before the deleted item", ^{
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(1, 0)];
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
                    NSArray *originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should contain(_IP(1, 0));
                    originalPositions should contain(_IP(2, 0));

                    [placer deleteItemsAtIndexPaths:@[_IP(1, 0)]];

                    originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should equal(@[_IP(1, 0), _IP(1, 0)]);
                });
            });

            context(@"deleting last content item, leaving a trailing ad", ^{
                it(@"should also remove the trailing ad", ^{
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(1, 0)];
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
                    NSArray *originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should contain(_IP(1, 0));
                    originalPositions should contain(_IP(2, 0));

                    [placer deleteItemsAtIndexPaths:@[_IP(2, 0)]];

                    originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should_not contain(_IP(2, 0));
                });
            });

            context(@"deleting all content items in multiple sections", ^{
                it (@"should remove all placed ads", ^{
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(1, 0)];
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 0)];
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(1, 1)];
                    [placer.adPlacementData insertAdData:nice_fake_for([MPNativeAdData class]) atIndexPath:_IP(3, 1)];

                    NSArray *originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should contain(_IP(1, 0));
                    originalPositions should contain(_IP(2, 0));
                    NSArray *originalPositions2 = [placer.adPlacementData originalAdIndexPathsForSection:1];
                    originalPositions2 should contain(_IP(1, 1));
                    originalPositions2 should contain(_IP(2, 1));

                    [placer deleteItemsAtIndexPaths:@[_IP(0, 0), _IP(1, 0), _IP(2, 0), _IP(0, 1), _IP(1, 1), _IP(2, 1)]];

                    originalPositions = [placer.adPlacementData originalAdIndexPathsForSection:0];
                    originalPositions should be_empty;
                    originalPositions2 = [placer.adPlacementData originalAdIndexPathsForSection:1];
                    originalPositions2 should be_empty;
                });
            });
        });
    });

    describe(@"-moveItemAtIndexPath:toIndexPath:", ^{
        it(@"should forward the message to the placement data", ^{
            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [placer moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(moveItemAtIndexPath:toIndexPath:)).with(fromIndexPath).and_with(toIndexPath);
        });
    });

    describe(@"-insertSections:", ^{
        it(@"should forward the message to the placement data", ^{
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:10];
            [placer insertSections:indexSet];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(insertSections:)).with(indexSet);
        });

        describe(@"section counts", ^{
            beforeEach(^{
                [placer setItemCount:0 forSection:0];
                [placer setItemCount:1 forSection:1];
                [placer setItemCount:2 forSection:2];
                [placer setItemCount:3 forSection:3];
            });

            context(@"when inserting one section at the beginning", ^{
                it(@"should adjust the section counts", ^{
                    [placer insertSections:[NSIndexSet indexSetWithIndex:0]];
                    for (NSInteger i = 1; i < 4; ++i) {
                        placer.sectionCounts[@(i)] should equal(@(i-1));
                    }

                    placer.sectionCounts[@0] should equal(@0);
                });
            });

            context(@"when inserting one section at the end", ^{
                it(@"should adjust the section counts", ^{
                    [placer insertSections:[NSIndexSet indexSetWithIndex:4]];
                    for (NSInteger i = 0; i < 4; ++i) {
                        placer.sectionCounts[@(i)] should equal(@(i));
                    }

                    placer.sectionCounts[@(4)] should equal(@0);
                });
            });

            context(@"when inserting multiple sections", ^{
                it(@"should adjust the section counts", ^{
                    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
                    [indexSet addIndex:1];
                    [indexSet addIndex:2];

                    [placer insertSections:indexSet];

                    for (NSInteger i = 0; i < 3; ++i) {
                        placer.sectionCounts[@(i)] should equal(@0);
                    }

                    for (NSInteger i = 3; i < 6; ++i) {
                        placer.sectionCounts[@(i)] should equal(@(i-2));
                    }
                });
            });
        });
    });

    describe(@"-deleteSections:", ^{
        it(@"should forward the message to the placement data", ^{
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:4];
            [placer deleteSections:indexSet];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(deleteSections:)).with(indexSet);
        });

        describe(@"section counts", ^{
            beforeEach(^{
                [placer setItemCount:0 forSection:0];
                [placer setItemCount:1 forSection:1];
                [placer setItemCount:2 forSection:2];
                [placer setItemCount:3 forSection:3];
            });

            context(@"when deleting one section at the beginning", ^{
                it(@"should adjust the section counts", ^{
                    [placer deleteSections:[NSIndexSet indexSetWithIndex:0]];
                    for (NSInteger i = 0; i < 3; ++i) {
                        placer.sectionCounts[@(i)] should equal(@(i+1));
                    }
                });
            });

            context(@"when deleting one section at the end", ^{
                it(@"should not adjust the section counts and clear out the last section's count", ^{
                    [placer deleteSections:[NSIndexSet indexSetWithIndex:3]];
                    for (NSInteger i = 0; i < 3; ++i) {
                        placer.sectionCounts[@(i)] should equal(@(i));
                    }
                    placer.sectionCounts[@(3)] should be_nil;
                });
            });

            context(@"when deleting multiple sections", ^{
                it(@"should adjust the section counts", ^{
                    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
                    [indexSet addIndex:1];
                    [indexSet addIndex:2];

                    [placer deleteSections:indexSet];
                    placer.sectionCounts[@0] should equal(@0);
                    placer.sectionCounts[@1] should equal(@3);
                });
            });
        });
    });

    describe(@"-moveSection:toSection:", ^{
        it(@"should forward the message to the placement data", ^{
            NSUInteger fromSection = 2;
            NSUInteger toSection = 3;
            [placer moveSection:fromSection toSection:toSection];
            fakeProvider.fakeStreamAdPlacementData should have_received(@selector(moveSection:toSection:)).with(fromSection).and_with(toSection);
        });

        describe(@"section counts", ^{
            beforeEach(^{
                [placer setItemCount:0 forSection:0];
                [placer setItemCount:1 forSection:1];
                [placer setItemCount:2 forSection:2];
                [placer setItemCount:3 forSection:3];
            });

            context(@"when moving front to back", ^{
                it(@"should adjust the section counts", ^{
                    [placer moveSection:0 toSection:3];

                    placer.sectionCounts[@0] should equal(@1);
                    placer.sectionCounts[@1] should equal(@2);
                    placer.sectionCounts[@2] should equal(@3);
                    placer.sectionCounts[@3] should equal(@0);
                });
            });

            context(@"when moving sections in the middle", ^{
                it(@"should adjust the section counts", ^{
                    [placer moveSection:2 toSection:1];

                    placer.sectionCounts[@0] should equal(@0);
                    placer.sectionCounts[@1] should equal(@2);
                    placer.sectionCounts[@2] should equal(@1);
                    placer.sectionCounts[@3] should equal(@3);
                });
            });
        });
    });

    describe(@"-shouldPlaceAdAtIndexPath:", ^{
        beforeEach(^{
            [placer setItemCount:1 forSection:0];
            [placer setItemCount:4 forSection:1];
            [placer setItemCount:3 forSection:2];
            placer.visibleIndexPaths = @[
                                         [NSIndexPath indexPathForRow:2 inSection:1],
                                         [NSIndexPath indexPathForRow:3 inSection:1],
                                         [NSIndexPath indexPathForRow:1 inSection:2]
                                         ];
        });

        context(@"when the index path is not within its section's range", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)0);
            });

            it(@"should return false", ^{
                NSIndexPath *testPath = [NSIndexPath indexPathForRow:1 inSection:1];
                [placer shouldPlaceAdAtIndexPath:testPath] should be_falsy;
            });
        });

        context(@"when there are no ads in the stream", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath *(NSIndexPath *adjustedIndexPath) {
                    return adjustedIndexPath;
                });
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)100);
            });

            context(@"when the top considered index path is nil and the bottom considered index path is not nil", ^{
                beforeEach(^{
                    placer.bottomConsideredIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
                    placer.topConsideredIndexPath = nil;
                });

                it(@"should return false", ^{
                    placer.visibleIndexPaths = @[[NSIndexPath indexPathForRow:5 inSection:5]];
                    [placer shouldPlaceAdAtIndexPath:nil] should be_falsy;
                });
            });

            context(@"when the bottom considered index path is nil and the top considered index path is not nil", ^{
                beforeEach(^{
                    placer.topConsideredIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
                    placer.bottomConsideredIndexPath = nil;
                });

                it(@"should return false", ^{
                    placer.visibleIndexPaths = @[[NSIndexPath indexPathForRow:5 inSection:5]];
                    [placer shouldPlaceAdAtIndexPath:nil] should be_falsy;
                });
            });

            context(@"when the top and bottom considered index paths are nil", ^{
                beforeEach(^{
                    placer.topConsideredIndexPath = nil;
                    placer.bottomConsideredIndexPath = nil;
                });

                it(@"should return false", ^{
                    placer.visibleIndexPaths = @[[NSIndexPath indexPathForRow:5 inSection:5]];
                    [placer shouldPlaceAdAtIndexPath:nil] should be_falsy;
                });
            });

            context(@"when the index path is nil", ^{
                it(@"should return false", ^{
                    placer.visibleIndexPaths = @[[NSIndexPath indexPathForRow:5 inSection:5]];
                    [placer shouldPlaceAdAtIndexPath:nil] should be_falsy;
                });
            });

            context(@"when the index path's row is less than the minimum row in the section of the lowest index path", ^{
                it(@"should return false", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:1 inSection:1];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_falsy;
                });
            });

            context(@"when the index path has a section less than the minimum section in visibleIndexPaths", ^{
                it(@"should return false", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:99 inSection:0];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_falsy;
                });
            });

            context(@"when the index path's row is greater than the maximum row in the section of the highest index path", ^{
                it(@"should return false", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:3 inSection:2];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_falsy;
                });
            });

            context(@"when the index path has a section greater than the maximum section in visibleIndexPaths", ^{
                it(@"should return false", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:0 inSection:3];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_falsy;
                });
            });

            context(@"when the index path is within the visible range and is a member of the visibleIndexPaths array", ^{
                it(@"should return true", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:3 inSection:1];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_truthy;
                });
            });

            context(@"when the index path is within the visible range, but not a member of the visibleIndexPaths array ", ^{
                it(@"should return true", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:4 inSection:1];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_truthy;
                });
            });

            context(@"when the index path is equal to the first visible row (when there is more than one visible index path)", ^{
                it(@"should return true", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:2 inSection:1];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_truthy;
                });
            });

            context(@"when the index path is equal to the last visible row (when there is more than one visible index path)", ^{
                it(@"should return true", ^{
                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:1 inSection:2];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_truthy;
                });
            });

            context(@"when the index path is equal to the last visible row (when there is more than one visible index path)", ^{
                it(@"should return true", ^{
                    placer.visibleIndexPaths = @[[NSIndexPath indexPathForRow:5 inSection:5]];

                    NSIndexPath *testPath = [NSIndexPath indexPathForRow:5 inSection:5];
                    [placer shouldPlaceAdAtIndexPath:testPath] should be_truthy;
                });
            });
        });

        context(@"when there are ads in the stream", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedIndexPathForOriginalIndexPath:)).and_do_block(^NSIndexPath *(NSIndexPath *adjustedIndexPath) {
                    return [NSIndexPath indexPathForRow:adjustedIndexPath.row+2 inSection:adjustedIndexPath.section];
                });
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)100);

                spy_on(placer);

                // Stub this method out to do nothing to the index path.  This way we know exactly what our adjusted index path bounds are.
                placer stub_method(@selector(furthestValidIndexPathAfterIndexPath:withinDistance:)).and_do_block(^NSIndexPath *(NSIndexPath *startingPath, NSUInteger distance) {
                    return startingPath;
                });

                placer.visibleIndexPaths = @[
                                             [NSIndexPath indexPathForRow:2 inSection:1],
                                             [NSIndexPath indexPathForRow:3 inSection:1],
                                             [NSIndexPath indexPathForRow:1 inSection:2]
                                             ];
            });

            it(@"should return NO when index path is before the adjusted visible index paths", ^{
                NSIndexPath *testPath = [NSIndexPath indexPathForRow:2 inSection:1];
                [placer shouldPlaceAdAtIndexPath:testPath] should be_falsy;
            });

            it(@"should return NO when the index path is after the adjusted visible index paths", ^{
                NSIndexPath *testPath = [NSIndexPath indexPathForRow:4 inSection:2];
                [placer shouldPlaceAdAtIndexPath:testPath] should be_falsy;
            });

            it(@"should return YES when the index path is in the adjusted range", ^{
                NSIndexPath *testPath1 = [NSIndexPath indexPathForRow:4 inSection:1];
                NSIndexPath *testPath2 = [NSIndexPath indexPathForRow:3 inSection:2];

                [placer shouldPlaceAdAtIndexPath:testPath1] should be_truthy;
                [placer shouldPlaceAdAtIndexPath:testPath2] should be_truthy;
            });
        });
    });

    describe(@"-retrieveAdDataForInsertionPath", ^{
        context(@"when the ad source doesn't return an ad", ^{
            __block NSIndexPath *indexPath;

            beforeEach(^{
                indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                adSource stub_method(@selector(dequeueAdForAdUnitIdentifier:)).and_return(nil);
            });

            it(@"should return nil", ^{
                [placer retrieveAdDataForInsertionPath:indexPath] should be_nil;
            });
        });

        context(@"when the ad source does return an ad", ^{
            __block NSIndexPath *indexPath;
            __block MPNativeAd *nativeAd;

            beforeEach(^{
                indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                nativeAd = nice_fake_for([MPNativeAd class]);
                adSource stub_method(@selector(dequeueAdForAdUnitIdentifier:)).and_return(nativeAd);
            });

            it(@"should return an ad data object that has nativeAd as its ad", ^{
                MPNativeAdData *adData = [placer retrieveAdDataForInsertionPath:indexPath];
                adData.ad should equal(nativeAd);
            });

            xit(@"should set all the properties correctly on the MPNativeAdData object", ^{
            });
        });

    });

    context(@"-fillAdsInConsideredRange", ^{
        beforeEach(^{
            [placer setItemCount:4 forSection:0];
            [placer setItemCount:6 forSection:1];
            adSource stub_method(@selector(dequeueAdForAdUnitIdentifier:)).and_return([[MPNativeAd alloc] init]);
        });

        xcontext(@"when the index path is not within its section's range", {

        });

        context(@"when the index path is within its section's range", ^{
            beforeEach(^{
                placementData stub_method(@selector(adjustedNumberOfItems:inSection:)).and_return((NSUInteger)100);
            });

            context(@"when the top considered index path is nil and the bottom considered index path is not nil", ^{
                beforeEach(^{
                    placer.bottomConsideredIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
                    placer.topConsideredIndexPath = nil;
                    [placer fillAdsInConsideredRange];
                });

                it(@"should not attempt to retrieve insertion paths", ^{
                    placementData should_not have_received(@selector(nextAdInsertionIndexPathForAdjustedIndexPath:));
                });
            });

            context(@"when the bottom considered index path is nil and the top considered index path is not nil", ^{
                beforeEach(^{
                    placer.topConsideredIndexPath = [NSIndexPath indexPathForItem:1 inSection:1];
                    placer.bottomConsideredIndexPath = nil;
                    [placer fillAdsInConsideredRange];
                });

                it(@"should not attempt to retrieve insertion paths", ^{
                    placementData should_not have_received(@selector(nextAdInsertionIndexPathForAdjustedIndexPath:));
                });
            });

            context(@"when the top and bottom considered index paths are nil", ^{
                beforeEach(^{
                    placer.topConsideredIndexPath = nil;
                    placer.bottomConsideredIndexPath = nil;
                    [placer fillAdsInConsideredRange];
                });

                it(@"should not attempt to retrieve insertion paths", ^{
                    placementData should_not have_received(@selector(nextAdInsertionIndexPathForAdjustedIndexPath:));
                });
            });

            context(@"when there isn't a visible index path", ^{
                beforeEach(^{
                    placer.visibleIndexPaths = @[];
                    [placer fillAdsInConsideredRange];
                });

                it(@"should not attempt to retrieve insertion paths", ^{
                    placementData should_not have_received(@selector(nextAdInsertionIndexPathForAdjustedIndexPath:));
                });
            });

            context(@"when placement data determines there are no places to place an ad", ^{
                beforeEach(^{
                    placementData stub_method(@selector(nextAdInsertionIndexPathForAdjustedIndexPath:)).and_return(nil);
                    [placer fillAdsInConsideredRange];
                });

                it(@"should never call adPlacer:didLoadAdAtIndexPath: on the delegate", ^{
                    placerDelegate should_not have_received(@selector(adPlacer:didLoadAdAtIndexPath:));
                });
            });

            // Making sure the stream ad placer will stop placing ads when we're out of ads in placement data.
            context(@"when we can fill all cached ads into visible index paths but we run out of ads in placement data", ^{
                __block NSArray *insertionIndexPaths;
                __block NSInteger count;

                beforeEach(^{
                    insertionIndexPaths = @[
                                            [NSIndexPath indexPathForRow:1 inSection:1],
                                            [NSIndexPath indexPathForRow:2 inSection:1],
                                            [NSIndexPath indexPathForRow:3 inSection:1]
                                            ];

                    placer.visibleIndexPaths = @[
                                                 [NSIndexPath indexPathForRow:1 inSection:1],
                                                 [NSIndexPath indexPathForRow:2 inSection:1],
                                                 [NSIndexPath indexPathForRow:3 inSection:1],
                                                 [NSIndexPath indexPathForRow:4 inSection:1],
                                                 [NSIndexPath indexPathForRow:5 inSection:1]
                                                 ];
                    count = 0;
                    placementData stub_method(@selector(nextAdInsertionIndexPathForAdjustedIndexPath:)).and_do(^(NSInvocation *invocation) {
                        if (insertionIndexPaths.count > count) {
                            NSIndexPath *indexPath = insertionIndexPaths[count];
                            [invocation setReturnValue:&indexPath];
                            ++count;
                        } else {
                            NSIndexPath *indexPath = nil;
                            [invocation setReturnValue:&indexPath];
                        }
                    });

                    [placer fillAdsInConsideredRange];
                });

                it(@"should call adPlacer:didLoadAdAtIndexPath: on the delegate with the correct insertion paths", ^{
                    for (int i = 0; i < 3; ++i) {
                        placerDelegate should have_received(@selector(adPlacer:didLoadAdAtIndexPath:)).with(placer).and_with(insertionIndexPaths[i]);
                    }
                });

                it(@"should call insertAdData:atIndexPath: on placementData", ^{
                    placementData should have_received(@selector(insertAdData:atIndexPath:));
                });
            });

            // Making sure the stream ad placer will stop placing ads when we run out of visible index paths to place ads into.
            context(@"when we can't fill all cached ads into visible index paths", ^{
                __block NSArray *insertionIndexPaths;
                __block NSInteger count;
                beforeEach(^{
                    insertionIndexPaths = @[
                                            [NSIndexPath indexPathForRow:1 inSection:1],
                                            [NSIndexPath indexPathForRow:2 inSection:1],
                                            [NSIndexPath indexPathForRow:3 inSection:1],
                                            [NSIndexPath indexPathForRow:4 inSection:1],
                                            [NSIndexPath indexPathForRow:5 inSection:1]
                                            ];

                    placer.visibleIndexPaths = @[
                                                 [NSIndexPath indexPathForRow:1 inSection:1],
                                                 [NSIndexPath indexPathForRow:2 inSection:1],
                                                 [NSIndexPath indexPathForRow:3 inSection:1],
                                                 [NSIndexPath indexPathForRow:4 inSection:1]
                                                 ];
                    count = 0;
                    placementData stub_method(@selector(nextAdInsertionIndexPathForAdjustedIndexPath:)).and_do(^(NSInvocation *invocation) {
                        if (insertionIndexPaths.count > count) {
                            NSIndexPath *indexPath = insertionIndexPaths[count];
                            [invocation setReturnValue:&indexPath];
                            ++count;
                        } else {
                            NSIndexPath *indexPath = nil;
                            [invocation setReturnValue:&indexPath];
                        }
                    });

                    [placer fillAdsInConsideredRange];
                });

                it(@"should call adPlacer:didLoadAdAtIndexPath: on the delegate with the correct insertion paths", ^{
                    for (int i = 0; i < 4; ++i) {
                        placerDelegate should have_received(@selector(adPlacer:didLoadAdAtIndexPath:)).with(placer).and_with(insertionIndexPaths[i]);
                    }
                });

                it(@"should call insertAdData:atIndexPath: on placementData", ^{
                    placementData should have_received(@selector(insertAdData:atIndexPath:));
                });
            });
        });
    });

    xit(@"should call -fillAdsInConsideredRange when receiving ad source delegate call -adSourceDidFinishRequest:(MPNativeAdSource *)source", ^{

    });


    xit(@"should call -fillAdsInConsideredRange when receiving setVisibleIndexPaths", ^{

    });
});

SPEC_END
