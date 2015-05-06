//
//  BannerViewController.h
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASBannerView.h"


@interface BannerViewController : UIViewController <SASAdViewDelegate> {
	SASBannerView *_banner;
	BOOL _statusBarHidden;
}

@end
