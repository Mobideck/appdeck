//
//  FakeMPURLResolver.h
//  MoPub
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPURLResolver.h"

@interface FakeMPURLResolver : MPURLResolver

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) MPURLResolverCompletionBlock completion;
@property (nonatomic, readonly) BOOL started;
@property (nonatomic, readonly) BOOL cancelled;

// Sets the `started` property to YES.
- (void)start;

// Calls the completion handler, passing in the given actionInfo and a nil error.
- (void)resolveWithActionInfo:(MPURLActionInfo *)actionInfo;

// Calls the completion handler, passing in the given error and a nil actionInfo.
- (void)resolveWithError:(NSError *)error;

// Sets the `cancelled` property to YES.
- (void)cancel;

@end
