//
//  FacebookNativeAdAdapter.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"

@interface FacebookNativeAdAdapter () <FBNativeAdDelegate>

@property (nonatomic, readonly, strong) FBNativeAd *fbNativeAd;

@end

@implementation FacebookNativeAdAdapter

@synthesize properties = _properties;

- (instancetype)initWithFBNativeAd:(FBNativeAd *)fbNativeAd
{
    if (self = [super init]) {
        _fbNativeAd = fbNativeAd;
        _fbNativeAd.delegate = self;

        NSNumber *starRating = nil;

        // Normalize star rating to 5 stars.
        if (fbNativeAd.starRating.scale != 0) {
            CGFloat ratio = 0.0f;
            ratio = kUniversalStarRatingScale/fbNativeAd.starRating.scale;
            starRating = [NSNumber numberWithFloat:ratio*fbNativeAd.starRating.value];
        }

        NSMutableDictionary *properties = [NSMutableDictionary dictionary];

        if (starRating) {
            [properties setObject:starRating forKey:kAdStarRatingKey];
        }

        if (fbNativeAd.title) {
            [properties setObject:fbNativeAd.title forKey:kAdTitleKey];
        }

        if (fbNativeAd.body) {
            [properties setObject:fbNativeAd.body forKey:kAdTextKey];
        }

        if (fbNativeAd.callToAction) {
            [properties setObject:fbNativeAd.callToAction forKey:kAdCTATextKey];
        }

        if (fbNativeAd.icon.url.absoluteString) {
            [properties setObject:fbNativeAd.icon.url.absoluteString forKey:kAdIconImageKey];
        }

        if (fbNativeAd.coverImage.url.absoluteString) {
            [properties setObject:fbNativeAd.coverImage.url.absoluteString forKey:kAdMainImageKey];
        }

        if (fbNativeAd.placementID) {
            [properties setObject:fbNativeAd.placementID forKey:@"placementID"];
        }

        if (fbNativeAd.socialContext) {
            [properties setObject:fbNativeAd.socialContext forKey:@"socialContext"];
        }

        _properties = properties;
    }

    return self;
}


#pragma mark - MPNativeAdAdapter

- (NSTimeInterval)requiredSecondsForImpression
{
    return 0.0;
}

- (NSURL *)defaultActionURL
{
    return nil;
}

- (BOOL)enableThirdPartyImpressionTracking
{
    return YES;
}

- (BOOL)enableThirdPartyClickTracking
{
    return YES;
}

- (void)willAttachToView:(UIView *)view
{
    [self.fbNativeAd registerViewForInteraction:view withViewController:[self.delegate viewControllerForPresentingModalView]];
}
- (void)didDetachFromView:(UIView *)view
{
    [self.fbNativeAd unregisterView];
}
#pragma mark - FBNativeAdDelegate

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) {
        [self.delegate nativeAdWillLogImpression:self];
    } else {
        MPLogWarn(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
    }
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    } else {
        MPLogWarn(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
}

@end
