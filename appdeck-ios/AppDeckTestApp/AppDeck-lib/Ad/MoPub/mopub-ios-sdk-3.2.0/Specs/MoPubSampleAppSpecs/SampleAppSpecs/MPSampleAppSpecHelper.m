//
//  MPSampleAppSpecHelper.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppSpecHelper.h"

static BOOL didNap = NO;

FakeMPSampleAppInstanceProvider *fakeProvider;

@implementation MPSampleAppSpecHelper

+ (void)beforeEach
{
    if (!didNap) {
        usleep(200000);
        didNap = YES;
    }

    fakeProvider = [[[FakeMPSampleAppInstanceProvider alloc] init] autorelease];
}
@end
