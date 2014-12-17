//
//  FakeMPAdServerCommunicator.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdServerCommunicator.h"

@implementation FakeMPAdServerCommunicator

- (void)loadURL:(NSURL *)URL
{
    self.loading = YES;
    self.loadedURL = URL;
    self.cancelled = NO;
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
