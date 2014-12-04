//
//  MPAdInfo+KIF.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdInfo.h"

@implementation MPAdInfo (KIF)

+ (NSArray *)bannerAds
{
    return @[
             [MPAdInfo infoWithTitle:@"JS Popups" ID:@"c24cd4648f7b4ba79e4498686ed509e6" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Valid StoreKit Link" ID:@"b086a37c8fe911e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Invalid StoreKit Link" ID:@"4ebfdd8a90ba11e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"MRAID Banner" ID:@"agltb3B1Yi1pbmNyDQsSBFNpdGUYzejGEgw" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Legacy Custom Event Banner" ID:@"66e80812a6d411e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"iAd Banner" ID:@"b9572278a20a11e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Millennial Banner" ID:@"1aa442709c9f11e281c11231392559e4" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Google AdMob Banner" ID:@"01535a569c8e11e281c11231392559e4" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Greystripe Banner" ID:@"ab654e0ca39411e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"InMobi Banner" ID:@"f6fc68a8a3a011e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Custom Network Banner" ID:@"76e8c2f4b8f111e281c11231392559e4" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Marketplace Banner" ID:@"f8e21726be6c11e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Click-to-Safari Link" ID:@"d79b3a4ee64248e3a9beadcb51caab57" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Click-to-Safari Link MRAID" ID:@"d133d07aa80a4bf7a77d3a306b6dd3b3" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"HTML MRECT Banner Ad" ID:@"agltb3B1Yi1pbmNyDQsSBFNpdGUYqKO5CAw" type:MPAdInfoMRectBanner],
             [MPAdInfo infoWithTitle:@"Malicious MRAID Banner Ad storePicture" ID:@"2db7c5aabc79406ea0c8fd20f0643f66" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Malicious MRAID Banner Ad playVideo" ID:@"38dea1b00f1e456ea570121a2d178ed3" type:MPAdInfoBanner],
             ];
}

+ (NSArray *)interstitialAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Valid StoreKit Link" ID:@"c3a8fa2690c611e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Millennial Phone Interstitial" ID:@"de4205fc932411e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"iAd Interstitial (iPad-only)" ID:@"7e7e9e50932411e281c11231392559e4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Millennial Phone Interstitial" ID:@"de4205fc932411e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Google AdMob Interstitial" ID:@"16ae389a932d11e281c11231392559e4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Greystripe Interstitial" ID:@"b80aef0c95a911e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"InMobi Interstitial" ID:@"f0cbed0095a911e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Chartboost Interstitial" ID:@"a425ff78959911e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"MRAID Interstitial" ID:@"3aba0056add211e281c11231392559e4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Vungle Interstitial" ID:@"20e01fce81f611e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"AdColony Interstitial" ID:@"e4b75cdda0544e59b668afe6b764c0a1" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"MRAID Interstitial auto playVideo" ID:@"644e65af01d142b8bb238d2dad0dd441" type:MPAdInfoInterstitial],

             ];
}

+ (NSArray *)nativeAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Native Ad" ID:@"8ce943e5b65a4689b434d72736dbed02" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"InMobi Native Ad" ID:@"7e8c0239e49441a28de13b2b11d5282e" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Facebook Native Ad" ID:@"79ca92da81cb4e7c87f697b26c06700d" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Ad (TableView Example)" ID:@"8ce943e5b65a4689b434d72736dbed02" type:MPAdInfoNativeInTableView]
             ];
}

@end
