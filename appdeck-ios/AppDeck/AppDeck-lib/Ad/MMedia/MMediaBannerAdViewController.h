//
//  MMediaBannerAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "BannerAdViewController.h"
#import "MMediaAdEngine.h"
#import "MMedia/MMSDK/MMSDK.h"
#import <CoreLocation/CoreLocation.h>
#import "MMedia/MMSDK/MMAdView.h"

#define MILLENNIAL_IPHONE_AD_VIEW_FRAME CGRectMake(0, 0, 320, 50)
#define MILLENNIAL_IPAD_AD_VIEW_FRAME CGRectMake(0, 0, 728, 90)
#define MILLENNIAL_AD_VIEW_FRAME ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? MILLENNIAL_IPAD_AD_VIEW_FRAME : MILLENNIAL_IPHONE_AD_VIEW_FRAME)

@interface MMediaBannerAdViewController : BannerAdViewController
{
    MMRequest *request;
    MMAdView *adview;
}
@property (nonatomic, strong)   MMediaAdEngine *adEngine;

@end
