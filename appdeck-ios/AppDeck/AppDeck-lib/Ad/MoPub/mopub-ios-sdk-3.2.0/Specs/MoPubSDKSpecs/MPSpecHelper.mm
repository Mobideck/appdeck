//
//  MPSpecHelper.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSpecHelper.h"
#import "MPInterstitialAdController.h"
#import "GSSDKInfo.h"
#import <MillennialMedia/MMSDK.h>
#import "CedarAsync.h"
#import "FakeMPInstanceProvider.h"
#import "FakeMPCoreInstanceProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static BOOL beforeAllDidRun = NO;

FakeMPInstanceProvider *fakeProvider = nil;
FakeMPCoreInstanceProvider *fakeCoreProvider = nil;

void verify_fake_received_selectors_async(id<CedarDouble> fake, NSArray *selectors)
{
    in_time(fake.sent_messages.count) should equal(selectors.count);

    for (int i = 0; i < [[fake sent_messages] count]; i++) {
        [[fake sent_messages][i] selector] should equal(NSSelectorFromString(selectors[i]));
    }

    [fake reset_sent_messages];
}

void verify_fake_received_selectors(id<CedarDouble> fake, NSArray *selectors)
{
    fake.sent_messages.count should equal(selectors.count);

    for (int i = 0; i < [[fake sent_messages] count]; i++) {
        [[fake sent_messages][i] selector] should equal(NSSelectorFromString(selectors[i]));
    }

    [fake reset_sent_messages];
}

void log_sent_messages(id<CedarDouble> fake)
{
    for (NSInvocation *invocation in fake.sent_messages) {
        NSLog(@"================> %@", NSStringFromSelector(invocation.selector));
    }
}

@implementation MPSpecHelper

+ (void)beforeEach
{
    if (!beforeAllDidRun) {
        usleep(200000);
        beforeAllDidRun = YES;
        [MMSDK setLogLevel:MMLOG_LEVEL_OFF];
        [GSSDKInfo setGUID:@"GreystripeGUID"]; //silences greystripe complaints further down the line
    }

    fakeProvider = [[FakeMPInstanceProvider alloc] init];
    fakeCoreProvider = [[FakeMPCoreInstanceProvider alloc] init];
}

+ (void)afterEach
{
    [[MPInterstitialAdController sharedInterstitialAdControllers] removeAllObjects];
}

@end
