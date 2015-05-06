//
//  PrefetchInterstitialViewController.h
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 21/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASInterstitialView.h"


@interface PrefetchInterstitialViewController : UIViewController <SASAdViewDelegate> {
	SASInterstitialView *_interstitial;
}

@end
