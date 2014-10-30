#import "MPGoogleAdMobBannerCustomEvent.h"
#import "FakeGADBannerView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPGoogleAdMobBannerCustomEventSpec)

describe(@"MPGoogleAdMobBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block MPGoogleAdMobBannerCustomEvent *event;
    __block FakeGADBannerView *banner;
    __block CLLocation *location;
    __block GADRequest<CedarDouble> *request;
    __block UIViewController *viewController;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        request = nice_fake_for([GADRequest class]);
        fakeProvider.fakeGADBannerRequest = request;

        banner = [[[FakeGADBannerView alloc] init] autorelease];
        fakeProvider.fakeGADBannerView = banner.masquerade;

        event = [[[MPGoogleAdMobBannerCustomEvent alloc] init] autorelease];
        event.delegate = delegate;

        location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                  altitude:11
                                        horizontalAccuracy:12.3
                                          verticalAccuracy:10
                                                 timestamp:[NSDate date]] autorelease];
        delegate stub_method("location").and_return(location);

        viewController = [[[UIViewController alloc] init] autorelease];
        delegate stub_method("viewControllerForPresentingModalView").and_return(viewController);

        [event requestAdWithSize:CGSizeZero customEventInfo:@{@"adUnitID":@"g00g1e", @"adWidth":@728, @"adHeight":@90}];
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when asked to fetch a banner", ^{
        it(@"should set the banner's ad unit ID and delegate", ^{
            banner.adUnitID should equal(@"g00g1e");
            banner.delegate should equal(event);
            banner.rootViewController should equal(viewController);
        });

        it(@"should load the banner with a proper request object", ^{
            banner.loadedRequest should equal(request);

            request should have_received(@selector(setLocationWithLatitude:longitude:accuracy:)).with(37.1f).and_with(21.2f).and_with(12.3f);
            request should have_received(@selector(setTestDevices:)).with(@[GAD_SIMULATOR_ID]);
        });

        it(@"should fetch a banner of the right size", ^{
            CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 728, 90)) should equal(YES);
        });

        context(@"when the size is not provided", ^{
            it(@"should use the 320x50 size", ^{
                [event requestAdWithSize:CGSizeZero customEventInfo:@{@"adUnitID":@"g00g1e"}];
                CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 320, 50)) should equal(YES);
            });
        });

        context(@"when the size is smaller than the minimum size", ^{
            it(@"should use the minimum size", ^{
                [event requestAdWithSize:CGSizeZero customEventInfo:@{@"adUnitID":@"g00g1e", @"adWidth":@319, @"adHeight":@49}];
                CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 320, 50)) should equal(YES);
            });
        });
    });
});

SPEC_END
