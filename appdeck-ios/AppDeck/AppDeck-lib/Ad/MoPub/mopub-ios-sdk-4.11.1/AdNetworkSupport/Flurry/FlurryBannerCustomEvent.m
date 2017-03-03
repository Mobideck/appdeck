//
//  FlurryBannerCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryBannerCustomEvent.h"
#import "FlurryAdBanner.h"
#import "FlurryMPConfig.h"

#import "MPInstanceProvider.h"
#import "MPLogging.h"

@interface MPInstanceProvider (FlurryBanners)

- (FlurryAdBanner*)bannerForSpace:(NSString *)adSpace delegate:(id<FlurryAdBannerDelegate>)delegate;

@end

@implementation MPInstanceProvider (FlurryBanners)

- (FlurryAdBanner*)bannerForSpace:(NSString *)adSpace delegate:(id<FlurryAdBannerDelegate>)delegate
{
    FlurryAdBanner *banner = [[FlurryAdBanner alloc] initWithSpace:adSpace];
    banner.adDelegate = delegate;
    return banner;
}

@end


@interface  FlurryBannerCustomEvent()

@property (nonatomic, strong) UIView* adView;
@property (nonatomic, strong) FlurryAdBanner* adBanner;

@end

@implementation FlurryBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Flurry banner ad of size: %f, %f" , size.width, size.height);
    
    NSString *apiKey = [info objectForKey:@"apiKey"];
    NSString *adSpaceName = [info objectForKey:@"adSpaceName"];
    
    if (!apiKey || !adSpaceName) {
        MPLogError(@"Failed banner ad fetch. Missing required server extras [FLURRY_APIKEY and/or FLURRY_ADSPACE]");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    } else {
        MPLogInfo(@"Server info fetched from MoPub for Flurry. API key: %@. Ad space name: %@", apiKey, adSpaceName);
    }
    
    [FlurryMPConfig startSessionWithApiKey:apiKey];
    
    self.adBanner = [[MPInstanceProvider sharedProvider] bannerForSpace:adSpaceName delegate:self];
    
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

- (void) adBannerDidFetchAd:(FlurryAdBanner *)bannerAd
{
    MPLogInfo(@"Flurry banner ad fetched");
    [self.adBanner displayAdInView:self.adView viewControllerForPresentation:[self.delegate viewControllerForPresentingModalView]];
}

- (void) adBannerDidRender:(FlurryAdBanner*)bannerAd
{
    MPLogInfo(@"Flurry banner ad rendered");
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:self.adView];
}

- (void) adBannerWillPresentFullscreen:(FlurryAdBanner*)bannerAd
{
    MPLogDebug(@"Flurry banner ad will present fullscreen");
}

- (void) adBannerWillLeaveApplication:(FlurryAdBanner*)bannerAd
{
    MPLogDebug(@"Flurry banner ad will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (void) adBannerWillDismissFullscreen:(FlurryAdBanner*)bannerAd
{
    MPLogDebug(@"Flurry banner ad will dismiss full screen");
}

- (void) adBannerDidDismissFullscreen:(FlurryAdBanner*)bannerAd
{
    MPLogDebug(@"Flurry banner ad was dismissed");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void) adBannerDidReceiveClick:(FlurryAdBanner*)bannerAd
{
    MPLogInfo(@"Flurry banner ad was clicked");
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void) adBannerVideoDidFinish:(FlurryAdBanner*)bannerAd
{
    MPLogDebug(@"Flurry banner ad video finished");
}

- (void) adBanner:(FlurryAdBanner*) bannerAd
          adError:(FlurryAdError) adError errorDescription:(NSError*) errorDescription;
{
    MPLogInfo(@"Flurry banner failed to load with error: %@", errorDescription.description);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:errorDescription];
}

@end
