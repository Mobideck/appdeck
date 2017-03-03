#import "MPLogEvent+NativeVideo.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPLogEvent_NativeVideoSpec)

describe(@"MPLogEvent_NativeVideo", ^{
    __block MPLogEvent *nativeVideoLogEvent;
    __block CGSize adSize;
    __block NSURL *failoverURL;
    __block MPAdConfiguration *config;
    __block MPAdConfigurationLogEventProperties *requestDependentProperties;

    beforeEach(^{
        adSize = CGSizeMake(320.0, 50.0);
        config = [[MPAdConfiguration alloc] init];
        config.headerAdType = @"test_ad_type";
        config.adType = MPAdTypeBanner;
        config.creativeId = @"abcd_creative_id";
        config.networkType = @"mopub_network";
        config.preferredSize = adSize;
        failoverURL = [NSURL URLWithString:@"http://ads.mopub.com/m/ad?v=8&udid=ifa:01C61C79-9EA0-458C-BFBB-C58F084225A7&id=1aa442709c9f11e281c11231392559e4&nv=3.5.0&o=p&sc=2.0&z=-0700&mr=1&ct=2&av=1.0&dn=x86_64&exclude=1ad153aa9c9f11e281c11231392559e4&request_id=0753417627e0416fac09151f4408bcdc&fail=1"];
        config.failoverURL = failoverURL;
        requestDependentProperties = [[MPAdConfigurationLogEventProperties alloc] initWithConfiguration:config];
    });

    describe(@"Initialization", ^{
        it(@"creates a log event with request dependent properties filled in", ^{
            nativeVideoLogEvent = [[MPLogEvent alloc] initWithLogEventProperties:requestDependentProperties nativeVideoEventType:MPNativeVideoEventTypeDownloadStart];
            nativeVideoLogEvent.adType should equal(@"test_ad_type");
            nativeVideoLogEvent.adCreativeId should equal(@"abcd_creative_id");
            nativeVideoLogEvent.adNetworkType should equal(@"mopub_network");
            nativeVideoLogEvent.adSize should equal(adSize);
            nativeVideoLogEvent.requestId should equal(@"0753417627e0416fac09151f4408bcdc");
            nativeVideoLogEvent.adUnitId should equal(@"1aa442709c9f11e281c11231392559e4");
        });

        it(@"with a type MPNativeVideoEventTypeDownloadStart should set event name appropriately", ^{
            nativeVideoLogEvent = [[MPLogEvent alloc] initWithLogEventProperties:requestDependentProperties nativeVideoEventType:MPNativeVideoEventTypeDownloadStart];
            nativeVideoLogEvent.eventName should equal(@"download_start");
            nativeVideoLogEvent.eventCategory should equal(@"native_video");
        });

        it(@"with a type MPNativeVideoEventTypeVideoReady should set event name appropriately", ^{
            nativeVideoLogEvent = [[MPLogEvent alloc] initWithLogEventProperties:requestDependentProperties nativeVideoEventType:MPNativeVideoEventTypeVideoReady];
            nativeVideoLogEvent.eventName should equal(@"download_video_ready");
            nativeVideoLogEvent.eventCategory should equal(@"native_video");
        });

        it(@"with a type MPNativeVideoEventTypeBuffering should set event name appropriately", ^{
            nativeVideoLogEvent = [[MPLogEvent alloc] initWithLogEventProperties:requestDependentProperties nativeVideoEventType:MPNativeVideoEventTypeBuffering];
            nativeVideoLogEvent.eventName should equal(@"download_buffering");
            nativeVideoLogEvent.eventCategory should equal(@"native_video");
        });

        it(@"with a type MPNativeVideoEventTypeErrorDuringPlayback should set event name appropriately", ^{
            nativeVideoLogEvent = [[MPLogEvent alloc] initWithLogEventProperties:requestDependentProperties nativeVideoEventType:MPNativeVideoEventTypeErrorDuringPlayback];
            nativeVideoLogEvent.eventName should equal(@"error_during_playback");
            nativeVideoLogEvent.eventCategory should equal(@"native_video");
        });

        it(@"with a type MPNativeVideoEventTypeErrorFailedToPlay should set event name appropriately", ^{
            nativeVideoLogEvent = [[MPLogEvent alloc] initWithLogEventProperties:requestDependentProperties nativeVideoEventType:MPNativeVideoEventTypeErrorFailedToPlay];
            nativeVideoLogEvent.eventName should equal(@"error_failed_to_play");
            nativeVideoLogEvent.eventCategory should equal(@"native_video");
        });
    });
});

SPEC_END
