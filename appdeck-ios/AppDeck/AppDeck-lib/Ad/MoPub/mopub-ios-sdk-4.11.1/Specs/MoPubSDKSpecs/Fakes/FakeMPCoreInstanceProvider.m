//
//  FakeMPCoreInstanceProvider.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeMPCoreInstanceProvider.h"
#import "MPGeolocationProvider.h"
#import "FakeMPURLResolver.h"

@interface FakeMPCoreInstanceProvider ()

@property (nonatomic, strong) NSMutableArray *fakeTimers;

@end

@implementation FakeMPCoreInstanceProvider

- (id)init
{
    self = [super init];
    if (self) {
        self.fakeTimers = [NSMutableArray array];
    }
    return self;
}

- (id)returnFake:(id)fake orCall:(IDReturningBlock)block
{
    if (fake) {
        return fake;
    } else {
        return block();
    }
}

#pragma mark - Fetching Ads

- (NSString *)userAgent
{
    return @"FAKE_TEST_USER_AGENT_STRING";
}

- (MPAdServerCommunicator *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate
{
    self.lastFakeMPAdServerCommunicator = [[FakeMPAdServerCommunicator alloc] initWithDelegate:delegate];
    return self.lastFakeMPAdServerCommunicator;
}

#pragma mark - URL Handling

- (MPURLResolver *)buildMPURLResolverWithURL:(NSURL *)URL completion:(MPURLResolverCompletionBlock)completion
{
    FakeMPURLResolver *fakeResolver = self.fakeMPURLResolver;
    fakeResolver.URL = URL;
    fakeResolver.completion = completion;
    return [self returnFake:fakeResolver
                     orCall:^{
                         return [super buildMPURLResolverWithURL:URL completion:completion];
                     }];
}

- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate
{
    return [self returnFake:self.fakeMPAdDestinationDisplayAgent
                     orCall:^{
                         return [super buildMPAdDestinationDisplayAgentWithDelegate:delegate];
                     }];
}

#pragma mark - Utilities

- (UIDevice *)sharedCurrentDevice
{
    return [self returnFake:self.fakeUIDevice
                     orCall:^id{
                         return [super sharedCurrentDevice];
                     }];
}

- (MPGeolocationProvider *)sharedMPGeolocationProvider
{
    return [self returnFake:self.fakeGeolocationProvider
                     orCall:^id{
                         return [super sharedMPGeolocationProvider];
                     }];
}

- (CLLocationManager *)buildCLLocationManager
{
    return [self returnFake:self.fakeLocationManager
                     orCall:^{
                         return [super buildCLLocationManager];
                     }];
}

- (MPAdAlertManager *)buildMPAdAlertManagerWithDelegate:(id<MPAdAlertManagerDelegate>)delegate
{
    if (self.fakeAdAlertManager != nil) {
        self.fakeAdAlertManager.delegate = delegate;
        return self.fakeAdAlertManager;
    } else {
        return [super buildMPAdAlertManagerWithDelegate:delegate];
    }
}

- (MPAdAlertGestureRecognizer *)buildMPAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action
{
    if (self.fakeAdAlertGestureRecognizer != nil) {
        [self.fakeAdAlertGestureRecognizer addTarget:target action:action];
        return self.fakeAdAlertGestureRecognizer;
    } else {
        return [super buildMPAdAlertGestureRecognizerWithTarget:target action:action];
    }
}

- (NSOperationQueue *)sharedOperationQueue
{
    return [self returnFake:self.fakeOperationQueue
                     orCall:^{
                         return [super sharedOperationQueue];
                     }];
}

- (MPReachability *)sharedMPReachability
{
    return [self returnFake:self.fakeMPReachability
                     orCall:^id{
                         return [super sharedMPReachability];
                     }];
}

- (NSDictionary *)sharedCarrierInfo
{
    return [self returnFake:self.fakeCarrierInfo
                     orCall:^id{
                         return [super sharedCarrierInfo];
                     }];
}

- (MPLogEventRecorder *)sharedLogEventRecorder
{
    return [self returnFake:self.fakeLogEventRecorder
                     orCall:^{
                         return [super sharedLogEventRecorder];
                     }];
}

- (MPNetworkManager *)sharedNetworkManager
{
    return [self returnFake:self.fakeNetworkManager
                     orCall:^{
                         return [super sharedNetworkManager];
                     }];
}

- (MPAnalyticsTracker *)sharedMPAnalyticsTracker
{
    return [self sharedFakeMPAnalyticsTracker];
}

- (FakeMPAnalyticsTracker *)sharedFakeMPAnalyticsTracker
{
    return [self singletonForClass:[MPAnalyticsTracker class] provider:^id{
        return [[FakeMPAnalyticsTracker alloc] init];
    }];
}

- (MPTimer *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats
{
    MPTimer *fakeTimer = [FakeMPTimer timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
    [self.fakeTimers addObject:fakeTimer];
    return fakeTimer;
}

- (void)advanceMPTimers:(NSTimeInterval)timeInterval
{
    NSTimeInterval delta = 1;
    NSTimeInterval advanceBy = 0;
    while (timeInterval > 0) {
        advanceBy = delta < timeInterval ? delta : timeInterval;
        for (FakeMPTimer *timer in [self.fakeTimers copy]) {
            [timer advanceTime:advanceBy];
        }
        timeInterval -= advanceBy;
    }
}

- (FakeMPTimer *)lastFakeMPTimerWithSelector:(SEL)selector
{
    NSUInteger numTimers = [self.fakeTimers count];
    for (NSInteger i = numTimers - 1; i >= 0; i--) {
        if ([self.fakeTimers[i] selector] == selector) {
            return self.fakeTimers[i];
        }
    }

    return nil;
}





@end
