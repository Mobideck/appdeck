//
//  MPMRAIDInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialViewControllerMF.h"

#import "MRAdViewMF.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPMRAIDInterstitialViewControllerDelegateMF;
@class MPAdConfigurationMF;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMRAIDInterstitialViewControllerMF : MPInterstitialViewControllerMF <MRAdViewDelegateMF>

- (id)initWithAdConfiguration:(MPAdConfigurationMF *)configuration;
- (void)startLoading;

@end

