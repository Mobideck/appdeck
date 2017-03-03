//
//  FakeMPAdServerCommunicator.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdServerCommunicator.h"
#import "MPLogEvent.h"

@interface FakeMPAdServerCommunicator ()

@property (nonatomic) MPLogEvent *adRequestLatencyEvent;

@end

@implementation FakeMPAdServerCommunicator

@dynamic adRequestLatencyEvent;
@synthesize loading;

- (void)loadURL:(NSURL *)URL
{
    self.loading = YES;
    self.loadedURL = URL;
    self.cancelled = NO;
    // Start tracking how long it takes to successfully or unsuccessfully retrieve an ad.
    self.adRequestLatencyEvent = [[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest];
    self.adRequestLatencyEvent.requestURI = URL.absoluteString;
}

- (void)cancel
{
    self.loading = NO;
    self.cancelled = YES;
}

- (void)receiveConfiguration:(MPAdConfiguration *)configuration
{
    if (self.loadedURL && !self.cancelled) {
        self.loading = NO;
        self.loadedURL = nil;
        [self.delegate communicatorDidReceiveAdConfiguration:configuration];
    }
}

- (void)failWithError:(NSError *)error
{
    if (self.loadedURL && !self.cancelled) {
        self.loading = NO;
        self.loadedURL = nil;
        [self.delegate communicatorDidFailWithError:error];
    }
}

- (void)resetLoadedURL
{
    self.loadedURL = nil;
}

@end
