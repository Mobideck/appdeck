//
//  MPNativeAd.m
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPNativeAdMF+Internal.h"
#import "MPAdConfigurationMF.h"
#import "MPCoreInstanceProviderMF.h"
#import "MPNativeAdErrorMF.h"
#import "MPLoggingMF.h"
#import "MPNativeCacheMF.h"
#import "MPNativeAdRenderingMF.h"
#import "MPImageDownloadQueueMF.h"
#import "UIImageView+MPNativeAdMF.h"
#import "NSJSONSerialization+MPAdditionsMF.h"
#import "MPNativeCustomEventMF.h"
#import "MPNativeAdAdapterMF.h"
#import "MPNativeAdConstantsMF.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPNativeAdMF ()

@property (nonatomic, retain) NSURL *engagementTrackingURL;
@property (nonatomic, retain) NSMutableSet *impressionTrackers;

@property (nonatomic, readonly, retain) id<MPNativeAdAdapterMF> adAdapter;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

@property (nonatomic, copy) NSString *adIdentifier;
@property (nonatomic, retain) UIView *associatedView;
@property (nonatomic, retain) NSTimer *associatedViewVisibilityTimer;
@property (nonatomic, assign) NSTimeInterval firstVisibilityTimestamp;
@property (nonatomic, assign) BOOL visible;

@property (nonatomic, retain) NSMutableSet *managedImageViews;
@property (nonatomic, retain) MPImageDownloadQueueMF *imageDownloadQueue;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPNativeAdMF

- (instancetype)initWithAdAdapter:(id<MPNativeAdAdapterMF>)adAdapter
{
    static int sequenceNumber = 0;

    self = [super init];
    if (self) {
        _adAdapter = [adAdapter retain];
        _adIdentifier = [[NSString stringWithFormat:@"%d", sequenceNumber++] copy];
        _firstVisibilityTimestamp = -1;
        _impressionTrackers = [[NSMutableSet alloc] init];
        _imageDownloadQueue = [[MPImageDownloadQueueMF alloc] init];
        _managedImageViews = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_adAdapter release];
    [_impressionTrackers release];
    [_engagementTrackingURL release];
    [_adIdentifier release];
    [_associatedView release];
    [_associatedViewVisibilityTimer invalidate];
    [_associatedViewVisibilityTimer release];
    [_imageDownloadQueue release];

    [self removeAssociatedObjectsFromManagedImageViews];
    [_managedImageViews release];

    [super dealloc];
}

- (void)removeAssociatedObjectsFromManagedImageViews
{
    for (UIImageView *imageView in _managedImageViews) {
        if ([imageView mp_nativeAd] == self) {
            [imageView mp_removeNativeAd];
        }
    }
}

#pragma mark - Public

- (NSNumber *)starRating
{
    NSNumber *starRatingNum = [self.properties objectForKey:kAdStarRatingKeyMF];

    if (![starRatingNum isKindOfClass:[NSNumber class]] || starRatingNum.floatValue < kStarRatingMinValueMF || starRatingNum.floatValue > kStarRatingMaxValueMF) {
        starRatingNum = nil;
    }

    return starRatingNum;
}

- (NSDictionary *)properties
{
    return self.adAdapter.properties;
}

- (NSURL *)defaultActionURL
{
    return self.adAdapter.defaultActionURL;
}

- (NSTimeInterval)requiredSecondsForImpression
{
    if ([self.adAdapter respondsToSelector:@selector(requiredSecondsForImpression)]) {
        return self.adAdapter.requiredSecondsForImpression;
    }

    return kDefaultRequiredSecondsForImpressionMF;
}

- (void)trackImpression
{
    if (self.hasTrackedImpression) {
        MPLogDebugMF(@"Impression already tracked.");
        return;
    }

    MPLogDebugMF(@"Tracking an impression for %@.", self.adIdentifier);
    self.hasTrackedImpression = YES;
    for (NSString *URLString in self.impressionTrackers) {
        NSURL *URL = [NSURL URLWithString:URLString];
        if (URL) {
            [self trackMetricForURL:URL];
        }
    }

    if ([self.adAdapter respondsToSelector:@selector(trackImpression)]) {
        [self.adAdapter trackImpression];
    }
}

- (void)trackClick
{
    if (self.hasTrackedClick) {
        return;
    }

    self.hasTrackedClick = YES;

    if (self.engagementTrackingURL) {
        [self trackMetricForURL:self.engagementTrackingURL];
    }

    if ([self.adAdapter respondsToSelector:@selector(trackClick)]) {
        [self.adAdapter trackClick];
    }

}

- (void)trackMetricForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[MPCoreInstanceProviderMF sharedProvider] buildConfiguredURLRequestWithURL:URL];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [NSURLConnection connectionWithRequest:request delegate:nil];
}

- (void)displayContentFromRootViewController:(UIViewController *)controller completion:(void (^)(BOOL, NSError *))completionBlock
{
    [self displayContentForURL:self.adAdapter.defaultActionURL rootViewController:controller completion:completionBlock];
}

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
       completion:(void (^)(BOOL success, NSError *error))completionBlock
{
    [self trackClick];
    [self.adAdapter displayContentForURL:URL rootViewController:controller completion:completionBlock];
}

- (void)prepareForDisplayInView:(UIView *)view
{
    self.associatedView = view;

    if ([view conformsToProtocol:@protocol(MPNativeAdRenderingMF)]) {
        [self willAttachToView:view];
        [(id<MPNativeAdRenderingMF>)view layoutAdAssets:self];
    }

    [self.associatedViewVisibilityTimer invalidate];
    self.associatedViewVisibilityTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(tick:) userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:self.associatedViewVisibilityTimer forMode:NSRunLoopCommonModes];
}

- (void)addImpressionTrackers:(NSArray *)trackers
{
    [self.impressionTrackers addObjectsFromArray:trackers];
}

- (void)tick:(NSTimer *)timer
{
    if ([self hasTrackedImpression]) {
        [self.associatedViewVisibilityTimer invalidate];
        self.associatedViewVisibilityTimer = nil;
    }

    [self setVisible:MPViewIsVisibleMF(self.associatedView)];
}

#pragma mark - Rendering

- (void)loadIconIntoImageView:(UIImageView *)imageView
{
    NSURL *imageURL = [NSURL URLWithString:[self.properties objectForKey:kAdIconImageKeyMF]];
    [self loadImageForURL:imageURL intoImageView:imageView];
}

- (void)loadImageIntoImageView:(UIImageView *)imageView
{
    NSURL *imageURL = [NSURL URLWithString:[self.properties objectForKey:kAdMainImageKeyMF]];
    [self loadImageForURL:imageURL intoImageView:imageView];
}

- (void)loadTextIntoLabel:(UILabel *)label
{
    label.text = [self.properties objectForKey:kAdTextKeyMF];
}

- (void)loadTitleIntoLabel:(UILabel *)label
{
    label.text = [self.properties objectForKey:kAdTitleKeyMF];
}

- (void)loadCallToActionTextIntoLabel:(UILabel *)label
{
    label.text = [self.properties objectForKey:kAdCTATextKeyMF];
}

- (void)loadCallToActionTextIntoButton:(UIButton *)button
{
    [button setTitle:[self.properties objectForKey:kAdCTATextKeyMF] forState:UIControlStateNormal];
}

- (void)loadImageForURL:(NSURL *)imageURL intoImageView:(UIImageView *)imageView
{
    imageView.image = nil;
    [imageView mp_setNativeAd:self];
    [self.managedImageViews addObject:imageView];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *cachedImageData = [[MPNativeCacheMF sharedCache] retrieveDataForKey:imageURL.absoluteString];
        UIImage *image = [UIImage imageWithData:cachedImageData];

        if (image) {
            [self safeMainQueueSetImage:image intoImageView:imageView];
        } else if (imageURL) {
            MPLogDebugMF(@"Cache miss on %@. Re-downloading...", imageURL);

            [self.imageDownloadQueue addDownloadImageURLs:@[imageURL]
                                          completionBlock:^(NSArray *errors) {
                                              if (errors.count == 0) {
                                                  UIImage *image = [UIImage imageWithData:[[MPNativeCacheMF sharedCache] retrieveDataForKey:imageURL.absoluteString]];

                                                  [self safeMainQueueSetImage:image intoImageView:imageView];
                                              } else {
                                                  MPLogDebugMF(@"Failed to download %@ on cache miss. Giving up for now.", imageURL);
                                              }
                                          }];
        }
    });
}

#pragma mark - Internal

- (void)willAttachToView:(UIView *)view
{
    if ([self.adAdapter respondsToSelector:@selector(willAttachToView:)]) {
        [self.adAdapter willAttachToView:view];
    }
}

- (void)safeMainQueueSetImage:(UIImage *)image intoImageView:(UIImageView *)imageView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MPNativeAdMF *ad = [imageView mp_nativeAd];
        if (ad && ad != self) {
            MPLogDebugMF(@"Cell was recycled. Don't bother setting the image.");
            return;
        }

        if (image) {
            imageView.image = image;
        }
    });
}

- (void)setVisible:(BOOL)visible
{
    if (visible) {
        NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];

        if (self.firstVisibilityTimestamp == -1) {
            self.firstVisibilityTimestamp = now;
        } else if (now - self.firstVisibilityTimestamp >= self.requiredSecondsForImpression) {
            self.firstVisibilityTimestamp = -1;
            [self trackImpression];
        }
    } else {
        self.firstVisibilityTimestamp = -1;
    }
}

@end
