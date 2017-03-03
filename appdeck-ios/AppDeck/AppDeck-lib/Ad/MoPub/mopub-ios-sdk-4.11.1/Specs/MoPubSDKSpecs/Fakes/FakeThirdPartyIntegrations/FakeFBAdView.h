//
//  FakeFBAdView.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface FakeFBAdView : UIView

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, weak) id<FBAdViewDelegate> delegate;
@property (nonatomic, assign, getter=isBannerLoaded) BOOL bannerLoaded;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserInteraction;
- (void)simulateUserInteractionFinished;
- (FBAdView *)masquerade;

- (void)loadAd;

@end
