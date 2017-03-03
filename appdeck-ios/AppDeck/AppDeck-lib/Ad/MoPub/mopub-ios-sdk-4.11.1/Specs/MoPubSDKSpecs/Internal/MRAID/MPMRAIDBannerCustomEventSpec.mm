#import "MPMRAIDBannerCustomEvent.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMRController.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMRAIDBannerCustomEventSpec)

describe(@"MPMRAIDBannerCustomEvent", ^{
    __block MPMRAIDBannerCustomEvent *event;
    __block id<CedarDouble, MPPrivateBannerCustomEventDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeMRController *fakeMRController;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPPrivateBannerCustomEventDelegate));

        fakeMRController = [[FakeMRController alloc]  initWithAdViewFrame:CGRectMake(0, 0, 300, 250)
                                                      adPlacementType:MRAdViewPlacementTypeInline];
        fakeProvider.fakeMRController = fakeMRController;

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
        fakeMRController.loadedHTMLString should equal(configuration.adResponseHTMLString);
    });

    it(@"should set itself as the banner delegate", ^{
        fakeMRController.delegate should equal(event);
    });
});

SPEC_END
