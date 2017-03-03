#import "ChartboostInterstitialCustomEvent.h"
#import "Chartboost+Specs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ChartboostInterstitialCustomEventSpec)

describe(@"ChartboostInterstitialCustomEvent", ^{
    __block ChartboostInterstitialCustomEvent *customEvent;
    __block id<MPInterstitialCustomEventDelegate, CedarDouble>delegate;

    describe(@"requesting with custom event info", ^{
        context(@"when the app ID or app signature is invalid", ^{
            beforeEach(^{
                [Chartboost clearRequestedLocations];
                customEvent = [[ChartboostInterstitialCustomEvent alloc] init];
                delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
                customEvent.delegate = delegate;
                [customEvent requestInterstitialWithCustomEventInfo:nil];
            });

            // Chartboost 5 moved to a static class init method that should only be called once.
            // This precludes us from testing multiple init routes and this case is marked PENDING
            // so that MPChartboostInterstitialIntegrationSuite tests pass
            xit(@"should tell chartboost to load with the app ID or app signature specified in the #defines", ^{
                [Chartboost appId] should equal(@"YOUR_CHARTBOOST_APP_ID");
                [Chartboost appSignature] should equal(@"YOUR_CHARTBOOST_APP_SIGNATURE");
                [Chartboost requestedLocations] should contain(@"Default");
            });
        });
    });
});

SPEC_END
