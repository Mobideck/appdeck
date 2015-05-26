//
//  MPMoPubNativeCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPMoPubNativeCustomEventMF.h"
#import "MPMoPubNativeAdAdapterMF.h"
#import "MPNativeAdMF+Internal.h"
#import "MPNativeAdErrorMF.h"
#import "MPLoggingMF.h"

@implementation MPMoPubNativeCustomEventMF

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    MPMoPubNativeAdAdapterMF *adAdapter = [[MPMoPubNativeAdAdapterMF alloc] initWithAdProperties:[[info mutableCopy] autorelease]];

    if (adAdapter.properties) {
        MPNativeAdMF *interfaceAd = [[[MPNativeAdMF alloc] initWithAdAdapter:adAdapter] autorelease];
        [interfaceAd.impressionTrackers addObjectsFromArray:adAdapter.impressionTrackers];

        // Get the image urls so we can download them prior to returning the ad.
        NSMutableArray *imageURLs = [NSMutableArray array];
        for (NSString *key in [info allKeys]) {
            if ([[key lowercaseString] hasSuffix:@"image"] && [[info objectForKey:key] isKindOfClass:[NSString class]]) {
                [imageURLs addObject:[NSURL URLWithString:[info objectForKey:key]]];
            }
        }
        [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
            if (errors) {
                MPLogDebugMF(@"%@", errors);
                MPLogInfoMF(@"Error: data received was invalid.");
                [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomainMF code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
            } else {
                [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
            }
        }];
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomainMF code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
    }

    [adAdapter release];
}

@end
