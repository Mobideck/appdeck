//
//  FakeMPCoreInstanceProvider.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPCoreInstanceProvider.h"
#import "FakeOperationQueue.h"
#import "FakeMPReachability.h"
#import "FakeMPGeolocationProvider.h"
#import "FakeUIDevice.h"
#import "FakeMPURLResolver.h"

@interface FakeMPCoreInstanceProvider : MPCoreInstanceProvider

#pragma mark - Fetching Ads
@property (nonatomic, strong) FakeMPAdServerCommunicator *lastFakeMPAdServerCommunicator;

#pragma mark - URL Handling
@property (nonatomic, strong) FakeMPURLResolver *fakeMPURLResolver;
@property (nonatomic, strong) MPAdDestinationDisplayAgent *fakeMPAdDestinationDisplayAgent;

#pragma mark - Utilities
@property (nonatomic, strong) FakeUIDevice *fakeUIDevice;
@property (nonatomic, strong) CLLocationManager *fakeLocationManager;
@property (nonatomic, strong) FakeMPAdAlertManager *fakeAdAlertManager;
@property (nonatomic, strong) FakeMPAdAlertGestureRecognizer *fakeAdAlertGestureRecognizer;
@property (nonatomic, strong) FakeOperationQueue *fakeOperationQueue;
@property (nonatomic, strong) FakeMPReachability *fakeMPReachability;
@property (nonatomic, strong) MPGeolocationProvider *fakeGeolocationProvider;
@property (nonatomic, strong) NSDictionary *fakeCarrierInfo;
@property (nonatomic, strong) MPLogEventRecorder *fakeLogEventRecorder;
@property (nonatomic, strong) MPNetworkManager *fakeNetworkManager;

- (NSString *)userAgent;
- (FakeMPAnalyticsTracker *)sharedFakeMPAnalyticsTracker;
- (void)advanceMPTimers:(NSTimeInterval)timeInterval;
- (NSMutableArray *)fakeTimers;
- (FakeMPTimer *)lastFakeMPTimerWithSelector:(SEL)selector;

@end
