//
//  FakeGADBannerView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GADBannerView;
@class GADRequest;

@protocol GADBannerViewDelegate;

@interface FakeGADBannerView : UIView

@property (nonatomic, copy) NSString *adUnitID;
@property (nonatomic, weak) id<GADBannerViewDelegate> delegate;
@property (nonatomic, strong) GADRequest *loadedRequest;
@property (nonatomic, strong) UIViewController *rootViewController;

- (GADBannerView *)masquerade;
- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;
- (void)simulateUserLeavingApplication;

@end
