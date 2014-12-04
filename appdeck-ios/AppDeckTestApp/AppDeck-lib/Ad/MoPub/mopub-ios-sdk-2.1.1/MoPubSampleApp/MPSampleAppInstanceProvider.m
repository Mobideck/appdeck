//
//  MPSampleAppInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppInstanceProvider.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"

static MPSampleAppInstanceProvider *sharedProvider = nil;

@implementation MPSampleAppInstanceProvider

+ (MPSampleAppInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[MPSampleAppInstanceProvider alloc] init];
    }
    return sharedProvider;
}

- (MPAdView *)buildMPAdViewWithAdUnitID:(NSString *)ID size:(CGSize)size
{
    return [[MPAdView alloc] initWithAdUnitId:ID size:size];
}

- (MPInterstitialAdController *)buildMPInterstitialAdControllerWithAdUnitID:(NSString *)ID
{
    return [MPInterstitialAdController interstitialAdControllerForAdUnitId:ID];
}

@end
