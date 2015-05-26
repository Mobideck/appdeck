//
//  WideSpaceBannerAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import <MobFox-iOS-SDK-20150526/Core/MobFox.h>
//#import "MobFox-iOS-SDK-6.0.0/MobFox.embeddedframework/MobFox.framework/Headers/MobFox.h"
#import "MobFoxAdEngine.h"

@class MobFoxAdEngine;

@interface MobFoxAdViewController : AppDeckAdViewController <MobFoxBannerViewDelegate>
{
}

- (id)initWithAdRation:(AdRation *)adRation engine:(MobFoxAdEngine *)adEngine config:(NSDictionary *)config;

@property (nonatomic, strong)   MobFoxAdEngine *adEngine;

@property (strong, nonatomic) MobFoxBannerView *bannerView;

@end
