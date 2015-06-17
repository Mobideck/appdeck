//
//  MPiAdBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPiAdBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"
#import <iAd/iAd.h>

static const CGFloat kMediumRectangleHeight = 250;

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPADBannerViewManagerObserver <NSObject>

- (void)bannerDidLoad;
- (void)bannerDidFail;
- (void)bannerActionWillBeginAndWillLeaveApplication:(BOOL)willLeave;
- (void)bannerActionDidFinish;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPADBannerViewManager : NSObject <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, strong) NSMutableSet *observers;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

+ (MPADBannerViewManager *)sharedManagerForAdType:(ADAdType)adType;

- (instancetype)initWithAdType:(ADAdType)adType;
- (void)registerObserver:(id<MPADBannerViewManagerObserver>)observer;
- (void)unregisterObserver:(id<MPADBannerViewManagerObserver>)observer;
- (BOOL)shouldTrackImpression;
- (void)didTrackImpression;
- (BOOL)shouldTrackClick;
- (void)didTrackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


@interface MPInstanceProvider (iAdBanners)

- (ADBannerView *)buildADBannerViewWithAdType:(ADAdType)adType;
- (MPADBannerViewManager *)sharedMPADBannerViewManagerForAdType:(ADAdType)adType;

@end

@implementation MPInstanceProvider (iAdBanners)

- (ADBannerView *)buildADBannerViewWithAdType:(ADAdType)adType
{
    if ([[ADBannerView class] instancesRespondToSelector:@selector(initWithAdType:)]) {
        return [[ADBannerView alloc] initWithAdType:adType];
    } else {
        // On versions of iOS older than 6.0, we must avoid -initWithAdType:.
        return [[ADBannerView alloc] init];
    }
}

- (MPADBannerViewManager *)sharedMPADBannerViewManagerForAdType:(ADAdType)adType
{
    NSString *adTypeIdentifier = (adType == ADAdTypeBanner) ? @"banner" : @"medium-rectangle";
    return [self singletonForClass:[MPADBannerViewManager class]
                          provider:^id {
                              return [[MPADBannerViewManager alloc] initWithAdType:adType];
                          }
                           context:adTypeIdentifier];
}

@end

/////////////////////////////////////////////////////////////////////////////////////

@interface MPiAdBannerCustomEvent () <MPADBannerViewManagerObserver>

@property (nonatomic, assign) BOOL onScreen;
@property (nonatomic, strong) MPADBannerViewManager *bannerViewManager;

@end

@implementation MPiAdBannerCustomEvent

@synthesize onScreen = _onScreen;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (ADBannerView *)bannerView
{
    return self.bannerViewManager.bannerView;
}

- (ADAdType)closestADAdTypeFromCGSize:(CGSize)size
{
    UIUserInterfaceIdiom userInterfaceIdiom = [[[MPCoreInstanceProvider sharedProvider] sharedCurrentDevice] userInterfaceIdiom];

    // On iPad, requests for ads with height beyond a certain threshold should result in medium
    // rectangle ads.
    if (userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return size.height >= kMediumRectangleHeight ? ADAdTypeMediumRectangle : ADAdTypeBanner;
    } else {
        return ADAdTypeBanner;
    }
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting iAd banner");

    ADAdType adType = [self closestADAdTypeFromCGSize:size];
    self.bannerViewManager = [MPADBannerViewManager sharedManagerForAdType:adType];
    [self.bannerViewManager registerObserver:self];

    if (self.bannerView.isBannerLoaded) {
        [self bannerDidLoad];
    }
}

- (void)invalidate
{
    self.onScreen = NO;
    [self.bannerViewManager unregisterObserver:self];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    self.bannerView.currentContentSizeIdentifier = UIInterfaceOrientationIsPortrait(orientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
}

- (void)didDisplayAd
{
    self.onScreen = YES;
    [self trackImpressionIfNecessary];
}

- (void)trackImpressionIfNecessary
{
    if (self.onScreen && [self.bannerViewManager shouldTrackImpression]) {
        [self.delegate trackImpression];
        [self.bannerViewManager didTrackImpression];
    }
}

- (void)trackClickIfNecessary
{
    if ([self.bannerViewManager shouldTrackClick]) {
        [self.delegate trackClick];
        [self.bannerViewManager didTrackClick];
    }
}

#pragma mark - <MPADBannerViewManagerObserver>

- (void)bannerDidLoad
{
    [self trackImpressionIfNecessary];
    [self.delegate bannerCustomEvent:self didLoadAd:self.bannerView];
}

- (void)bannerDidFail
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)bannerActionWillBeginAndWillLeaveApplication:(BOOL)willLeave
{
    [self trackClickIfNecessary];
    if (willLeave) {
        [self.delegate bannerCustomEventWillLeaveApplication:self];
    } else {
        [self.delegate bannerCustomEventWillBeginAction:self];
    }
}

- (void)bannerActionDidFinish
{
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end

/////////////////////////////////////////////////////////////////////////////////////

@implementation MPADBannerViewManager

@synthesize bannerView = _bannerView;
@synthesize observers = _observers;
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

+ (MPADBannerViewManager *)sharedManagerForAdType:(ADAdType)adType
{
    return [[MPInstanceProvider sharedProvider] sharedMPADBannerViewManagerForAdType:adType];
}

- (id)initWithAdType:(ADAdType)adType
{
    self = [super init];
    if (self) {
        self.bannerView = [[MPInstanceProvider sharedProvider] buildADBannerViewWithAdType:adType];
        self.bannerView.delegate = self;
        self.observers = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc
{
    self.bannerView.delegate = nil;
}

- (void)registerObserver:(id<MPADBannerViewManagerObserver>)observer;
{
    [self.observers addObject:observer];
}

- (void)unregisterObserver:(id<MPADBannerViewManagerObserver>)observer;
{
    [self.observers removeObject:observer];
}

- (BOOL)shouldTrackImpression
{
    return !self.hasTrackedImpression;
}

- (void)didTrackImpression
{
    self.hasTrackedImpression = YES;
}

- (BOOL)shouldTrackClick
{
    return !self.hasTrackedClick;
}

- (void)didTrackClick
{
    self.hasTrackedClick = YES;
}

#pragma mark - <ADBannerViewDelegate>

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    MPLogInfo(@"iAd banner did load");
    self.hasTrackedImpression = NO;
    self.hasTrackedClick = NO;

    for (id<MPADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerDidLoad];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    MPLogInfo(@"iAd banner did fail with error %@", error.localizedDescription);
    for (id<MPADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerDidFail];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    MPLogInfo(@"iAd banner action will begin");
    for (id<MPADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerActionWillBeginAndWillLeaveApplication:willLeave];
    }
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    MPLogInfo(@"iAd banner action did finish");
    for (id<MPADBannerViewManagerObserver> observer in [self.observers copy]) {
        [observer bannerActionDidFinish];
    }
}

@end

