//
//  iAdCustomEventBanner.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 13.03.2014.
//
//

#import "iAdCustomEventBanner.h"

@implementation iAdCustomEventBanner

static BOOL alreadyReportedAvailability;
static ADBannerView *adBannerView;

- (void)loadBannerWithSize:(CGSize)size optionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    self.trackingPixel = trackingPixel;
    alreadyReportedAvailability = NO;
    
    if(!adBannerView) {
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            adBannerView = [[ADBannerView alloc] init];
        }
        adBannerView.delegate = self;
        [adBannerView setFrame:CGRectMake(0, 0, size.width, size.height)];
    } else if(adBannerView.isBannerLoaded && !alreadyReportedAvailability) {
        alreadyReportedAvailability = YES;
        [self didDisplayAd];
        [self.delegate customEventBannerDidLoadAd:adBannerView];
    } else if (!alreadyReportedAvailability){
        alreadyReportedAvailability = YES;
        [self.delegate customEventBannerDidFailToLoadAd];
    }

}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if(!alreadyReportedAvailability) {
        alreadyReportedAvailability = YES;
        [self didDisplayAd];
        [self.delegate customEventBannerDidLoadAd:adBannerView];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if(!alreadyReportedAvailability) {
        alreadyReportedAvailability = YES;
        [self.delegate customEventBannerDidFailToLoadAd];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [self.delegate customEventBannerWillExpand];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [self.delegate customEventBannerWillClose];
}




@end
