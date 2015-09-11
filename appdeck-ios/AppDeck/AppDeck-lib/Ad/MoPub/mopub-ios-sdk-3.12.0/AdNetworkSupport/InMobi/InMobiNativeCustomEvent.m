//
//  InMobiNativeCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "InMobiNativeCustomEvent.h"
#import "IMNative.h"
#import "InMobiNativeAdAdapter.h"
#import "MPNativeAd.h"
#import "MPLogging.h"
#import "MPNativeAdError.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdUtils.h"

static NSString *gAppId = nil;

@interface InMobiNativeCustomEvent () <IMNativeDelegate>

@property (nonatomic, strong) IMNative *inMobiAd;

@end

@implementation InMobiNativeCustomEvent

+ (void)setAppId:(NSString *)appId
{
    gAppId = [appId copy];
}

- (void)dealloc
{
    _inMobiAd.delegate = nil;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    NSString *appId = [info objectForKey:@"app_id"];

    if ([appId length] == 0) {
        appId = gAppId;
    }

    if ([appId length]) {
        _inMobiAd = [[IMNative alloc] initWithAppId:appId];
        self.inMobiAd.delegate = self;
        [self.inMobiAd loadAd];
    } else {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"Invalid InMobi app ID")];
    }
}

#pragma mark - IMNativeDelegate

-(void)nativeAdDidFinishLoading:(IMNative*)native
{
    InMobiNativeAdAdapter *adAdapter = [[InMobiNativeAdAdapter alloc] initWithInMobiNativeAd:native];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];

    NSMutableArray *imageURLs = [NSMutableArray array];

    if ([[interfaceAd.properties objectForKey:kAdIconImageKey] length]) {
        if (![MPNativeAdUtils addURLString:[interfaceAd.properties objectForKey:kAdIconImageKey] toURLArray:imageURLs]) {
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
        }
    }

    if ([[interfaceAd.properties objectForKey:kAdMainImageKey] length]) {
        if (![MPNativeAdUtils addURLString:[interfaceAd.properties objectForKey:kAdMainImageKey] toURLArray:imageURLs]) {
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
        }
    }

    [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
        if (errors) {
            MPLogDebug(@"%@", errors);
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
        } else {
            [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
        }
    }];
}

-(void)nativeAd:(IMNative*)native didFailWithError:(IMError*)error
{
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"InMobi ad load error")];
}

@end
