//
//  MPSpecHelper.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSpecHelper.h"
#import "MPInterstitialAdController.h"
#import "GSSDKInfo.h"
#import <MMAdSDK/MMSDK.h>
#import "CedarAsync.h"
#import "FakeMPInstanceProvider.h"
#import "FakeMPCoreInstanceProvider.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static BOOL beforeAllDidRun = NO;

FakeMPInstanceProvider *fakeProvider = nil;
FakeMPCoreInstanceProvider *fakeCoreProvider = nil;
NSString *kMPSpecsTestImageURL = @"http://d30x8mtr3hjnzo.cloudfront.net/creatives/a7b528d5c537426da5e42f418cc35e47";

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

NSData *dataFromXMLFileNamed(NSString *name) {
    NSString *file = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
    return [NSData dataWithContentsOfFile:file];
}

@implementation MPSpecHelper

+ (void)beforeEach
{
    if (!beforeAllDidRun) {
        usleep(200000);
        beforeAllDidRun = YES;
        [MMSDK setLogLevel:MMLogLevelError];
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
