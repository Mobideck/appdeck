//
//  MMediaRectangleAdViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 08/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

/*#import "RectangleAdViewController.h"*/
#import "MMediaAdEngine.h"
#import <MillennialMedia/MMSDK.h>
#import <CoreLocation/CoreLocation.h>
#import "MillennialMedia/MMAdView.h"

@interface MMediaRectangleAdViewController : AdViewController
{
    MMRequest *request;
    MMAdView *adview;
}
@property (nonatomic, strong)   MMediaAdEngine *adEngine;

@end
