//
//  FakeMPCoreInstanceProvider.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPCoreInstanceProvider.h"
#import "FakeOperationQueue.h"

@interface FakeMPCoreInstanceProvider : MPCoreInstanceProvider

#pragma mark - Fetching Ads
@property (nonatomic, strong) FakeMPAdServerCommunicator *lastFakeMPAdServerCommunicator;

#pragma mark - URL Handling
@property (nonatomic, strong) MPURLResolver *fakeMPURLResolver;
@property (nonatomic, strong) MPAdDestinationDisplayAgent *fakeMPAdDestinationDisplayAgent;

#pragma mark - Utilities
@property (nonatomic, strong) FakeMPAdAlertManager *fakeAdAlertManager;
@property (nonatomic, strong) FakeMPAdAlertGestureRecognizer *fakeAdAlertGestureRecognizer;
@property (nonatomic, strong) FakeOperationQueue *fakeOperationQueue;
@property (nonatomic, strong) FakeMPReachability *fakeMPReachability;
@property (nonatomic, strong) NSDictionary *fakeCarrierInfo;

- (NSString *)userAgent;
- (FakeMPAnalyticsTracker *)sharedFakeMPAnalyticsTracker;
- (void)advanceMPTimers:(NSTimeInterval)timeInterval;
- (NSMutableArray *)fakeTimers;
- (FakeMPTimer *)lastFakeMPTimerWithSelector:(SEL)selector;

@end
