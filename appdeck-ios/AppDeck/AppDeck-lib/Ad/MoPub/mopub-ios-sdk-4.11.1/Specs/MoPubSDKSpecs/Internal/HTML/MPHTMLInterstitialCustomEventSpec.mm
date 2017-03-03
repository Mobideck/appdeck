#import "MPHTMLInterstitialCustomEvent.h"
#import "MPAdConfigurationFactory.h"
#import "MPHTMLInterstitialViewController.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPHTMLInterstitialCustomEvent ()

@property (nonatomic, readonly) MPHTMLInterstitialViewController *interstitial;

@end

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

        event = [[MPHTMLInterstitialCustomEvent alloc] init];
        event.delegate = delegate;

        [event requestInterstitialWithCustomEventInfo:nil];
    });

    it(@"should disable automatic metrics tracking", ^{
        // The webview agent used by HTML interstitials will track clicks
        // Since 2.4, HTML interstitials invoke the clicked delegate method that causes the base adapter to kick off the click tracker.
        // Turn off automatic tracking to prevent double counting of clicks
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    context(@"when asked to get an ad for a configuration", ^{
        it(@"should tell the interstitial view controller to load the configuration", ^{
            controller should have_received(@selector(loadConfiguration:)).with(configuration);
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *presentingController;

        beforeEach(^{
            presentingController = [[UIViewController alloc] init];
            [event showInterstitialFromRootViewController:presentingController];
        });

        it(@"should tell the interstitial view controller to show the interstitial", ^{
            controller should have_received(@selector(presentInterstitialFromViewController:)).with(presentingController);
        });

        it(@"should tell the delegate to track an impression when it's visible", ^{
            [event interstitialDidAppear:nil];
            delegate should have_received(@selector(trackImpression));
        });

        it(@"should tell the delegate the interstitial was tapped", ^{
            [event interstitialDidReceiveTapEvent:nil];
            delegate should have_received(@selector(interstitialCustomEventDidReceiveTapEvent:));
        });

        context(@"when asked to dismiss the interstitial", ^{
            beforeEach(^{
                [event interstitialDidDisappear:controller];
            });

            it(@"should nil out the interstitial view controller", ^{
                event.interstitial should be_nil;
            });
        });
    });
});

SPEC_END
