#import "InMobiInterstitialCustomEvent.h"
#import "FakeIMAdInterstitial.h"
#import "InMobi+Specs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiInterstitialCustomEventSpec)

describe(@"InMobiInterstitialCustomEvent", ^{
    __block InMobiInterstitialCustomEvent *event;
    __block FakeIMAdInterstitial *interstitial;
    __block CLLocation *location;
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;

    beforeEach(^{
        [InMobi initialize:@"YOUR_INMOBI_APP_ID"];

        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));

        event = [[InMobiInterstitialCustomEvent alloc] init];
        event.delegate = delegate;
        interstitial = [[FakeIMAdInterstitial alloc] init];
        fakeProvider.fakeIMAdInterstitial = interstitial;

        location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                  altitude:11
                                        horizontalAccuracy:12.3
                                          verticalAccuracy:10
                                                 timestamp:[NSDate date]];
        delegate stub_method("location").and_return(location);
    });

    context(@"when requesting an interstitial", ^{
        beforeEach(^{
            [InMobi mp_swizzleSetLocationMethod];
            [event requestInterstitialWithCustomEventInfo:nil];
        });

        it(@"should load with a proper params dictionary", ^{
            NSDictionary *params = interstitial.additionaParameters;
            NSString *tpValue = [params objectForKey:@"tp"];
            tpValue should equal(@"c_mopub");
        });

        it(@"should set the location using the InMobi class method", ^{
            [InMobi mp_getLatitude] should equal((CGFloat)37.1);
            [InMobi mp_getLongitude] should equal((CGFloat)21.2);
            [InMobi mp_getAccuracy] should equal((CGFloat)12.3);
        });
    });
});

SPEC_END
