#import "MPHTMLBannerCustomEvent.h"
#import "MPBannerCustomEventDelegate.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPWebView.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPHTMLBannerCustomEventSpec)

describe(@"MPHTMLBannerCustomEvent", ^{
    __block MPHTMLBannerCustomEvent *event;
    __block id<CedarDouble, MPPrivateBannerCustomEventDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeMPWebView *fakeAdWebView;
    __block CGSize containerSize;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPPrivateBannerCustomEventDelegate));
        fakeAdWebView = [[FakeMPWebView alloc] initWithFrame:CGRectZero];
        fakeProvider.fakeMPWebView = fakeAdWebView;

        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
        containerSize = CGSizeMake(300, 250);

        event = [[MPHTMLBannerCustomEvent alloc] init];
        event.delegate = delegate;
    });

    subjectAction(^{
        delegate stub_method("configuration").and_return(configuration);
        [event requestAdWithSize:containerSize customEventInfo:nil];
    });

    context(@"when the configuration has a preferred ad size", ^{
        beforeEach(^{
            configuration.preferredSize = CGSizeMake(320, 50);
        });

        it(@"should create a banner with that size", ^{
            fakeAdWebView.frame.size should equal(configuration.preferredSize);
        });
    });

    context(@"when the configuration does not have a preferred ad size", ^{
        beforeEach(^{
            configuration.preferredSize = CGSizeZero;
        });

        it(@"should create a banner with the container's size (passed into requestAdWithSize:)", ^{
            fakeAdWebView.frame.size should equal(containerSize);
        });
    });

    it(@"should disable automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

//    it(@"should request an ad using the configuration", ^{
//        fakeAdWebView.loadedHTMLString should equal(configuration.adResponseHTMLString);
//    });

    describe(@"forwarding the view controller along", ^{
        it(@"should", ^{
            UIViewController *controller = [[UIViewController alloc] init];
            delegate stub_method("viewControllerForPresentingModalView").and_return(controller);
            event.viewControllerForPresentingModalView should equal(controller);
        });
    });
});

SPEC_END
