//
//  MPNativeAdPlacerCollectionViewController.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdPlacerCollectionViewController.h"
#import "MPAdInfo.h"
#import "MPCollectionViewAdPlacer.h"
#import "MPCollectionViewAdPlacerView.h"
#import "MPClientAdPositioning.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPNativeAdConstants.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPStaticNativeAdRendererSettings.h"
#import <CoreLocation/CoreLocation.h>

@interface MPNativeAdPlacerCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, MPCollectionViewAdPlacerDelegate>

@property (nonatomic) MPAdInfo *adInfo;
@property (nonatomic) NSMutableArray *contentItems;
@property (nonatomic) MPCollectionViewAdPlacer *placer;

@end

static NSString *const kReuseIdentifier = @"cell";

@implementation MPNativeAdPlacerCollectionViewController

- (id)initWithAdInfo:(MPAdInfo *)info
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(70, 113);

    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = @"Collection View Ads";
        self.adInfo = info;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kReuseIdentifier];

    [self setupContent];
    [self setupAdPlacer];
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark - Content

- (void)setupContent
{
    self.contentItems = [NSMutableArray array];

    for (NSInteger i = 0; i < 200; i++) {
        NSInteger r = arc4random() % 256;
        NSInteger g = arc4random() % 256;
        NSInteger b = arc4random() % 256;
        [self.contentItems addObject:[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]];
    }
}

#pragma mark - AdPlacer

- (void)setupAdPlacer
{
    // Create a targeting object to serve better ads.
    MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
    targeting.desiredAssets = [NSSet setWithObjects:kAdTitleKey, kAdIconImageKey, kAdCTATextKey, nil];
    targeting.location = [[CLLocation alloc] initWithLatitude:37.7793 longitude:-122.4175];

    // Create and configure a renderer configuration for native ads.
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    settings.renderingViewClass = [MPCollectionViewAdPlacerView class];
    settings.viewSizeHandler = ^(CGFloat maximumWidth) {
        return CGSizeMake(70.0f, 113.0f);
    };

    MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];

    // Create a collection view ad placer that uses server-side ad positioning.
    self.placer = [MPCollectionViewAdPlacer placerWithCollectionView:self.collectionView viewController:self rendererConfigurations:@[config]];

    // If you wish to use client-side ad positioning rather than configuring your ad unit on the
    // MoPub website, comment out the line above and use the code below instead.

    /*
    // Create an ad positioning object and register the index paths where ads should be displayed.
    MPClientAdPositioning *positioning = [MPClientAdPositioning positioning];
    [positioning addFixedIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [positioning enableRepeatingPositionsWithInterval:15];

    self.placer = [MPCollectionViewAdPlacer placerWithCollectionView:self.collectionView viewController:self adPositioning:positioning rendererConfigurations:@[config]];
     */

    self.placer.delegate = self;
    // Load ads (using a test ad unit ID). Feel free to replace this ad unit ID with your own.
    [self.placer loadAdsForAdUnitID:self.adInfo.ID targeting:targeting];
}

#pragma mark - <MPCollectionViewAdPlacerDelegate>

- (void)nativeAdWillPresentModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer
{
    NSLog(@"Collection view ad placer will present modal.");
}

- (void)nativeAdDidDismissModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer
{
    NSLog(@"Collection view ad placer did dismiss modal.");
}

- (void)nativeAdWillLeaveApplicationFromCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer
{
    NSLog(@"Collection view ad placer will leave application.");
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.contentItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     * IMPORTANT: add the mp_ prefix to dequeueReusableCellWithReuseIdentifier:forIndexPath:.
     */
    UICollectionViewCell *cell = [collectionView mp_dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = self.contentItems[indexPath.item];
    return cell;
}

@end
