//
//  MPNativeAdError.m
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPNativeAdError.h"

NSString * const MoPubNativeAdsSDKDomain = @"com.mopub.nativeads";

NSError *MPNativeAdNSErrorForInvalidAdServerResponse(NSString *reason) {
    if (reason.length == 0) {
        reason = @"Invalid ad server response";
    }

    return [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:@{NSLocalizedDescriptionKey : [reason copy]}];
}

NSError *MPNativeAdNSErrorForAdUnitWarmingUp() {
    return [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorAdUnitWarmingUp userInfo:@{NSLocalizedDescriptionKey : @"Ad unit is warming up"}];
}

NSError *MPNativeAdNSErrorForNoInventory() {
    return [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorNoInventory userInfo:@{NSLocalizedDescriptionKey : @"Ad server returned no inventory"}];
}

NSError *MPNativeAdNSErrorForNetworkConnectionError() {
    return [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorHTTPError userInfo:@{NSLocalizedDescriptionKey : @"Connection error"}];
}

NSError *MPNativeAdNSErrorForInvalidImageURL() {
    return MPNativeAdNSErrorForInvalidAdServerResponse(@"Invalid image URL");
}

NSError *MPNativeAdNSErrorForImageDownloadFailure() {
    return [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorImageDownloadFailed userInfo:@{NSLocalizedDescriptionKey : @"Failed to download images"}];
}

NSError *MPNativeAdNSErrorForContentDisplayErrorMissingRootController() {
    return [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorContentDisplayError userInfo:@{NSLocalizedDescriptionKey : @"Cannot display content without a root view controller"}];
}

NSError *MPNativeAdNSErrorForContentDisplayErrorInvalidURL() {
    return [NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorContentDisplayError userInfo:@{NSLocalizedDescriptionKey : @"Cannot display content without a valid URL"}];
}
