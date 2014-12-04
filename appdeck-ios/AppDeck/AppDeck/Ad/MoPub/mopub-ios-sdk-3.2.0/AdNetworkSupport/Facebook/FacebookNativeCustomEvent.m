//
//  FacebookNativeCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeCustomEvent.h"
#import "FacebookNativeAdAdapter.h"
#import "MPNativeAd.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"

static const NSInteger FacebookNoFillErrorCode = 1001;

@interface FacebookNativeCustomEvent () <FBNativeAdDelegate>

@property (nonatomic, readwrite, strong) FBNativeAd *fbNativeAd;

@end

@implementation FacebookNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    NSString *placementID = [info objectForKey:@"placement_id"];

    if (placementID) {
        _fbNativeAd = [[FBNativeAd alloc] initWithPlacementID:placementID];
        self.fbNativeAd.delegate = self;
        [self.fbNativeAd loadAd];
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
    }
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    FacebookNativeAdAdapter *adAdapter = [[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];

    NSMutableArray *imageURLs = [NSMutableArray array];

    if (nativeAd.icon.url) {
        [imageURLs addObject:nativeAd.icon.url];
    }

    if (nativeAd.coverImage.url) {
        [imageURLs addObject:nativeAd.coverImage.url];
    }

    [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
        if (errors) {
            MPLogDebug(@"%@", errors);
            MPLogInfo(@"Error: data received was invalid.");
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
        } else {
            [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
        }
    }];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    if (error.code == FacebookNoFillErrorCode) {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorNoInventory userInfo:error.userInfo]];
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:error.userInfo]];
    }
}

@end
