//
//  ToasterViewController.h
//  ObjCSample
//
//  Created by Loïc GIRON DIT METAZ on 16/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASBannerView.h"


@interface ToasterViewController : UIViewController <SASAdViewDelegate> {
	SASBannerView *_toaster;
	BOOL _statusBarHidden;
}

@end
