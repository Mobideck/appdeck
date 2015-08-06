//
//  FlurryBannerCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"
#import "FlurryAdBanner.h"
#import "FlurryMPConfig.h"

@interface MPInstanceProvider (FlurryBanners)

- (FlurryAdBanner*)bannerForSpace:(NSString *)adSpace delegate:(id<FlurryAdBannerDelegate>)delegate;

@end

@implementation MPInstanceProvider (FlurryBanners)

- (FlurryAdBanner*)bannerForSpace:(NSString *)adSpace delegate:(id<FlurryAdBannerDelegate>)delegate {
    FlurryAdBanner *banner = [[FlurryAdBanner alloc] initWithSpace:adSpace];
    banner.adDelegate = delegate;
    return banner;
}

@end


@interface  FlurryBannerCustomEvent()

@property (nonatomic, strong) NSString *adSpaceName;
@property (nonatomic, strong) UIView* adView;
@property (nonatomic, strong) FlurryAdBanner* adBanner;

@end

@implementation FlurryBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"MoPub instructs Flurry to display an ad, %@, of size: %f, %f" , self, size.width, size.height);
    [FlurryMPConfig sharedInstance];
    
    self.adSpaceName = [info objectForKey:@"adSpaceName"];
    if (!self.adSpaceName) {
        self.adSpaceName = FlurryBannerAdSpaceName;
    }
    
    self.adBanner = [[MPInstanceProvider sharedProvider] bannerForSpace:self.adSpaceName delegate:self];
    
    CGRect theRect = CGRectMake(0, 0, size.width, size.height);
    self.adView = [[UIView alloc] initWithFrame:theRect];
    [self.adBanner fetchAdForFrame:theRect];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}
    
- (void)dealloc {
    _adBanner.adDelegate = nil;
}

#pragma mark - FlurryAdBannerDelegate

- (void) adBannerDidFetchAd:(FlurryAdBanner *)bannerAd {
    MPLogInfo(@"Flurry banner ad fetched");
    [self.adBanner displayAdInView:self.adView viewControllerForPresentation:[self.delegate viewControllerForPresentingModalView]];
}

- (void) adBannerDidRender:(FlurryAdBanner*)bannerAd {
    MPLogInfo(@"Flurry banner ad rendered");
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:self.adView];
}

- (void) adBannerWillPresentFullscreen:(FlurryAdBanner*)bannerAd {
    MPLogDebug(@"Flurry banner ad will present fullscreen");
}

- (void) adBannerWillLeaveApplication:(FlurryAdBanner*)bannerAd {
    MPLogDebug(@"Flurry banner ad will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (void) adBannerWillDismissFullscreen:(FlurryAdBanner*)bannerAd {
    MPLogDebug(@"Flurry banner ad will dismiss full screen");
}

- (void) adBannerDidDismissFullscreen:(FlurryAdBanner*)bannerAd {
    MPLogDebug(@"Flurry banner ad was dismissed");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void) adBannerDidReceiveClick:(FlurryAdBanner*)bannerAd {
    MPLogInfo(@"Flurry banner ad was clicked");
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void) adBannerVideoDidFinish:(FlurryAdBanner*)bannerAd {
    MPLogDebug(@"Flurry banner ad video finished");
}

- (void) adBanner:(FlurryAdBanner*) bannerAd adError:(FlurryAdError) adError errorDescription:(NSError*) errorDescription; {
    MPLogInfo(@"Flurry banner failed to load with error: %@", errorDescription.description);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:errorDescription];
}

@end
