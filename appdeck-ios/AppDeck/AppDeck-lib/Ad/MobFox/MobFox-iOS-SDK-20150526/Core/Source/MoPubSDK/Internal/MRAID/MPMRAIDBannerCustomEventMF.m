//
//  MPMRAIDBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMRAIDBannerCustomEventMF.h"
#import "MpLoggingMF.h"
#import "MPAdConfigurationMF.h"
#import "MPInstanceProviderMF.h"

@interface MPMRAIDBannerCustomEventMF ()

@property (nonatomic, retain) MRAdViewMF *banner;

@end

@implementation MPMRAIDBannerCustomEventMF

@synthesize banner = _banner;

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfoMF(@"Loading MoPub MRAID banner");
    MPAdConfigurationMF *configuration = [self.delegate configuration];

    CGRect adViewFrame = CGRectZero;
    if ([configuration hasPreferredSize]) {
        adViewFrame = CGRectMake(0, 0, configuration.preferredSize.width,
                                 configuration.preferredSize.height);
    }

    self.banner = [[MPInstanceProviderMF sharedProvider] buildMRAdViewWithFrame:adViewFrame
                                                              allowsExpansion:YES
                                                             closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                placementType:MRAdViewPlacementTypeInline
                                                                     delegate:self];
    
    self.banner.delegate = self;
    [self.banner loadCreativeWithHTMLString:[configuration adResponseHTMLString]
                                    baseURL:nil];
}

- (void)dealloc
{
    self.banner.delegate = nil;
    self.banner = nil;

    [super dealloc];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.banner rotateToOrientation:newOrientation];
}

#pragma mark - MRAdViewDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (MPAdConfigurationMF *)adConfiguration
{
    return [self.delegate configuration];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidLoad:(MRAdViewMF *)adView
{
    MPLogInfoMF(@"MoPub MRAID banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adDidFailToLoad:(MRAdViewMF *)adView
{
    MPLogInfoMF(@"MoPub MRAID banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)closeButtonPressed
{
    //don't care
}

- (void)appShouldSuspendForAd:(MRAdViewMF *)adView
{
    MPLogInfoMF(@"MoPub MRAID banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)appShouldResumeFromAd:(MRAdViewMF *)adView
{
    MPLogInfoMF(@"MoPub MRAID banner did end action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end
