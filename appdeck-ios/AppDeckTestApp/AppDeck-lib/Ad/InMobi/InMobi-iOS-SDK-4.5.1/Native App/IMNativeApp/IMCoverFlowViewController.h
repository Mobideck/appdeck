//
//  IMCoverFlowViewController.h
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "IMNative.h"
#import "IMNativeDelegate.h"

@interface IMCoverFlowViewController : UIViewController<iCarouselDataSource,iCarouselDelegate,IMNativeDelegate> {
    IMNative *nativeAd;
}

@end
