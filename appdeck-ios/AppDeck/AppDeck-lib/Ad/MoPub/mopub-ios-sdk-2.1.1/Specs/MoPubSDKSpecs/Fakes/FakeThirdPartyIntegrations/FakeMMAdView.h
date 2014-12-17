//
//  FakeMMAdView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MillennialMedia/MMAdView.h>

@interface FakeMMAdView : UIView

@property (nonatomic, assign) NSString *apid;
@property (nonatomic, assign) UIViewController *rootViewController;
@property (nonatomic, copy) MMCompletionBlock completionBlock;
@property (nonatomic, assign) MMRequest *request;

- (MMAdView *)masquerade;
- (NSDictionary *)userInfo;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;

- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;

@end
