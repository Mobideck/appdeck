//
//  MMediaInterstitialAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "InterstitialAdViewController.h"
#import "MMediaAdEngine.h"
#import "MMedia/MMSDK/MMInterstitial.h"
#import <CoreLocation/CoreLocation.h>

@interface MMediaInterstitialAdViewController : InterstitialAdViewController
{
    MMRequest *request;
}
@property (nonatomic, strong)   MMediaAdEngine *adEngine;


@end
