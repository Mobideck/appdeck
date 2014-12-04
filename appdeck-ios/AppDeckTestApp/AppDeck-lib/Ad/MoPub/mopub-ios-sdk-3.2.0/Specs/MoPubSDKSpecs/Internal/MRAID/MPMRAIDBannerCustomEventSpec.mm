#import "MPMRAIDBannerCustomEvent.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMRAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMRAIDBannerCustomEventSpec)

describe(@"MPMRAIDBannerCustomEvent", ^{
    __block MPMRAIDBannerCustomEvent *event;
    __block id<CedarDouble, MPPrivateBannerCustomEventDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeMRAdView *fakeMRAdView;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPPrivateBannerCustomEventDelegate));

        fakeMRAdView = [[FakeMRAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            allowsExpansion:YES
                                           closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                              placementType:MRAdViewPlacementTypeInline];
        fakeProvider.fakeMRAdView = fakeMRAdView;

        event = [[MPMRAIDBannerCustomEvent alloc] init];
        event.delegate = delegate;

        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:kAdTypeMraid];

        delegate stub_method("configuration").and_return(configuration);
        [event requestAdWithSize:CGSizeMake(300, 250) customEventInfo:nil];
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    it(@"should request an ad using the configuration", ^{
        fakeMRAdView.loadedHTMLString should equal(configuration.adResponseHTMLString);
    });

    it(@"should set itself as the banner delegate", ^{
        fakeMRAdView.delegate should equal(event);
    });

    context(@"when the event is told to rotate", ^{
        beforeEach(^{
            fakeMRAdView.currentInterfaceOrientation = UIInterfaceOrientationPortrait;
            [event rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
        });

        it(@"should also tell the banner", ^{
            fakeMRAdView.currentInterfaceOrientation should equal(UIInterfaceOrientationLandscapeLeft);
        });
    });
});

SPEC_END
