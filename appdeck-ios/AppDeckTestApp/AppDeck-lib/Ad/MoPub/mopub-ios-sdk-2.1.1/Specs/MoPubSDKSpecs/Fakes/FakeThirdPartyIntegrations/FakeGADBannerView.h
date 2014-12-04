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

@property (nonatomic, assign) NSString *adUnitID;
@property (nonatomic, assign) id<GADBannerViewDelegate> delegate;
@property (nonatomic, assign) GADRequest *loadedRequest;
@property (nonatomic, assign) UIViewController *rootViewController;

- (GADBannerView *)masquerade;
- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;
- (void)simulateUserLeavingApplication;

@end
