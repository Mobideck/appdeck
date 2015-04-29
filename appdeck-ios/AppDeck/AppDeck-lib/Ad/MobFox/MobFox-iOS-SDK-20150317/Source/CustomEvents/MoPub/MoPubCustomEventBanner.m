//
//  MoPubCustomEventBanner.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 18.06.2014.
//
//

#import "MoPubCustomEventBanner.h"

@interface MoPubCustomEventBanner()
@property (nonatomic, retain) MPAdView* adBannerView;
@end

@implementation MoPubCustomEventBanner

- (void)loadBannerWithSize:(CGSize)size optionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    
    self.adBannerView = [[MPAdView alloc]initWithAdUnitId:optionalParameters size:CGSizeMake(size.width, size.height)];
    self.adBannerView.delegate = self;
    self.adBannerView.frame = CGRectMake(0, 0, size.width, size.height);
    
    [self.adBannerView loadAd];
    
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)dealloc
{
    self.adBannerView.delegate = nil;
    self.adBannerView = nil;
}

#pragma mark delegate methods
- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    [self didDisplayAd];
    [self.delegate customEventBannerDidLoadAd:self.adBannerView];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    [self.delegate customEventBannerDidFailToLoadAd];
}

- (void)willPresentModalViewForAd:(MPAdView *)view
{
    [self.delegate customEventBannerWillExpand];
}

- (void)didDismissModalViewForAd:(MPAdView *)view
{
    [self.delegate customEventBannerWillClose];
}


@end
