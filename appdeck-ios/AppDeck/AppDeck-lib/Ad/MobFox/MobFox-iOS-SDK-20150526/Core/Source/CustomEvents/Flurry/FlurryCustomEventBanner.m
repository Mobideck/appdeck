//
//  FlurryCustomEventBanner.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 14.07.2014.
//
//

#import "FlurryCustomEventBanner.h"

@interface FlurryCustomEventBanner()
@property (nonatomic, strong) NSString* adSpace;
@property (nonatomic, strong) UIView* bannerView;
@end

@implementation FlurryCustomEventBanner

- (void)loadBannerWithSize:(CGSize)size optionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    NSString* adId;
    NSArray *tmp=[optionalParameters componentsSeparatedByString:@";"];
    
    Class flurryClass = NSClassFromString(@"Flurry");
    Class flurryAdsClass = NSClassFromString(@"FlurryAds");
    if(!flurryAdsClass || !flurryClass || [tmp count] != 2) {
        [self.delegate customEventBannerDidFailToLoadAd];
        return;
    }
    _bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _adSpace = [tmp objectAtIndex:0];
    adId = [tmp objectAtIndex:1];
    
    [flurryClass startSession:adId];
    [flurryAdsClass initialize:[self.delegate viewControllerForPresentingModalView]];
    [flurryAdsClass setAdDelegate:self];
    [flurryAdsClass fetchAdForSpace:_adSpace frame:[_bannerView frame] size:BANNER_BOTTOM];
    
}

-(void)dealloc {
    Class flurryAdsClass = NSClassFromString(@"FlurryAds");
    [flurryAdsClass removeAdFromSpace:_adSpace];
    [flurryAdsClass setAdDelegate:nil];
}

-(void)spaceDidReceiveAd:(NSString *)adSpace {
    if(![adSpace isEqualToString:_adSpace]) {
        return;
    }
    Class flurryAdsClass = NSClassFromString(@"FlurryAds");
    [self didDisplayAd];
    [flurryAdsClass displayAdForSpace:_adSpace onView:_bannerView];
    [self.delegate customEventBannerDidLoadAd:self.bannerView];
}

-(void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error {
    if(![adSpace isEqualToString:_adSpace]) {
        return;
    }
    [self.delegate customEventBannerDidFailToLoadAd];
}

-(void)spaceWillExpand:(NSString *)adSpace {
    if(![adSpace isEqualToString:_adSpace]) {
        return;
    }
    [self.delegate customEventBannerWillExpand];
}

-(void)spaceWillCollapse:(NSString *)adSpace {
    if(![adSpace isEqualToString:_adSpace]) {
        return;
    }
    [self.delegate customEventBannerWillClose];
}




@end
