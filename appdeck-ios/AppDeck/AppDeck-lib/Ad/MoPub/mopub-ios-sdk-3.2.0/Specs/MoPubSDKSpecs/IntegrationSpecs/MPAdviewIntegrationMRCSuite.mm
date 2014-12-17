#import "MPAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPAdView (Spec)

- (void)managerDidFailToLoadAd;

@end

@interface MyFakeMPAdViewDelegate : NSObject <MPAdViewDelegate>

@end

@implementation MyFakeMPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return nil;
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    [view release];
}

@end

SPEC_BEGIN(MPAdviewIntegrationMRCSuite)

describe(@"MPAdviewIntegrationMRCSuite", ^{
    context(@"when ad load fails and the delegate releases all references to the banner", ^{
        it(@"should not crash", ^{
            MPAdView *banner = [[MPAdView alloc] initWithAdUnitId:@"custom_event" size:MOPUB_BANNER_SIZE];
            banner.delegate = [[[MyFakeMPAdViewDelegate alloc] init] autorelease];

            [banner loadAd];

            [banner managerDidFailToLoadAd];

            banner should be_instance_of([MPAdView class]);
        });
    });
});

SPEC_END
