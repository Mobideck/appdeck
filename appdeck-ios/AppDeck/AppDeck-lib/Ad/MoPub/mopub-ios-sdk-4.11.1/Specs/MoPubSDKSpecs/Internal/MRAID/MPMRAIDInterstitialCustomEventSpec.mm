#import "MPMRAIDInterstitialCustomEvent.h"
#import "MPAdConfigurationFactory.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPMRAIDInterstitialCustomEvent ()

@property (nonatomic, readonly) MPMRAIDInterstitialViewController *interstitial;

@end

SPEC_BEGIN(MPMRAIDInterstitialCustomEventSpec)

describe(@"MPMRAIDInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPPrivateInterstitialCustomEventDelegate> delegate;
    __block MPMRAIDInterstitialCustomEvent *event;
    __block MPAdConfiguration *configuration;
    __block MPMRAIDInterstitialViewController<CedarDouble> *viewController;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPPrivateInterstitialCustomEventDelegate));
        viewController = nice_fake_for([MPMRAIDInterstitialViewController class]);
        fakeProvider.fakeMPMRAIDInterstitialViewController = viewController;

        configuration = [MPAdConfigurationFactory defaultMRAIDInterstitialConfiguration];
        delegate stub_method("configuration").and_return(configuration);

        event = [[MPMRAIDInterstitialCustomEvent alloc] init];
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
            viewController should have_received(@selector(setCloseButtonStyle:)).with(MPInterstitialCloseButtonStyleAlwaysHidden);
        });

        it(@"should tell the interstitial view controller to start loading", ^{
            viewController should have_received(@selector(startLoading));
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *presentingController;

        beforeEach(^{
            presentingController = [[UIViewController alloc] init];
            [event showInterstitialFromRootViewController:presentingController];
        });

        it(@"should tell the interstitial view controller to show the interstitial", ^{
            viewController should have_received(@selector(presentInterstitialFromViewController:)).with(presentingController);
        });

        context(@"when asked to dismiss the interstitial", ^{
            beforeEach(^{
                [event interstitialDidDisappear:viewController];
            });

            it(@"should nil out the interstitial view controller", ^{
                event.interstitial should be_nil;
            });
        });
    });

    describe(@"MPMRAIDInterstitialViewControllerDelegate methods", ^{
        it(@"should pass these through to its delegate", ^{
            [event interstitialDidLoadAd:viewController];
            delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:)).with(event).and_with(viewController);

            [event interstitialDidFailToLoadAd:viewController];
            delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);

            [event interstitialWillAppear:viewController];
            delegate should have_received(@selector(interstitialCustomEventWillAppear:)).with(event);

            [event interstitialDidAppear:viewController];
            delegate should have_received(@selector(interstitialCustomEventDidAppear:)).with(event);

            [event interstitialWillDisappear:viewController];
            delegate should have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);

            [event interstitialDidDisappear:viewController];
            delegate should have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);

            [event interstitialWillLeaveApplication:viewController];
            delegate should have_received(@selector(interstitialCustomEventWillLeaveApplication:)).with(event);
        });
    });
});

SPEC_END
