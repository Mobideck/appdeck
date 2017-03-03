#import "MoPub.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MoPubSpec)

describe(@"MoPub", ^{
    __block MoPub *subject;
    __block MPGeolocationProvider *fakeGeolocationProvider;

    beforeEach(^{
        subject = [[MoPub alloc] init];
    });

    describe(@"locationUpdatesEnabled", ^{
        beforeEach(^{
            fakeGeolocationProvider = nice_fake_for([MPGeolocationProvider class]);
            fakeCoreProvider.fakeGeolocationProvider = fakeGeolocationProvider;
        });

        context(@"when set to YES", ^{
            it(@"should tell the geolocation provider", ^{
                subject.locationUpdatesEnabled = YES;
                fakeGeolocationProvider should have_received(@selector(setLocationUpdatesEnabled:)).with(YES);
            });
        });

        context(@"when set to NO", ^{
            it(@"should tell the geolocation provider", ^{
                subject.locationUpdatesEnabled = NO;
                fakeGeolocationProvider should have_received(@selector(setLocationUpdatesEnabled:)).with(NO);
            });
        });
    });

    // Mediation settings tests are spread across MPRewardedAdManagerSpec and MPRewardedVideoSpec.
});

SPEC_END
