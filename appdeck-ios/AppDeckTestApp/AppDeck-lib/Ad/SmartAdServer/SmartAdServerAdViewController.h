//
//  WideSpaceBannerAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"

#import "SmartAdServerAdEngine.h"

@class SmartAdServerAdEngine;

@interface SmartAdServerAdViewController : AppDeckAdViewController <SASAdViewDelegate>
{
    SASAdView *adView;
}

- (id)initWithAdRation:(AdRation *)adRation engine:(SmartAdServerAdEngine *)adEngine config:(NSDictionary *)config;

@property (nonatomic, strong)   SmartAdServerAdEngine *adEngine;

@end
