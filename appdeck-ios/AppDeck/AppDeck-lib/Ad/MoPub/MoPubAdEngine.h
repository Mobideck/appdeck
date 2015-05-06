//
//  MoPubAdEngine.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdEngine.h"

#import "mopub-ios-sdk-3.7.0/MoPubSDK/MPAdView.h"
#import "mopub-ios-sdk-3.7.0/MoPubSDK/MPInterstitialAdController.h"
#import "mopub-ios-sdk-3.7.0/MoPubSDK/Internal/Utility/MPSessionTracker.h"

@interface MoPubAdEngine : AppDeckAdEngine

@property (strong, nonatomic) NSString *bannerAdUnitId;
@property (strong, nonatomic) NSString *rectangleAdUnitId;
@property (strong, nonatomic) NSString *InterstitialAdUnitId;
@property (strong, nonatomic) NSString *InterstitialLandscapeAdUnitId;

@property (strong, nonatomic) NSString *bannerTabletAdUnitId;
@property (strong, nonatomic) NSString *rectangleTabletAdUnitId;
@property (strong, nonatomic) NSString *InterstitialTabletAdUnitId;
@property (strong, nonatomic) NSString *InterstitialTabletLandscapeAdUnitId;

-(void)setMetaData:(MPAdView *)adView;
-(void)setInterstitialMetaData:(MPInterstitialAdController *)adInterstitial;

@end
