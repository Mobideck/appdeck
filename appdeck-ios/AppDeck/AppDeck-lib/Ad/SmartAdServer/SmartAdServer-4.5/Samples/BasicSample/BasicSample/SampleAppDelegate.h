//
//  SampleAppDelegate.h
//  Sample
//
//  Created by Julien Stoeffler on 07/07/11.
//  Copyright 2011 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASInterstitialView.h"


@interface SampleAppDelegate : UIResponder <UIApplicationDelegate, SASAdViewDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) SASInterstitialView *startupInterstitial;

@end
