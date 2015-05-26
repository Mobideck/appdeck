//
//  InMobiCustomEventBanner.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 08.07.2014.
//
//

#import "InMobiCustomEventBanner.h"

@interface InMobiCustomEventBanner()
@property (nonatomic, strong) IMBanner* banner;
@end

@implementation InMobiCustomEventBanner

- (void)loadBannerWithSize:(CGSize)size optionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    
    Class bannerClass = NSClassFromString(@"IMBanner");
    Class sdkClass = NSClassFromString(@"InMobi");
    if(!bannerClass || !sdkClass) {
        [self.delegate customEventBannerDidFailToLoadAd];
        return;
    }
    
    int adSize = IM_UNIT_320x50;
    if(size.width >= 728 && size.height >=90) {
        adSize = IM_UNIT_728x90;
    } else if (size.width >= 468 && size.height >=60) {
        adSize = IM_UNIT_468x60;
    } else if(size.width >= 120 && size.height >=600) {
        adSize = IM_UNIT_120x600;
    } else if(size.width >= 300 && size.height >=250) {
        adSize = IM_UNIT_300x250;
    }
    
    
    [sdkClass initialize:optionalParameters];
    
    self.banner = [[bannerClass alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)
                                            appId:optionalParameters
                                           adSize:adSize];
    self.banner.delegate = self;
    self.banner.refreshInterval = REFRESH_INTERVAL_OFF;
    [self.banner loadBanner];
    
}

- (void)dealloc
{
    self.banner.delegate = nil;
    self.banner = nil;
}


#pragma mark - Delegate methods
- (void)bannerDidReceiveAd:(IMBanner *)banner {
    [self didDisplayAd];
    [self.delegate customEventBannerDidLoadAd:self.banner];
}

- (void)banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error {
    [self.delegate customEventBannerDidFailToLoadAd];
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
    [self.delegate customEventBannerWillClose];
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
    [self.delegate customEventBannerWillExpand];
}




@end
