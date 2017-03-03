//
//  FakeGSBannerAdView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "GSMobileBannerAdView.h"

@interface FakeGSBannerAdView : GSMobileBannerAdView

@property (nonatomic, copy) NSString *GUID;
@property (nonatomic, assign) BOOL didFetch;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;

@end
