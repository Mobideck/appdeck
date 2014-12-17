//
//  FakeMMAdView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MillennialMedia/MMAdView.h>

@interface FakeMMAdView : UIView

@property (nonatomic, copy) NSString *apid;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, copy) MMCompletionBlock completionBlock;
@property (nonatomic, strong) MMRequest *request;

- (MMAdView *)masquerade;
- (NSDictionary *)userInfo;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;

- (void)simulateUserLeavingApplication:(BOOL)modalFirst;

- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;

@end
