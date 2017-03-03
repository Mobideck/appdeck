#import "MRProperty.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRPropertySpec)

describe(@"MRProperty", ^{
    context(@"MRSupportsProperty", ^{
        __block MRSupportsProperty *property;

        beforeEach(^{
            property = [MRSupportsProperty propertyWithSupportedFeaturesDictionary:
                                @{@"sms": @YES,
                                  @"tel": @YES,
                                  @"calendar": @NO,
                                  @"storePicture": @NO,
                                  @"inlineVideo": @YES}];
        });

        it(@"should serialize properly", ^{
            [property description] should equal(@"supports: {sms: true, tel: true, calendar: false, storePicture: false, inlineVideo: true}");
        });
    });

    context(@"MRViewableProperty", ^{
        __block MRViewableProperty *property;

        beforeEach(^{
            property = [MRViewableProperty propertyWithViewable:YES];
        });

        it(@"should serialize properly", ^{
            [property description] should equal(@"viewable: true");
        });
    });

    context(@"MRPlacementTypeProperty", ^{
        __block MRPlacementTypeProperty *property;

        beforeEach(^{
            property = [MRPlacementTypeProperty propertyWithType:MRAdViewPlacementTypeInterstitial];
        });

        it(@"should serialize properly", ^{
            [property description] should equal(@"placementType: 'interstitial'");
        });
    });

    context(@"MRStateProperty", ^{
        __block MRStateProperty *property;

        it(@"should serialize properly when expanded", ^{
            property = [MRStateProperty propertyWithState:MRAdViewStateExpanded];
            [property description] should equal(@"state: 'expanded'");
        });

        it(@"should serialize properly when resized", ^{
            property = [MRStateProperty propertyWithState:MRAdViewStateResized];
            [property description] should equal(@"state: 'resized'");
        });
    });

    context(@"MRScreenSizeProperty", ^{
        __block MRScreenSizeProperty *property;

        beforeEach(^{
            property = [MRScreenSizeProperty propertyWithSize:CGSizeMake(111, 222)];
        });

        it(@"should serialize properly", ^{
            NSString *target = [NSString stringWithFormat:@"screenSize: {width: %f, height: %f}", 111.0, 222.0];
            [property description] should equal(target);
        });
    });
});

SPEC_END
