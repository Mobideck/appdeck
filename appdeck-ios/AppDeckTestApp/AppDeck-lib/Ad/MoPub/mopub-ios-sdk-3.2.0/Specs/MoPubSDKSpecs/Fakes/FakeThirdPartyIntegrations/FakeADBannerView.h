//
//  FakeADBannerView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADBannerView;
@protocol ADBannerViewDelegate;

@interface FakeADBannerView : UIView

@property (nonatomic, weak) id<ADBannerViewDelegate> delegate;
@property (nonatomic, assign, getter=isBannerLoaded) BOOL bannerLoaded;
@property (nonatomic, copy) NSString *currentContentSizeIdentifier;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserInteraction;
- (void)simulateUserDismissingAd;
- (void)simulateUserLeavingApplication;
- (ADBannerView *)masquerade;

@end
