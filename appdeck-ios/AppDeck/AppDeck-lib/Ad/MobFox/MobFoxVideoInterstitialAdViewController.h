//
//  WideSpaceBannerAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdViewController.h"
#import <MobFox-iOS-SDK-20150317/MobFox.h>
#import "MobFoxAdEngine.h"

@class MobFoxAdEngine;

@interface MobFoxVideoInterstitialAdViewController : AppDeckAdViewController <MobFoxVideoInterstitialViewControllerDelegate>
{
    MobFoxAdType    currentAdvertType;
}

- (id)initWithAdRation:(AdRation *)adRation engine:(MobFoxAdEngine *)adEngine config:(NSDictionary *)config;

@property (nonatomic, strong)   MobFoxAdEngine *adEngine;

@property (nonatomic, strong) MobFoxVideoInterstitialViewController *videoInterstitialViewController;

//- (IBAction)requestInterstitialAdvert:(id)sender;

@end
