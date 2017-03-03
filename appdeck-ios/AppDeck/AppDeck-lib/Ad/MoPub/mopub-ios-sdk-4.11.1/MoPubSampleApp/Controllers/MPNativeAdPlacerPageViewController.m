//
//  MPNativeAdPlacerPageViewController.m
//  MoPubSampleApp
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdPlacerPageViewController.h"
#import "MPAdInfo.h"
#import "MPStreamAdPlacer.h"
#import "MPClientAdPositioning.h"
#import "MPNativeAdPageView.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"

// This variable will extend the ad placer's visible range by kVisiblePathLookAhead view controllers.
const NSUInteger kVisiblePathLookAhead = 0;
const NSUInteger kBeginningNumberOfPages = 8;

@interface MPNativeAdPlacerPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, MPStreamAdPlacerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, readonly) MPStreamAdPlacer *streamAdPlacer;
@property (nonatomic, readonly) MPAdInfo *adInfo;
@property (nonatomic, readonly) NSMutableArray *contentViewControllers;
@property (nonatomic, readonly) UIPageViewController *pageViewController;
@property (nonatomic, readonly) NSMutableArray *visibleIndexPaths;
@property (nonatomic, readwrite) UIActionSheet *actionSheet;
@property (nonatomic, readwrite) UIAlertView *deleteAlertView;
@property (nonatomic, readwrite) UIAlertView *insertAlertView;
@property (nonatomic, readwrite) NSInteger adCount;

@end

@implementation MPNativeAdPlacerPageViewController

- (instancetype)initWithAdInfo:(MPAdInfo *)info
{
    self = [super init];
    if (self) {
        self.title = @"Page View Controller Ad Placer";
        _adInfo = info;

        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;

        // Set up where we want to place our ads within the page view controller.
        MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
        [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [positioning enableRepeatingPositionsWithInterval:2];

        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
        settings.renderingViewClass = [MPNativeAdPageView class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) {
            return self.view.bounds.size;
        };

        MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
        _streamAdPlacer = [MPStreamAdPlacer placerWithViewController:self adPositioning:positioning rendererConfigurations:@[config]];
        _streamAdPlacer.delegate = self;

        // Create a bunch of alternating red/green view controllers.
        _contentViewControllers = [[NSMutableArray alloc] init];

        for (NSUInteger i = 0; i < kBeginningNumberOfPages; ++i) {
            UIViewController *vc = [[UIViewController alloc] init];

            if (i % 2 == 0) {
                vc.view.backgroundColor = [UIColor redColor];
            } else {
                vc.view.backgroundColor = [UIColor greenColor];
            }

            [_contentViewControllers addObject:vc];
        }

        _visibleIndexPaths = [NSMutableArray array];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];

        _deleteAlertView = [[UIAlertView alloc] initWithTitle:@"Choose which page(s) to delete" message:@"You can delete multiple pages by separating indices with commas. Do not delete ads." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        _deleteAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;

        _insertAlertView = [[UIAlertView alloc] initWithTitle:@"Choose which page(s) to insert" message:@"You can insert multiple pages by separating indices with commas." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Insert", nil];
        _insertAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    [[self.pageViewController view] setFrame:[[self view] bounds]];
    [self addChildViewController:self.pageViewController];
    [[self view] addSubview:[self.pageViewController view]];
    [self.pageViewController didMoveToParentViewController:self];
    [self.pageViewController setViewControllers:@[self.contentViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // Upon load, set our visible index paths and issue a load ads request.
    [self updateVisibleIndexPaths];
    [self.streamAdPlacer setItemCount:self.contentViewControllers.count forSection:0];
    [self.streamAdPlacer loadAdsForAdUnitID:self.adInfo.ID];
}

- (void)editButtonPressed:(UIBarButtonItem *)item
{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Page(s)" otherButtonTitles:@"Insert Page(s)", @"Re-insert ads", nil];
    [self.actionSheet showInView:self.view];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger newPos = [self.contentViewControllers indexOfObject:viewController] + 1;

    if (newPos < self.contentViewControllers.count) {
        return self.contentViewControllers[newPos];
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger newPos = [self.contentViewControllers indexOfObject:viewController] - 1;

    if (newPos >= 0) {
        return self.contentViewControllers[newPos];
    } else {
        return nil;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.contentViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    if (self.pageViewController.viewControllers.count) {
        return [self.contentViewControllers indexOfObject:self.pageViewController.viewControllers[0]];
    } else {
        return 0;
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self updateVisibleIndexPaths];
}

#pragma mark - Private

- (void)updateVisibleIndexPaths
{
    NSUInteger pos = [self.contentViewControllers indexOfObject:self.pageViewController.viewControllers[0]];

    [self.visibleIndexPaths removeAllObjects];

    for (NSInteger i = pos; i <= pos + kVisiblePathLookAhead; ++i) {
        if (i < self.contentViewControllers.count) {
            [self.visibleIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }

    self.streamAdPlacer.visibleIndexPaths = self.visibleIndexPaths;
}

#pragma mark - MPStreamAdPlacerDelegate

- (void)adPlacer:(MPStreamAdPlacer *)adPlacer didLoadAdAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    UIView *adView = [[UIView alloc] initWithFrame:frame];
    UIViewController *vc = [[UIViewController alloc] init];
    [vc.view addSubview:adView];
    [vc.view setFrame:frame];

    [self.contentViewControllers insertObject:vc atIndex:indexPath.row];
    [self.streamAdPlacer renderAdAtIndexPath:indexPath inView:adView];

    [self.pageViewController setViewControllers:@[self.pageViewController.viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self updateVisibleIndexPaths];

    self.adCount++;
}

- (void)adPlacer:(MPStreamAdPlacer *)adPlacer didRemoveAdsAtIndexPaths:(NSArray *)indexPaths
{
    NSMutableIndexSet *deletionIndices = [NSMutableIndexSet indexSet];

    for (NSIndexPath *indexPath in indexPaths) {
        [deletionIndices addIndex:indexPath.row];
    }

    [self.contentViewControllers removeObjectsAtIndexes:deletionIndices];

    [self.pageViewController setViewControllers:@[self.contentViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self updateVisibleIndexPaths];

    self.adCount -= deletionIndices.count;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.deleteAlertView show];
            break;
        case 1:
            [self.insertAlertView show];
            break;
        case 2:
            [self.streamAdPlacer loadAdsForAdUnitID:self.adInfo.ID];
            break;
        case 3:
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView == self.deleteAlertView) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            NSArray *deletionIndicesStr = [text componentsSeparatedByString:@","];
            NSMutableArray *deletionIndexPaths = [NSMutableArray array];
            NSMutableIndexSet *deletionIndices = [NSMutableIndexSet indexSet];

            for (NSString *indexStr in deletionIndicesStr) {
                NSInteger indexNum = [indexStr integerValue];
                [deletionIndexPaths addObject:[NSIndexPath indexPathForRow:indexNum inSection:0]];
                [deletionIndices addIndex:indexNum];
            }

            [self.contentViewControllers removeObjectsAtIndexes:deletionIndices];
            [self.streamAdPlacer deleteItemsAtIndexPaths:deletionIndexPaths];

            // Don't worry about the logic to shift or keep the same place.  Just go to the first view controller.
            [self.pageViewController setViewControllers:@[self.contentViewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        } else if (alertView == self.insertAlertView) {
            NSString *text = [alertView textFieldAtIndex:0].text;
            NSArray *insertionIndicesStr = [text componentsSeparatedByString:@","];
            NSMutableArray *insertionIndexPaths = [NSMutableArray array];

            for (NSString *indexStr in insertionIndicesStr) {
                NSInteger indexNum = [indexStr integerValue];
                [insertionIndexPaths addObject:[NSIndexPath indexPathForRow:indexNum inSection:0]];

                UIViewController *vc = [[UIViewController alloc] init];
                vc.view.backgroundColor = [UIColor blueColor];
                [self.contentViewControllers insertObject:vc atIndex:indexNum];
            }

            [self.streamAdPlacer insertItemsAtIndexPaths:insertionIndexPaths];
            [self.pageViewController setViewControllers:@[self.pageViewController.viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }

        [self.streamAdPlacer setItemCount:self.contentViewControllers.count-self.adCount forSection:0];
    }
}

@end
