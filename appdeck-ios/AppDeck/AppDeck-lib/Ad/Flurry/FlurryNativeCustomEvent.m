//
//  FlurryNativeCustomEvent.m
//  MoPub Mediates Flurry
//
//  Created by Flurry.
//  Copyright (c) 2015 Yahoo, Inc. All rights reserved.
//

#import "FlurryNativeCustomEvent.h"
#import "FlurryAdNative.h"
#import "FlurryNativeAdAdapter.h"
#import "MPNativeAd.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"
#import "FlurryMPConfig.h"

@interface FlurryNativeCustomEvent () <FlurryAdNativeDelegate>

@property (nonatomic, retain) FlurryAdNative *adNative;

@end

@implementation FlurryNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    [FlurryMPConfig sharedInstance];
    NSString *adSpace = [info objectForKey:@"adSpaceName"];
    if (adSpace) {
        self.adNative = [[FlurryAdNative alloc] initWithSpace:adSpace];
        self.adNative.adDelegate = self;
        [self.adNative fetchAd];
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
    }
}

#pragma mark - Flurry Ad Delegates

- (void) adNativeDidFetchAd:(FlurryAdNative *)flurryAd
{
    MPLogDebug(@"Flurry native ad fetched (customEvent)");
    FlurryNativeAdAdapter *adAdapter = [[FlurryNativeAdAdapter alloc] initWithFlurryAdNative:flurryAd];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    NSMutableArray *imageURLs = [NSMutableArray array];
    for (int ix = 0; ix < flurryAd.assetList.count; ++ix) {
        FlurryAdNativeAsset* asset = [flurryAd.assetList objectAtIndex:ix];
        if ([asset.name isEqualToString:@"secImage"]) {
            [imageURLs addObject:[NSURL URLWithString:asset.value]];
        }
        if ([asset.name isEqualToString:@"secHqImage"]) {
            [imageURLs addObject:[NSURL URLWithString:asset.value]];
        }
    }
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

- (void) adNative:(FlurryAdNative *)flurryAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    MPLogDebug(@"Flurry native ad failed to load with error (customEvent): %@", errorDescription.description);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:errorDescription];
}

- (void) adNativeWillPresent:(FlurryAdNative*) nativeAd {
    MPLogDebug(@"Flurry native ad will present (customEvent)");
}

- (void) adNativeWillLeaveApplication:(FlurryAdNative*) nativeAd {
    MPLogDebug(@"Flurry native ad will leave application (customEvent)");
}

- (void) adNativeWillDismiss:(FlurryAdNative*) nativeAd {
    MPLogDebug(@"Flurry native ad will dismiss (customEvent)");
}

- (void) adNativeDidDismiss:(FlurryAdNative*) nativeAd {
    MPLogDebug(@"Flurry native ad did dismiss (customEvent)");
}

- (void) adNativeDidReceiveClick:(FlurryAdNative*) nativeAd {
    MPLogDebug(@"Flurry native ad was clicked (customEvent)");
}

@end
