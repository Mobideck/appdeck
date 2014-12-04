#import "MPHTMLInterstitialCustomEvent.h"
#import "MPAdConfigurationFactory.h"
#import "MPHTMLInterstitialViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPHTMLInterstitialCustomEventSpec)

describe(@"MPHTMLInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPPrivateInterstitialCustomEventDelegate> delegate;
    __block MPHTMLInterstitialCustomEvent *event;
    __block MPAdConfiguration *configuration;
    __block MPHTMLInterstitialViewController<CedarDouble> *controller;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPPrivateInterstitialCustomEventDelegate));
        controller = nice_fake_for([MPHTMLInterstitialViewController class]);
        fakeProvider.fakeMPHTMLInterstitialViewController = controller;

        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"html"];
        delegate stub_method("configuration").and_return(configuration);

        event = [[[MPHTMLInterstitialCustomEvent alloc] init] autorelease];
        event.delegate = delegate;

        [event requestInterstitialWithCustomEventInfo:nil];
    });

    it(@"should enable automatic metrics tracking", ^{
        //the interstitial does not perform impression tracking itself, so we must have the custom event adapter do it
        //technically it *does* do click handling itself, but does not expose a click event so we never trigger the interstitialCustomEventDidReceiveTapEvent: callback and don't have to worry about double counting clicks.
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when asked to get an ad for a configuration", ^{
        it(@"should tell the interstitial view controller to load the configuration", ^{
            controller should have_received(@selector(loadConfiguration:)).with(configuration);
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *presentingController;

        beforeEach(^{
            presentingController = [[[UIViewController alloc] init] autorelease];
            [event showInterstitialFromRootViewController:presentingController];
        });

        it(@"should tell the interstitial view controller to show the interstitial", ^{
            controller should have_received(@selector(presentInterstitialFromViewController:)).with(presentingController);
        });
    });
});

SPEC_END
