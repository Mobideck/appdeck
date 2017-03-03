#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "FakeGADInterstitial.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPGoogleAdMobInterstitialCustomEventSpec)

describe(@"MPGoogleAdMobInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block MPGoogleAdMobInterstitialCustomEvent *event;
    __block FakeGADInterstitial *interstitial;
    __block CLLocation *location;
    __block GADRequest<CedarDouble> *request;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));

        request = nice_fake_for([GADRequest class]);
        fakeProvider.fakeGADInterstitialRequest = request;

        interstitial = [[FakeGADInterstitial alloc] init];
        fakeProvider.fakeGADInterstitial = interstitial.masquerade;

        event = [[MPGoogleAdMobInterstitialCustomEvent alloc] init];
        event.delegate = delegate;

        location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                  altitude:11
                                        horizontalAccuracy:12.3
                                          verticalAccuracy:10
                                                 timestamp:[NSDate date]];
        delegate stub_method("location").and_return(location);

        [event requestInterstitialWithCustomEventInfo:@{@"adUnitID":@"g00g1e"}];
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when asked to fetch an interstitial", ^{
        it(@"should set interstitial's ad unit ID and delegate", ^{
            interstitial.adUnitID should equal(@"g00g1e");
            interstitial.delegate should equal(event);
        });

        it(@"should load the interstitial with a proper request object", ^{
            interstitial.loadedRequest should equal(request);

            request should have_received(@selector(setLocationWithLatitude:longitude:accuracy:)).with((CGFloat)37.1).and_with((CGFloat)21.2).and_with((CGFloat)12.3);
            request should have_received(@selector(setTestDevices:));
        });
    });
});

SPEC_END
