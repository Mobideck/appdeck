#import "VungleInterstitialCustomEvent.h"
#import "VungleSDK+Specs.h"

#import <CoreLocation/CoreLocation.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(VungleInterstitialCustomEventSpec)

describe(@"VungleInterstitialCustomEvent", ^{
    __block VungleInterstitialCustomEvent *model;
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block VungleSDK *sharedSDK;

    beforeEach(^{
        model = [[VungleInterstitialCustomEvent alloc] init];
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        model.delegate = delegate;

        sharedSDK = [VungleSDK sharedSDK];
    });

    context(@"when requesting a Vungle video ad", ^{
        beforeEach(^{
            [model requestInterstitialWithCustomEventInfo:[NSDictionary dictionaryWithObject:@"CUSTOM_APP_ID" forKey:@"appId"]];
        });

        it(@"should set itself as Vungle's delegate", ^{
            [sharedSDK delegate] should equal(model);
        });

        it(@"should use the app id from the info dictionary", ^{
            [VungleSDK mp_getAppId] should equal(@"CUSTOM_APP_ID");
        });

        context(@"when Vungle sends us vungleSDKhasCachedAdAvailable", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [sharedSDK.delegate vungleSDKhasCachedAdAvailable];
            });

            it(@"should notify the delegate ad did load", ^{
                delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));
            });
        });

        context(@"when Vungle sends us vungleSDKwillCloseAdWithViewInfo", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            describe(@"with presenting a product sheet", ^{
                it(@"should not send disappear messages to the delegate", ^{
                    [sharedSDK.delegate vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:YES];
                    delegate should_not have_received(@selector(interstitialCustomEventWillDisappear:));
                    delegate should_not have_received(@selector(interstitialCustomEventDidDisappear:));
                });
            });

            describe(@"with not presenting a product sheet", ^{
                it(@"should send disappear messages to the delegate", ^{
                    [sharedSDK.delegate vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:NO];
                    delegate should have_received(@selector(interstitialCustomEventWillDisappear:));
                    delegate should have_received(@selector(interstitialCustomEventDidDisappear:));
                });
            });
        });

        context(@"when Vungle sends us vungleSDKwillCloseProductSheet", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            it(@"should send disappear messages to the delegate", ^{
                [sharedSDK.delegate vungleSDKwillCloseProductSheet:nil];
                delegate should have_received(@selector(interstitialCustomEventWillDisappear:));
                delegate should have_received(@selector(interstitialCustomEventDidDisappear:));
            });
        });

        context(@"when Vungle sends us vungleSDKwillShowAd", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            it(@"should send appear messages to the delegate", ^{
                [sharedSDK.delegate vungleSDKwillShowAd];
                delegate should have_received(@selector(interstitialCustomEventWillAppear:));
                delegate should have_received(@selector(interstitialCustomEventDidAppear:));
            });
        });
    });

    context(@"when there are multiple requests to load a Vungle video ad", ^{
        __block VungleInterstitialCustomEvent *secondModel;
        __block id<CedarDouble, MPInterstitialCustomEventDelegate> secondDelegate;

        beforeEach(^{
            secondModel = [[VungleInterstitialCustomEvent alloc] init];
            secondDelegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
            secondModel.delegate = secondDelegate;

            [model requestInterstitialWithCustomEventInfo:nil];
            [secondModel requestInterstitialWithCustomEventInfo:nil];
        });

        it(@"secondModel should be the Vungle delegate", ^{
            [sharedSDK delegate] should equal(secondModel);

            [sharedSDK.delegate vungleSDKhasCachedAdAvailable];
            secondDelegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));
            delegate should_not have_received(@selector(interstitialCustomEvent:didLoadAd:));
        });

        context(@"when the current Vungle delegate is invalidated", ^{
            beforeEach(^{
                [secondModel performSelector:@selector(invalidate) withObject:nil];
            });

            it(@"should nil out the Vungle delegate", ^{
                [sharedSDK delegate] should be_nil;
            });

            context(@"when another custom event requests a Vungle ad", ^{
                beforeEach(^{
                    [model requestInterstitialWithCustomEventInfo:nil];
                });

                it(@"should be the Vungle delegate", ^{
                    [sharedSDK delegate] should equal(model);
                });
            });
        });
    });
});

SPEC_END
