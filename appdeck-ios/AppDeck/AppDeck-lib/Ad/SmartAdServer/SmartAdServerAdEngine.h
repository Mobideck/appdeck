//
//  WideSpaceAdEngine.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "../../AppDeckAdEngine.h"

#import "SASAd.h"
#import "SASBannerView.h"
#import "SASInterstitialView.h"

@interface SmartAdServerAdEngine : AppDeckAdEngine

@property (strong, nonatomic)   NSString *siteID;
@property (strong, nonatomic)   NSString *pageID;
@property (strong, nonatomic)   NSString *formatBannerID;
@property (strong, nonatomic)   NSString *formatRectangleID;
@property (strong, nonatomic)   NSString *formatinterstitialID;
@property (strong, nonatomic)   NSString *networkID;
@property (strong, nonatomic)   NSString *baseURL;

@end
