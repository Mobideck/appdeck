//
//  FakeMPAdServerCommunicator.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdServerCommunicator.h"

@interface FakeMPAdServerCommunicator : MPAdServerCommunicator

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) NSURL *loadedURL;
@property (nonatomic, assign) BOOL cancelled;

- (void)receiveConfiguration:(MPAdConfiguration *)configuration;
- (void)failWithError:(NSError *)error;

- (void)resetLoadedURL;

@end
