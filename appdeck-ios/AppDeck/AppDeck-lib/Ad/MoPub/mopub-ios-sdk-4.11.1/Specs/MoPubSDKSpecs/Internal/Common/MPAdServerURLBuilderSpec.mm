#import "MPAdServerURLBuilder.h"
#import "MPConstants.h"
#import "MPIdentityProvider.h"
#import "MPGlobal.h"
#import "TWTweetComposeViewController+MPSpecs.h"
#import "FakeMPGeolocationProvider.h"
#import <CoreLocation/CoreLocation.h>
#import "MPAPIEndpoints.h"
#import "MPGlobalSpecHelper.h"
#import "NSDate+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

static BOOL advertisingTrackingEnabled = YES;

@implementation MPAdServerURLBuilder (Spec)

+ (BOOL)advertisingTrackingEnabled
{
    return advertisingTrackingEnabled;
}

@end


SPEC_BEGIN(MPAdServerURLBuilderSpec)

describe(@"MPAdServerURLBuilder", ^{
    __block NSURL *URL;
    __block NSString *expected;

    describe(@"base case", ^{
        it(@"should have the right things", ^{
            URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                               keywords:nil
                                               location:nil
                                                testing:YES];
            expected = [NSString stringWithFormat:@"https://testing.ads.mopub.com/m/ad?v=8&udid=%@&id=guy&nv=%@",
                        [MPIdentityProvider identifier],
                        MP_SDK_VERSION];
            URL.absoluteString should contain(expected);

            URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                               keywords:nil
                                               location:nil
                                                testing:NO];
            expected = [NSString stringWithFormat:@"https://ads.mopub.com/m/ad?v=8&udid=%@&id=guy&nv=%@",
                        [MPIdentityProvider identifier],
                        MP_SDK_VERSION];
            URL.absoluteString should contain(expected);
        });
    });

    it(@"should process keywords", ^{
        [UIPasteboard removePasteboardWithName:@"fb_app_attribution"];
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:@"  something with whitespace,another  "
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&q=something%20with%20whitespace,another");

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should_not contain(@"&q=");

        UIPasteboard *pb = [UIPasteboard pasteboardWithName:@"fb_app_attribution" create:YES];
        pb.string = @"from zuckerberg with love";
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:@"a=1"
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&q=a=1,FBATTRID:from%20zuckerberg%20with%20love");
        [UIPasteboard removePasteboardWithName:@"fb_app_attribution"];
    });

    it(@"should process orientation", ^{
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&o=p");

        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&o=l");
    });

    it(@"should process scale factor", ^{
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&sc=\\d\\.0"
                                                                               options:0
                                                                                 error:NULL];
        [regex numberOfMatchesInString:URL.absoluteString options:0 range:NSMakeRange(0, URL.absoluteString.length)] should equal(1);
    });

    it(@"should process time zone", ^{
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&z=[-+]\\d{4}"
                                                                               options:0
                                                                                 error:NULL];
        [regex numberOfMatchesInString:URL.absoluteString options:0 range:NSMakeRange(0, URL.absoluteString.length)] should equal(1);
    });

    it(@"should process location", ^{
        [NSDate mp_swizzleDateMethod];

        const NSInteger startInterval = 2000;
        const NSInteger endInterval = 3000;
        const NSInteger dateDiffMillis = 1000 * (endInterval - startInterval);
        NSDate * const locationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:startInterval];
        NSDate * const timingNowDate = [NSDate dateWithTimeIntervalSinceReferenceDate:endInterval];

        FakeMPGeolocationProvider *fakeGeolocationProvider = [[FakeMPGeolocationProvider alloc] init];
        fakeCoreProvider.fakeGeolocationProvider = fakeGeolocationProvider;

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should_not contain(@"&ll=");
        URL.absoluteString should_not contain(@"&llsdk=");
        URL.absoluteString should_not contain(@"&llf=");

        [NSDate mp_setFakeDate:locationDate];

        CLLocation *validLocationNoAccuracy = [[CLLocation alloc] initWithLatitude:10.1 longitude:-40.23];

        [NSDate mp_setFakeDate:timingNowDate];

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:validLocationNoAccuracy
                                            testing:YES];
        URL.absoluteString should contain(@"&ll=10.1,-40.23");
        URL.absoluteString should_not contain(@"&lla=");
        URL.absoluteString should_not contain(@"&llsdk=");
        URL.absoluteString should contain(@"&llf=");
        [[MPGlobalSpecHelper dictionaryFromQueryString:URL.query][@"llf"] integerValue] should equal(dateDiffMillis);

        CLLocation *validLocationWithAccuracy = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(10.1, -40.23)
                                                                               altitude:30.4
                                                                     horizontalAccuracy:500.1
                                                                       verticalAccuracy:60
                                                                              timestamp:locationDate];
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:validLocationWithAccuracy
                                            testing:YES];
        URL.absoluteString should contain(@"&ll=10.1,-40.23");
        URL.absoluteString should contain(@"&lla=500.1");
        URL.absoluteString should_not contain(@"&llsdk=");
        URL.absoluteString should contain(@"&llf=");
        [[MPGlobalSpecHelper dictionaryFromQueryString:URL.query][@"llf"] integerValue] should equal(dateDiffMillis);

        NSDate *bogusTimestamp = [NSDate dateWithTimeIntervalSinceReferenceDate:1000];
        NSDate *bogusNowTimestamp = [NSDate dateWithTimeIntervalSinceReferenceDate:9000];
        CLLocation *validLocationWithBogusTimestamp = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(10.1, -40.23)
                                                                                    altitude:30.4
                                                                          horizontalAccuracy:500.1
                                                                            verticalAccuracy:60
                                                                                   timestamp:bogusTimestamp];

        [NSDate mp_setFakeDate:bogusNowTimestamp];

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:validLocationWithBogusTimestamp
                                            testing:YES];
        URL.absoluteString should contain(@"&ll=10.1,-40.23");
        URL.absoluteString should contain(@"&lla=500.1");
        URL.absoluteString should_not contain(@"&llsdk=");
        URL.absoluteString should contain(@"&llf=");
        [[MPGlobalSpecHelper dictionaryFromQueryString:URL.query][@"llf"] integerValue] should equal((8000000));

        CLLocation *invalidLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(10.1, -40.23)
                                                                     altitude:30.4
                                                           horizontalAccuracy:-1
                                                             verticalAccuracy:60
                                                                    timestamp:[NSDate date]];
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:invalidLocation
                                            testing:YES];
        URL.absoluteString should_not contain(@"&ll=");
        URL.absoluteString should_not contain(@"&lla=");
        URL.absoluteString should_not contain(@"&llsdk=");
        URL.absoluteString should_not contain(@"&llf=");

        // When the SDK's own location provider has retrieved location data, the URL builder should
        // use that, rather than the developer-supplied location.
        CLLocation *locationFromProvider = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(42, -42) altitude:10 horizontalAccuracy:60 verticalAccuracy:60 timestamp:locationDate];

        [NSDate mp_setFakeDate:timingNowDate];

        fakeGeolocationProvider.fakeLastKnownLocation = locationFromProvider;

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:validLocationWithAccuracy
                                            testing:YES];
        URL.absoluteString should contain(@"&ll=42,-42");
        URL.absoluteString should contain(@"&lla=60");
        URL.absoluteString should contain(@"&llsdk=1");
        URL.absoluteString should contain(@"&llf=");

        [[MPGlobalSpecHelper dictionaryFromQueryString:URL.query][@"llf"] integerValue] should equal(dateDiffMillis);

        [NSDate mp_swizzleDateMethod];
    });

    it(@"should have mraid", ^{
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&mr=1");
    });

    it(@"should turn advertisingTrackingEnabled into DNT", ^{
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should_not contain(@"&dnt=");

        advertisingTrackingEnabled = NO;
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&dnt=1");

        advertisingTrackingEnabled = YES;
    });

    it(@"should provide connectivity information", ^{
        fakeCoreProvider.fakeMPReachability = [[FakeMPReachability alloc] init];
        FakeMPReachability *fakeMPReachability = fakeCoreProvider.fakeMPReachability;
        fakeMPReachability.hasWifi = YES;

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&ct=2");

        fakeMPReachability.hasWifi = NO;

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&ct=3");
    });

    it(@"should provide application version", ^{
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&av=1.0");
    });

    it(@"should provide carrier info", ^{
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should_not contain(@"&cn=");
        URL.absoluteString should_not contain(@"&iso=");
        URL.absoluteString should_not contain(@"&mnc=");
        URL.absoluteString should_not contain(@"&mcc=");

        NSDictionary *fakeCarrierInfo = @{
            @"carrierName" : @"AT&T",
            @"isoCountryCode" : @"us",
            @"mobileNetworkCode" : @"310",
            @"mobileCountryCode" : @"410"
        };
        fakeCoreProvider.fakeCarrierInfo = fakeCarrierInfo;

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain(@"&cn=AT%26T");
        URL.absoluteString should contain(@"&iso=us");
        URL.absoluteString should contain(@"&mnc=310");
        URL.absoluteString should contain(@"&mcc=410");
    });

    it(@"should provide the device name identifier", ^{
        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];
        URL.absoluteString should contain([NSString stringWithFormat:@"&dn=%@", [[[UIDevice currentDevice] mp_hardwareDeviceName] mp_URLEncodedString]]);
    });

    it(@"should provide the screen size in pixels", ^{
        CGSize screenSize = [MPGlobalSpecHelper screenResolution];
        NSString *screenSizeStr = [NSString stringWithFormat:@"&w=%.0f&h=%.0f", screenSize.width, screenSize.height];

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];

        URL.absoluteString should contain(screenSizeStr);
    });

    it(@"should provide the app's bundle identifier", ^{
        NSString *bundleParam = [NSString stringWithFormat:@"&bundle=%@", [[[NSBundle mainBundle] bundleIdentifier] mp_URLEncodedString]];

        URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                           keywords:nil
                                           location:nil
                                            testing:YES];

        URL.absoluteString should contain(bundleParam);
    });

    describe(@"desired assets", ^{
        it(@"should append desired ad assets as a query parameter", ^{
            NSArray *assets = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
            URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                               keywords:nil
                                               location:nil
                                   versionParameterName:@"nsv"
                                                version:MP_SDK_VERSION
                                                testing:NO
                                          desiredAssets:assets];

            URL.absoluteString should contain(@"&assets=a,b,c");
        });

        it(@"should append not desired ad assets as a query parameter if none are set", ^{
            URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                               keywords:nil
                                               location:nil
                                   versionParameterName:@"nsv"
                                                version:MP_SDK_VERSION
                                                testing:NO
                                          desiredAssets:nil];

            URL.absoluteString should_not contain(@"&assets");
        });
    });

    describe(@"ad placer sequence position", ^{
        it(@"should append desired sequence position to URL", ^{
            NSArray *assets = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
            URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                               keywords:nil
                                               location:nil
                                   versionParameterName:@"nsv"
                                                version:MP_SDK_VERSION
                                                testing:NO
                                          desiredAssets:assets
                                             adSequence:0];

            URL.absoluteString should contain(@"&seq=0");
        });

        it(@"should append not sequence position as a query parameter if none is set", ^{
            URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                               keywords:nil
                                               location:nil
                                   versionParameterName:@"nsv"
                                                version:MP_SDK_VERSION
                                                testing:NO
                                          desiredAssets:nil];

            URL.absoluteString should_not contain(@"&seq");
        });
    });

    context(@"when HTTPS is disabled", ^{
        beforeEach(^{
            [MPAPIEndpoints setUsesHTTPS:NO];
        });

        afterEach(^{
            [MPAPIEndpoints setUsesHTTPS:YES];
        });

        it(@"should return HTTP URLs", ^{
            URL = [MPAdServerURLBuilder URLWithAdUnitID:@"guy"
                                               keywords:nil
                                               location:nil
                                                testing:NO];
            expected = [NSString stringWithFormat:@"http://ads.mopub.com/m/ad?v=8&udid=%@&id=guy&nv=%@",
                        [MPIdentityProvider identifier],
                        MP_SDK_VERSION];
            URL.absoluteString should contain(expected);
        });
    });
});

SPEC_END
