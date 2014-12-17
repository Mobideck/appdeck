//
//  MoPubInterstitialAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 09/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import "MoPubAdEngine.h"

@class MoPubAdEngine;

@interface MoPubInterstitialAdViewController : AppDeckAdViewController <MPInterstitialAdControllerDelegate>

- (id)initWithAdRation:(AdRation *)adRation engine:(MoPubAdEngine *)adEngine config:(NSDictionary *)config;

@property (nonatomic, strong)   MoPubAdEngine *adEngine;
@property (nonatomic, retain) MPInterstitialAdController *interstitial;

@end
