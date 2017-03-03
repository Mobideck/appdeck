#import "MPLogEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPLogEvent (Specs)

@property (nonatomic, readwrite) NSDate *timestamp;
@property (nonatomic, readwrite) NSUInteger performanceDurationMs;

- (NSString *)adTypeAsString;

@end

SPEC_BEGIN(MPLogEventSpec)

describe(@"MPLogEvent", ^{
    __block MPLogEvent *event;
    __block NSDate *timestamp;

    beforeEach(^{
        timestamp = [NSDate dateWithTimeIntervalSince1970:1425078783];

        FakeMPReachability *fakeReachability = [[FakeMPReachability alloc] init];
        fakeReachability.hasCellular = YES;
        fakeCoreProvider.fakeMPReachability = fakeReachability;

        CLLocation *testLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(42, -42)
                                                             altitude:10
                                                   horizontalAccuracy:60
                                                     verticalAccuracy:60
                                                            timestamp:[NSDate date]];
        FakeMPGeolocationProvider *geoLocationProvider = [[FakeMPGeolocationProvider alloc] init];
        geoLocationProvider.fakeLastKnownLocation = testLocation;
        fakeCoreProvider.fakeGeolocationProvider = geoLocationProvider;

        #pragma unused (testLocation)

        fakeCoreProvider.fakeCarrierInfo = @{
                                             @"carrierName": @"AT&T",
                                             @"mobileCountryCode": @"001",
                                             @"mobileNetworkCode": @"666",
                                             };


        event = [[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest];
        [event setEventName:@"test"];
        [event setEventCategory:@"mopub_test"];
        [event setAdUnitId:@"abcd-efgh"];
        [event setAdCreativeId:@"foo-bar-baz"];
        [event setAdType:@"html"];
        [event setAdNetworkType:@"testnetwork"];
        [event setAdSize:CGSizeMake(123, 678)];
        [event setAppName:@"MoPub Testing"];
        [event setAppStoreId:@"1234App_Store"];
        [event setAppBundleId:@"com.mopub.testing"];
        [event setAppVersion:@"0.0.1"];
        [event setPerformanceDurationMs:999];
        [event setRequestId:@"mopub-request-id"];
        [event setRequestStatusCode:200];
        [event setRequestURI:@"http://mopub/ads"];
        [event setRequestRetries:0];

        // override readonly properties
        [event setTimestamp:timestamp];
    });

    describe(@"initialization", ^{
        describe(@"setting known parameters on init", ^{
            it(@"should set the scribe category", ^{
                [event scribeCategory] should equal(MPExchangeClientEventCategory);
            });

            it(@"should set the sdk version", ^{
                [event sdkVersion] should equal(MP_SDK_VERSION);
            });

            it(@"should set the model of the device", ^{
                [event deviceModel] should equal([UIDevice currentDevice].model);
            });

            it(@"should set the os version of the device", ^{
                [event deviceOSVersion] should equal([UIDevice currentDevice].systemVersion);
            });

            it(@"should set the screen width and height", ^{
                [event deviceSize].width should equal([[UIScreen mainScreen] bounds].size.width);
                [event deviceSize].height should equal([[UIScreen mainScreen] bounds].size.height);
            });

            it(@"should set the location and location accuracy of the device", ^{
                [event geoLat] should equal(42);
                [event geoLon] should equal(-42);
                [event geoAccuracy] should equal(60);
            });

            context(@"when the device is on wifi", ^{
                beforeEach(^{
                    FakeMPReachability *fakeReachability = [[FakeMPReachability alloc] init];
                    fakeReachability.hasWifi = YES;
                    fakeReachability.hasCellular = NO;
                    fakeCoreProvider.fakeMPReachability = fakeReachability;
                    event = [[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest];
                });

                it(@"should set the network type to wifi", ^{
                    [event networkType] should equal(MPLogEventNetworkTypeWifi);
                });
                it(@"shouldn't set any other network/carrier properties", ^{
                    [event networkOperatorName] should be_nil;
                    [event networkSIMOperatorName] should be_nil;
                    [event networkSIMCode] should be_nil;
                    [event networkOperatorCode] should be_nil;
                    [event networkISOCountryCode] should be_nil;
                    [event networkSimISOCountryCode] should be_nil;
                });
            });

            context(@"when the device is using cellular", ^{
                it(@"should set the network type to mobile", ^{
                    [event networkType] should equal(MPLogEventNetworkTypeMobile);
                });
                it(@"should set the network operator name", ^{
                    [event networkOperatorName] should equal(@"AT&T");
                    [event networkSIMOperatorName] should equal(@"AT&T");
                });
                it(@"should set the operator code", ^{
                    [event networkOperatorCode] should equal(@"001666");
                    [event networkSIMCode] should equal(@"001666");
                });
                it(@"should set the country code", ^{
                    NSString *code = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
                    [event networkISOCountryCode] should equal(code);
                    [event networkSimISOCountryCode] should equal(code);
                });
            });

            context(@"when the network connection isn't available", ^{
                beforeEach(^{
                    FakeMPReachability *fakeReachability = [[FakeMPReachability alloc] init];
                    fakeReachability.hasWifi = NO;
                    fakeReachability.hasCellular = NO;
                    fakeCoreProvider.fakeMPReachability = fakeReachability;
                    event = [[MPLogEvent alloc] init];
                });

                it(@"should set the network type to unknown", ^{
                    [event networkType] should equal(MPLogEventNetworkTypeUnknown);
                });
                it(@"shouldn't set any other network/carrier properties", ^{
                    [event networkOperatorName] should be_nil;
                    [event networkSIMOperatorName] should be_nil;
                    [event networkSIMCode] should be_nil;
                    [event networkOperatorCode] should be_nil;
                    [event networkISOCountryCode] should be_nil;
                    [event networkSimISOCountryCode] should be_nil;
                });
            });
        });
    });

    it(@"should convert the timestamp to an epoch integer with -timeAsEpoch", ^{
        [event timestampAsEpoch] should equal(1425078783);
    });

    describe(@"-asDictionary", ^{
        __block NSDictionary *dict;

        beforeEach(^{
            dict = [event asDictionary];
        });

        it(@"should have the correct number of keys when the base properties are set", ^{
            [dict count] should equal(38);
        });

        it(@"shouldn't include a property if its value is nil", ^{
            [event setRequestId:nil];
            dict = [event asDictionary];
            [dict count] should equal(37);
            [dict objectForKey:@"req_id"] should be_nil;
        });
    });

    describe(@"setting request properties with an adserver configuration object", ^{
        __block CGSize adSize;
        __block NSURL *failoverURL;
        __block MPAdConfiguration *config;
        beforeEach(^{
            adSize = CGSizeMake(320.0, 50.0);
            config = [[MPAdConfiguration alloc] init];
            config.headerAdType = @"test_ad_type";
            config.adType = MPAdTypeBanner;
            config.creativeId = @"abcd_creative_id";
            config.networkType = @"mopub_network";
            config.preferredSize = adSize;
            failoverURL =[NSURL URLWithString:@"http://ads.mopub.com/m/ad?v=8&udid=ifa:01C61C79-9EA0-458C-BFBB-C58F084225A7&id=1aa442709c9f11e281c11231392559e4&nv=3.5.0&o=p&sc=2.0&z=-0700&mr=1&ct=2&av=1.0&dn=x86_64&exclude=1ad153aa9c9f11e281c11231392559e4&request_id=0753417627e0416fac09151f4408bcdc&fail=1"];
            config.failoverURL = failoverURL;
        });

        describe(@"Setting request properties with MPAdConfigurationLogEventProperties", ^{
            __block MPAdConfigurationLogEventProperties *logEventProperties;

            beforeEach(^{
                logEventProperties = [[MPAdConfigurationLogEventProperties alloc] initWithConfiguration:config];
            });

            it(@"should set the properties on the MPLogEvent", ^{
                [event setLogEventProperties:logEventProperties];
                event.adType should equal(@"test_ad_type");
                event.adCreativeId should equal(@"abcd_creative_id");
                event.adNetworkType should equal(@"mopub_network");
                event.adSize should equal(adSize);
                event.requestId should equal(@"0753417627e0416fac09151f4408bcdc");
                event.adUnitId should equal(@"1aa442709c9f11e281c11231392559e4");
            });

        });
    });
});

SPEC_END
