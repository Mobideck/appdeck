//
//  MPMillennialBannerCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MPMillennialBannerCustomEvent.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

#define MM_SIZE_320x50  CGSizeMake(320, 50)
#define MM_SIZE_300x250 CGSizeMake(300, 250)
#define MM_SIZE_728x90  CGSizeMake(728, 90)

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

@implementation MPInstanceProvider (MillennialBanners)

- (MMInlineAd *)buildMMInlineAdWithSize:(CGSize)size placementId:(NSString *)placementId {
    return [[MMInlineAd alloc] initWithPlacementId:placementId size:size];
}

@end

@interface MPMillennialBannerCustomEvent ()

@property (nonatomic, assign) BOOL didTrackImpression;
@property (nonatomic, assign) BOOL didTrackClick;

@property (nonatomic, strong) MMInlineAd *mmInlineAd;

@end

@implementation MPMillennialBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

- (id)init {
    self = [super init];
    if (self) {
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0) {
            MMSDK *mmSDK = [MMSDK sharedInstance];
            if ([mmSDK isInitialized] == NO) {
                MMAppSettings *appSettings = [[MMAppSettings alloc] init];
                [mmSDK initializeWithSettings:appSettings withUserSettings:nil];
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.mmInlineAd = nil;
    self.delegate = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {

    MMSDK *mmSDK = [MMSDK sharedInstance];

    if ([mmSDK isInitialized] == NO) {
        MPLogError(@"Millennial adapter not properly intialized yet.");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    MPLogInfo(@"Requesting Millennial banner.");

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (!placementId) {
        MPLogError(@"Millennial received invalid placement ID. Request failed.");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    [mmSDK appSettings].mediator = @"MPMillennialBannerCustomEvent";
    if (info[kMoPubMMAdapterDCN]) {
        [mmSDK appSettings].siteId = info[kMoPubMMAdapterDCN];
    } else {
        [mmSDK appSettings].siteId = nil;
    }

    self.mmInlineAd = [[MPInstanceProvider sharedProvider] buildMMInlineAdWithSize:size placementId:placementId];
    self.mmInlineAd.delegate = self;
    self.mmInlineAd.refreshInterval = -1;

    [self.mmInlineAd.view setFrame:[self frameFromCustomEventInfo:info]];
    [self.mmInlineAd request:nil];

}

- (CGSize)sizeFromCustomEventInfo:(NSDictionary *)info {
    CGFloat width = [info[@"adWidth"] floatValue];
    CGFloat height = [info[@"adHeight"] floatValue];
    return CGSizeMake(width, height);
}

- (CGRect)frameFromCustomEventInfo:(NSDictionary *)info {
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
        MPLogInfo(@"Millennial banner %@ was clicked.", ad);
        [self.delegate trackClick];
        self.didTrackClick = YES;
    } else {
        MPLogInfo(@"Millennial banner %@ ignoring duplicate click.", ad);
    }
}

- (void)inlineAdWillPresentModal:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner %@ will present modal.", ad);
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)inlineAdDidCloseModal:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner %@ did dismiss modal.", ad);
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)inlineAdRequestDidSucceed:(MMInlineAd *)ad {
    MPLogInfo(@"Millennial banner %@ did load.", ad);
    [self.delegate bannerCustomEvent:self didLoadAd:ad.view];
    [self didDisplayAd];
    if (!self.didTrackImpression) {
        [self.delegate trackImpression];
        self.didTrackImpression = YES;
    }
}

- (void)inlineAd:(MMInlineAd *)ad requestDidFailWithError:(NSError *)error {
    MPLogError(@"Millennial banner %@ failed with error (%d) %@", ad, error.code, error.description);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}


@end
