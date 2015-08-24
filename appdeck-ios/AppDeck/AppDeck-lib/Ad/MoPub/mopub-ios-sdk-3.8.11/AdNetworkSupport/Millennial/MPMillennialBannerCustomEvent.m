#import "MPMillennialBannerCustomEvent.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

#define MM_SIZE_320x50  CGSizeMake(320, 50)
#define MM_SIZE_300x250 CGSizeMake(300, 250)
#define MM_SIZE_728x90  CGSizeMake(728, 90)

@interface MPInstanceProvider (MillennialBanners)

- (MMInlineAd *)buildMMInlineAdWithSize:(CGSize)size placementId:(NSString *)placementId;

@end

@implementation MPInstanceProvider (MillennialBanners)

- (MMInlineAd *)buildMMInlineAdWithSize:(CGSize)size placementId:(NSString *)placementId
{
    return [[MMInlineAd alloc] initWithPlacementId:placementId size:size];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMillennialBannerCustomEvent ()

@property (nonatomic, assign) BOOL didTrackImpression;
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, assign) BOOL didShowModal;

@property (nonatomic, strong) MMInlineAd *mmInlineAds;

- (CGRect)frameFromCustomEventInfo:(NSDictionary *)info;
- (CGSize)sizeFromCustomEventInfo:(NSDictionary *)info;

@end

@implementation MPMillennialBannerCustomEvent

@synthesize didTrackImpression = _didTrackImpression;
@synthesize didTrackClick = _didTrackClick;
@synthesize mmInlineAds = _mmInlineAds;


- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        if ( ![[MMSDK sharedInstance] isInitialized] ) {
            [[MMSDK sharedInstance] initializeWithSettings:[[MMAppSettings alloc] init] withUserSettings:[[MMUserSettings alloc] init]];
        }
    }
    return self;
}

- (void)invalidate
{
    self.mmInlineAds = nil;
    self.delegate = nil;
}

- (void)dealloc
{
    [self invalidate];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Millennial banner");
    NSString *placementId = [info objectForKey:@"adUnitID"];

    // If Custom Event Class Data contains DCN / Position, let's use that instead.
    // { "dcn": "...", "adUnitID": "..."  }
    [[MMSDK sharedInstance] appSettings].mediator = @"MPMillennialBannerCustomEvent";
    if ( [info objectForKey:@"dcn"] ) {
        [[[MMSDK sharedInstance] appSettings] setSiteId:[info objectForKey:@"dcn"]];
    } else {
        [[[MMSDK sharedInstance] appSettings] setSiteId:nil];
    }

    if ( !placementId ) {
        MPLogError(@"Millennial received invalid placement ID. Request failed.");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    [[MMSDK sharedInstance] setSendLocationIfAvailable:[[MoPub sharedInstance] locationUpdatesEnabled]];

    self.mmInlineAds = [[MPInstanceProvider sharedProvider] buildMMInlineAdWithSize:size placementId:placementId];
    self.mmInlineAds.delegate = self;
    self.mmInlineAds.refreshInterval = -1;

    [self.mmInlineAds.view setFrame:[self frameFromCustomEventInfo:info]];
    [self.mmInlineAds request:nil];

}

- (CGSize)sizeFromCustomEventInfo:(NSDictionary *)info
{
    CGFloat width = [[info objectForKey:@"adWidth"] floatValue];
    CGFloat height = [[info objectForKey:@"adHeight"] floatValue];
    return CGSizeMake(width, height);
}

- (CGRect)frameFromCustomEventInfo:(NSDictionary *)info
{
    CGSize size = [self sizeFromCustomEventInfo:info];
    if (!CGSizeEqualToSize(size, MM_SIZE_300x250) && !CGSizeEqualToSize(size, MM_SIZE_728x90)) {
        size.width = MM_SIZE_320x50.width;
        size.height = MM_SIZE_320x50.height;
    }
    return CGRectMake(0, 0, size.width, size.height);
}


#pragma mark - MMInlineAdDelegate methods

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}


- (void)inlineAdContentTapped:(MMInlineAd *)ad {
    if (!self.didTrackClick) {
        MPLogInfo(@"Millennial banner was clicked.");
        [self.delegate trackClick];
        self.didTrackClick = YES;
    } else {
        MPLogInfo(@"Millennial banner ignoring duplicate click");
    }
}


- (void)inlineAdWillPresentModal:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner will present modal");
    self.didShowModal = YES;
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)inlineAdDidCloseModal:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner did dismiss modal");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)inlineAdRequestDidSucceed:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:ad.view];
    [self didDisplayAd];
    if (!self.didTrackImpression) {
        [self.delegate trackImpression];
        self.didTrackImpression = YES;
    }
}

- (void)inlineAd:(MMInlineAd *)ad requestDidFailWithError:(NSError *)error {
    MPLogError(@"Millennial interstitial ad failed with error (%d) %@", error.code, error.description);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}


@end
