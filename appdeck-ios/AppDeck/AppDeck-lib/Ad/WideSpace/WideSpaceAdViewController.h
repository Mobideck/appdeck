//
//  WideSpaceBannerAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import "widespace-sdk-ios-4.6.0/WSLibrary.framework/Headers/WSAdSpace.h"
#import "WideSpaceAdEngine.h"

@class WideSpaceAdEngine;

@interface WideSpaceAdViewController : AppDeckAdViewController <WSAdSpaceDelegate>
{
    WSAdSpace *adView;
}

- (id)initWithAdRation:(AdRation *)adRation engine:(WideSpaceAdEngine *)adEngine config:(NSDictionary *)config;
//- (id)initWithAdManager:(AdManager *)adManager type:(NSString *)adType engine:(WideSpaceAdEngine *)engine;

@property (nonatomic, strong)   WideSpaceAdEngine *adEngine;

@end
