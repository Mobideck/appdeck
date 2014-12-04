//
//  FakeGSFullScreenAd.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "GSFullscreenAd.h"
#import "GSAdDelegate.h"

@interface FakeGSFullscreenAd : GSFullscreenAd <FakeInterstitialAd>

@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, copy) NSString *GUID;

@property (nonatomic, assign) BOOL didFetch;
@property (nonatomic, assign) BOOL isAdReady;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserDismissingAd;
- (void)simulateInterstitialFinishedDisappearing;

@end
