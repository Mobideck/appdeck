//
//  MoPubBannerAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import "MoPubAdEngine.h"
//#import "mopub-ios-sdk/MoPubSDK/MPAdView.h"
//#import "mopub-ios-sdk/MoPubSDK/MPInterstitialAdController.h"

@interface MoPubAdViewController : AppDeckAdViewController <MPAdViewDelegate>
{

}

//- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(MoPubAdEngine *)engine;
- (id)initWithAdRation:(AdRation *)adRation engine:(MoPubAdEngine *)adEngine config:(NSDictionary *)config;

@property (nonatomic, strong)   MoPubAdEngine *adEngine;
@property (nonatomic, retain)   MPAdView *adView;

@end
