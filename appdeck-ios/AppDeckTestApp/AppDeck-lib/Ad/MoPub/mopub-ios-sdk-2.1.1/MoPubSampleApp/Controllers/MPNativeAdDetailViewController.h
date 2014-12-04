//
//  MPNativeAdDetailViewController.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPAdInfo;

extern NSString *const kNativeAdDefaultActionViewKey;

@interface MPNativeAdDetailViewController : UIViewController

- (id)initWithAdInfo:(MPAdInfo *)info;

@end
