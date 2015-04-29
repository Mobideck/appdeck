//
//  FacebookCustomEventBanner.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 16.06.2014.
//
//

#import "FacebookCustomEventBanner.h"

#define COMPILE_FACEBOOK 0 //currently disabled, as it causes problems for project without FBAudienceNetwork framework

@interface FacebookCustomEventBanner()
@property (nonatomic, strong) FBAdView* adBannerView;
@end

@implementation FacebookCustomEventBanner

-(void)loadBannerWithSize:(CGSize)size optionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
#if COMPILE_FACEBOOK
    self.trackingPixel = trackingPixel;
    
    Class bannerClass = NSClassFromString(@"FBAdView");
    if(!bannerClass) {
        [self.delegate customEventBannerDidFailToLoadAd];
        return;
    }
    
    if (size.height >= 90) {
        self.adBannerView = [[bannerClass alloc] initWithPlacementID:optionalParameters
                                                              adSize:kFBAdSizeHeight90Banner
                                                  rootViewController:[self.delegate viewControllerForPresentingModalView]];
    } else {
        self.adBannerView = [[bannerClass alloc] initWithPlacementID:optionalParameters
                                                              adSize:kFBAdSizeHeight50Banner
                                                  rootViewController:[self.delegate viewControllerForPresentingModalView]];
    }
    
    self.adBannerView.delegate = self;
    
    [self.adBannerView loadAd];
#else
    [self.delegate customEventBannerDidFailToLoadAd];
    return;
#endif
    
}

- (id)init
{
    self = [super init];

    return self;
}

-(void)dealloc
{
    self.adBannerView.delegate = nil;
    self.adBannerView = nil;
}

#pragma mark delegate methods
- (void)adViewDidClick:(FBAdView *)adView
{
    [self.delegate customEventBannerWillExpand];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    [self.delegate customEventBannerWillClose];
}

- (void)adViewDidLoad:(FBAdView *)adView
{
    
    [self didDisplayAd];
    [self.delegate customEventBannerDidLoadAd:adView];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    [self.delegate customEventBannerDidFailToLoadAd];
}





@end
