#import "FacebookInterstitialCustomEvent.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FakeFBInterstitialAd.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface FacebookInterstitialCustomEvent (Specs) <FBInterstitialAdDelegate>

@end

SPEC_BEGIN(FacebookInterstitialCustomEventSpec)

describe(@"FacebookInterstitialCustomEvent", ^{
    __block FacebookInterstitialCustomEvent *event;
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block FakeFBInterstitialAd *interstitial;

    beforeEach(^{
        interstitial = [[FakeFBInterstitialAd alloc] init];
        fakeProvider.fakeFBInterstitialAd = interstitial.masquerade;

        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        event = [[FacebookInterstitialCustomEvent alloc] init];
        event.delegate = delegate;
        [event requestInterstitialWithCustomEventInfo:@{@"placement_id":@"fb_placement"}];
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *presentingController;

        beforeEach(^{
            presentingController = [[UIViewController alloc] init];
        });

        context(@"when the interstitial is loaded", ^{
            beforeEach(^{
                [interstitial simulateLoadingAd];
                [event showInterstitialFromRootViewController:presentingController];
            });

            it(@"should tell its delegate that an interstitial will appear", ^{
                delegate should have_received(@selector(interstitialCustomEventWillAppear:)).with(event);
            });

            it(@"should tell the interstitial view controller to show the interstitial", ^{
                interstitial.presentingViewController should equal(presentingController);
            });

            it(@"should tell its delegate that an interstitial did appear", ^{
                delegate should have_received(@selector(interstitialCustomEventDidAppear:)).with(event);
            });
        });

        context(@"when the interstitial is not loaded", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                interstitial.isAdValid = NO;
                [event showInterstitialFromRootViewController:presentingController];
            });

            it(@"should tell its delegate that the interstitial expired", ^{
                delegate should have_received(@selector(interstitialCustomEventDidExpire:)).with(event);
            });

            it(@"should not tell the interstitial view controller to show the interstitial", ^{
                interstitial.presentingViewController should be_nil;
            });
        });

        context(@"when the interstitial fails to load", ^{
            it(@"should tell its delegate and expire", ^{
                [event requestInterstitialWithCustomEventInfo:@{@"wrong_placement_id_key":@"fb_placement"}];
                delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
            });
        });
    });

    context(@"when the interstitial is tapped", ^{
        it(@"should allow the interstitial to proceed with its action", ^{
            [event interstitialAdDidClick:interstitial.masquerade] should equal(YES);
        });
    });

    context(@"when the interstitial has been dismissed", ^{
        beforeEach(^{
            interstitial.isAdValid = YES;
            [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
            [interstitial simulateUserDismissingAd];
            [interstitial simulateUserDismissedAd];
        });

        it(@"should tell its delegate", ^{
            delegate should have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
            delegate should have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
        });
    });

    context(@"when the interstitial is dismissed and unloaded", ^{
        beforeEach(^{
            interstitial.isAdValid = YES;
            [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
            [interstitial simulateUserDismissingAd];
            [interstitial simulateUserDismissedAd];
            [delegate reset_sent_messages];
            [interstitial simulateUserDismissedAd];
        });

        it(@"should not send duplicate disappear events", ^{
            delegate should_not have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
            delegate should_not have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
        });
    });

    context(@"when the interstitial has unloaded", ^{

        context(@"after having been displayed", ^{
            beforeEach(^{
                interstitial.isAdValid = YES;
                [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
                [interstitial simulateUserDismissingAd];
                [interstitial simulateUserDismissedAd];
            });

            it(@"should tell its delegate", ^{
                delegate should have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
                delegate should have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
            });
        });
    });
});

SPEC_END
