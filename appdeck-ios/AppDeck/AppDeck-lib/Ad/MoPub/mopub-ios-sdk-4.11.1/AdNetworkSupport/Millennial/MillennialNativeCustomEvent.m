//
//  MillennialNativeCustomEvent.m
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#import "MillennialNativeCustomEvent.h"
#import "MillennialNativeAdAdapter.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"

#import <MMAdSDK/MMAdSDK.h>
#import "MMNativeAd+ClientMediation.h"

static NSString *const kMoPubMMAdapterAdUnit = @"adUnitID";
static NSString *const kMoPubMMAdapterDCN = @"dcn";

@interface MillennialNativeCustomEvent() <MMNativeAdDelegate>

@property (nonatomic, strong) MMNativeAd *nativeAd;

@end

@implementation MillennialNativeCustomEvent

- (id)init {
    if (self = [super init]) {
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0) {
            MMSDK *mmSDK = [MMSDK sharedInstance];
            if (![mmSDK isInitialized]) {
                MMAppSettings *appSettings = [[MMAppSettings alloc] init];
                [mmSDK initializeWithSettings:appSettings withUserSettings:nil];
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.nativeAd.delegate = nil;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {

    MMSDK *mmSDK = [MMSDK sharedInstance];

    if (![mmSDK isInitialized]) {
        MPLogError(@"Millennial adapter not properly intialized yet.");
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    NSLog(@"Requesting Millennial native ad.");

    NSString *placementId = info[kMoPubMMAdapterAdUnit];
    if (!placementId) {
        MPLogError(@"Millennial received invalid APID. Request failed.");
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    [mmSDK appSettings].mediator = @"MillennialNativeCustomEvent";
    if (info[kMoPubMMAdapterDCN]) {
        mmSDK.appSettings.siteId = info[kMoPubMMAdapterDCN];
    } else {
        mmSDK.appSettings.siteId = nil;
    }

    self.nativeAd = [[MMNativeAd alloc] initWithPlacementId:placementId supportedTypes:@[MMNativeAdTypeInline]];
    self.nativeAd.delegate = self;
    [self.nativeAd load:nil];
}

#pragma mark - MMNativeAdDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)nativeAdRequestDidSucceed:(MMNativeAd *)ad {
    MPLogInfo(@"Millennial native ad %@ did load successfully.", ad);
    MillennialNativeAdAdapter *adapter = [[MillennialNativeAdAdapter alloc] initWithMMNativeAd:self.nativeAd];
    MPNativeAd *mpNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];

    NSMutableArray *imageURLs = [NSMutableArray array];

    if (ad.mainImageInfo[MMNativeImageInfoURLKey]) {
        [imageURLs addObject:ad.mainImageInfo[MMNativeImageInfoURLKey]];
    }

    if (ad.iconImageInfo[MMNativeImageInfoURLKey]) {
        [imageURLs addObject:ad.iconImageInfo[MMNativeImageInfoURLKey]];
    }

    [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
        if (errors) {
            MPLogError(@"Failed caching URLs for Millennial native ad with errors: %@", errors);
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
            return;
        } else {
            [self.delegate nativeCustomEvent:self didLoadAd:mpNativeAd];
        }
    }];
}

- (void)nativeAd:(MMNativeAd *)ad requestDidFailWithError:(NSError *)error {
    MPLogWarn(@"Millennial native ad did fail loading with error: %@.", error);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForNoInventory()];
}

@end
