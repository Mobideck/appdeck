//
//  MPAdWebViewAgent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdDestinationDisplayAgentMF.h"

enum {
    MPAdWebViewEventAdDidAppear     = 0,
    MPAdWebViewEventAdDidDisappear  = 1
};
typedef NSUInteger MPAdWebViewEvent;

@protocol MPAdWebViewAgentDelegateMF;

@class MPAdConfigurationMF;
@class MPAdWebViewMF;
@class CLLocation;

@interface MPAdWebViewAgentMF : NSObject <UIWebViewDelegate, MPAdDestinationDisplayAgentDelegateMF>

@property (nonatomic, assign) id customMethodDelegate;
@property (nonatomic, retain) MPAdWebViewMF *view;
@property (nonatomic, assign) id<MPAdWebViewAgentDelegateMF> delegate;

- (id)initWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegateMF>)delegate customMethodDelegate:(id)customMethodDelegate;
- (void)loadConfiguration:(MPAdConfigurationMF *)configuration;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)invokeJavaScriptForEvent:(MPAdWebViewEvent)event;
- (void)forceRedraw;

- (void)stopHandlingRequests;
- (void)continueHandlingRequests;

@end

@class MPAdWebViewMF;

@protocol MPAdWebViewAgentDelegateMF <NSObject>

- (NSString *)adUnitId;
- (CLLocation *)location;
- (UIViewController *)viewControllerForPresentingModalView;
- (void)adDidClose:(MPAdWebViewMF *)ad;
- (void)adDidFinishLoadingAd:(MPAdWebViewMF *)ad;
- (void)adDidFailToLoadAd:(MPAdWebViewMF *)ad;
- (void)adActionWillBegin:(MPAdWebViewMF *)ad;
- (void)adActionWillLeaveApplication:(MPAdWebViewMF *)ad;
- (void)adActionDidFinish:(MPAdWebViewMF *)ad;

@end
