#import "MPMRAIDInterstitialCustomEvent.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMRAIDInterstitialCustomEventSpec)

describe(@"MPMRAIDInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPPrivateInterstitialCustomEventDelegate> delegate;
    __block MPMRAIDInterstitialCustomEvent *event;
    __block MPAdConfiguration *configuration;
    __block MPMRAIDInterstitialViewController<CedarDouble> *controller;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPPrivateInterstitialCustomEventDelegate));
        controller = nice_fake_for([MPMRAIDInterstitialViewController class]);
        fakeProvider.fakeMPMRAIDInterstitialViewController = controller;

        configuration = [MPAdConfigurationFactory defaultMRAIDInterstitialConfiguration];
        delegate stub_method("configuration").and_return(configuration);

        event = [[[MPMRAIDInterstitialCustomEvent alloc] init] autorelease];
        event.delegate = delegate;

        [event requestInterstitialWithCustomEventInfo:nil];
    });

    it(@"should enable automatic metrics tracking", ^{
        //the interstitial does not perform impression tracking itself, so we must have the custom event adapter do it
        //technically it *does* do click handling itself, but does not expose a click event so we never trigger the interstitialCustomEventDidReceiveTapEvent: callback and don't have to worry about double counting clicks.
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when asked to get an ad for a configuration", ^{
        it(@"should set the close button style", ^{
            controller should have_received(@selector(setCloseButtonStyle:)).with(MPInterstitialCloseButtonStyleAdControlled);
        });

        it(@"should tell the interstitial view controller to start loading", ^{
            controller should have_received(@selector(startLoading));
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

    describe(@"MPMRAIDInterstitialViewControllerDelegate methods", ^{
        it(@"should pass these through to its delegate", ^{
            [event interstitialDidLoadAd:controller];
            delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:)).with(event).and_with(controller);

            [event interstitialDidFailToLoadAd:controller];
            delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);

            [event interstitialWillAppear:controller];
            delegate should have_received(@selector(interstitialCustomEventWillAppear:)).with(event);

            [event interstitialDidAppear:controller];
            delegate should have_received(@selector(interstitialCustomEventDidAppear:)).with(event);

            [event interstitialWillDisappear:controller];
            delegate should have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);

            [event interstitialDidDisappear:controller];
            delegate should have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);

            [event interstitialWillLeaveApplication:controller];
            delegate should have_received(@selector(interstitialCustomEventWillLeaveApplication:)).with(event);
        });
    });
});

SPEC_END
