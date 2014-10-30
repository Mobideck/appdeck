//
//  FakeInterstitialAdapter.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBaseInterstitialAdapter.h"

@interface FakeInterstitialAdapter : MPBaseInterstitialAdapter

@property (nonatomic, assign) MPAdConfiguration *configurationForLastRequest;
@property (nonatomic, assign) UIViewController *presentingViewController;

- (void)failToLoad;
- (void)loadSuccessfully;

@end
