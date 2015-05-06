//
//  InterstitialViewController.h
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 16/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASInterstitialView.h"


@interface InterstitialViewController : UIViewController <SASAdViewDelegate> {
	SASInterstitialView *_interstitial;
	BOOL _statusBarHidden;
}

@end
