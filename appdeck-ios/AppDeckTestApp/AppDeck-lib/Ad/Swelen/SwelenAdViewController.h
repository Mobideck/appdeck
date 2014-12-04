//
//  WideSpaceBannerAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import "SwelenAdEngine.h"

@class SwelenAdEngine;

@interface SwelenAdViewController : AppDeckAdViewController <swelenDelegate>
{
    swAdView *adView;
}

- (id)initWithAdRation:(AdRation *)adRation engine:(SwelenAdEngine *)adEngine config:(NSDictionary *)config;
//- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(SwelenAdEngine *)engine;

@property (nonatomic, strong)   SwelenAdEngine *adEngine;

@end
