//
//  iCarouselWebViewModuleViewController.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 20/06/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDeckApiCall.h"
#import "WebViewModuleViewController.h"
#import "iCarousel.h"
#import "ManagedUIWebViewController.h"

@interface iCarouselWebViewModuleViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, ManagedUIWebViewDelegate, AppDeckApiCallDelegate>
{
    iCarousel *carousel;
    BOOL       wrap;
    NSMutableArray *items;
}


@property (nonatomic, retain) AppDeckApiCall *apicall;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDictionary *options;


@end
