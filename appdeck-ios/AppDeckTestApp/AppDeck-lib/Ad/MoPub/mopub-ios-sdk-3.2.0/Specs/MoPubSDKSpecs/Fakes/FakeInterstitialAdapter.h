//
//  FakeInterstitialAdapter.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBaseInterstitialAdapter.h"

@interface FakeInterstitialAdapter : MPBaseInterstitialAdapter

@property (nonatomic, strong) MPAdConfiguration *configurationForLastRequest;
@property (nonatomic, strong) UIViewController *presentingViewController;

- (void)failToLoad;
- (void)loadSuccessfully;

@end
