//
//  FakeMPCoreInstanceProvider.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPCoreInstanceProvider.h"

@interface FakeMPCoreInstanceProvider : MPCoreInstanceProvider

#pragma mark - Fetching Ads
@property (nonatomic, assign) FakeMPAdServerCommunicator *lastFakeMPAdServerCommunicator;

#pragma mark - URL Handling
@property (nonatomic, assign) MPURLResolver *fakeMPURLResolver;
@property (nonatomic, assign) MPAdDestinationDisplayAgent *fakeMPAdDestinationDisplayAgent;

#pragma mark - Utilities
@property (nonatomic, assign) FakeMPAdAlertManager *fakeAdAlertManager;
@property (nonatomic, assign) FakeMPAdAlertGestureRecognizer *fakeAdAlertGestureRecognizer;
@property (nonatomic, assign) FakeOperationQueue *fakeOperationQueue;
@property (nonatomic, assign) FakeMPReachability *fakeMPReachability;
@property (nonatomic, assign) NSDictionary *fakeCarrierInfo;

- (NSString *)userAgent;
- (FakeMPAnalyticsTracker *)sharedFakeMPAnalyticsTracker;
- (void)advanceMPTimers:(NSTimeInterval)timeInterval;
- (NSMutableArray *)fakeTimers;
- (FakeMPTimer *)lastFakeMPTimerWithSelector:(SEL)selector;

@end
