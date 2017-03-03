//
//  FakeMPURLResolver.m
//  MoPub
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "FakeMPURLResolver.h"

@interface FakeMPURLResolver ()

@property (nonatomic, readwrite) BOOL started;
@property (nonatomic, readwrite) BOOL cancelled;

@end

@implementation FakeMPURLResolver

- (void)start
{
    self.started = YES;
}

- (void)resolveWithActionInfo:(MPURLActionInfo *)actionInfo
{
    self.completion(actionInfo, nil);
}

- (void)resolveWithError:(NSError *)error
{
    self.completion(nil, error);
}

- (void)cancel
{
    self.cancelled = YES;
}

@end
