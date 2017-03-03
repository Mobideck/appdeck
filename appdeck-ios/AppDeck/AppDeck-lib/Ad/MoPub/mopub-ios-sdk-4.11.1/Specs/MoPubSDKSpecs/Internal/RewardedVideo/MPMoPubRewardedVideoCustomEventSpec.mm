#import "MPMoPubRewardedVideoCustomEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPMoPubRewardedVideoCustomEvent()

@property (nonatomic) MPMRAIDInterstitialViewController<CedarDouble> *interstitial;

- (void)interstitialDidLoadAd:(MPInterstitialViewController *)interstitial;
- (void)interstitialDidAppear:(MPInterstitialViewController *)interstitial;
- (void)interstitialWillAppear:(MPInterstitialViewController *)interstitial;
- (void)interstitialDidFailToLoadAd:(MPInterstitialViewController *)interstitial;
- (void)interstitialWillDisappear:(MPInterstitialViewController *)interstitial;
- (void)interstitialDidDisappear:(MPInterstitialViewController *)interstitial;
- (void)interstitialDidReceiveTapEvent:(MPInterstitialViewController *)interstitial;
- (void)interstitialWillLeaveApplication:(MPInterstitialViewController *)interstitial;
- (void)interstitialRewardedVideoEnded;

@end

SPEC_BEGIN(MPMoPubRewardedVideoCustomEventSpec)

describe(@"MPMoPubRewardedVideoCustomEvent", ^{
    __block MPMoPubRewardedVideoCustomEvent *customEvent;
    __block id<CedarDouble, MPPrivateRewardedVideoCustomEventDelegate> delegate;

    beforeEach(^{
        customEvent = [[MPMoPubRewardedVideoCustomEvent alloc] init];
        delegate = nice_fake_for(@protocol(MPPrivateRewardedVideoCustomEventDelegate));
        customEvent.delegate = delegate;
    });

    context(@"when requesting a rewarded video ads", ^{
        beforeEach(^{
            spy_on(customEvent);
            [customEvent requestRewardedVideoWithCustomEventInfo:nil];
        });

        it(@"should initialize interstitialViewController", ^{
            customEvent.interstitial should_not be_nil;
        });

        context(@"when presentRewardedVideoFromViewController is called and hasAdAvailable = YES", ^{
            beforeEach(^{
                customEvent stub_method(@selector(hasAdAvailable)).and_return(YES);
                spy_on(customEvent.interstitial);
                [customEvent presentRewardedVideoFromViewController:[UIViewController new]];
            });

            it(@"presentInterstitialFromViewController should be called", ^{
                customEvent.interstitial should have_received(@selector(presentInterstitialFromViewController:));
            });
        });

        context(@"when presentRewardedVideoFromViewController is called and hasAdAvailable = NO", ^{
            beforeEach(^{
                customEvent stub_method(@selector(hasAdAvailable)).and_return(NO);
                spy_on(customEvent.interstitial);
                [customEvent presentRewardedVideoFromViewController:[UIViewController new]];
            });

            it(@"rewardedVideoDidFailToPlayForCustomEvent:error: should be called", ^{
                customEvent.delegate should have_received(@selector(rewardedVideoDidFailToPlayForCustomEvent:error:));
            });
        });
    });

    context(@"when MPMRAIDInterstitialViewControllerDelegate methods get called", ^{
        beforeEach(^{
            [customEvent requestRewardedVideoWithCustomEventInfo:nil];
        });

        context(@"when interstitialDidLoadAd: called", ^{
            beforeEach(^{
                spy_on(customEvent);
                [customEvent interstitialDidLoadAd:nil];
            });

            it(@"should send the message to rewardedVideoDidLoadAdForCustomEvent", ^{
                [customEvent hasAdAvailable] should be_truthy;
                delegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            });
        });

        context(@"when interstitialDidAppear: called", ^{
            beforeEach(^{
                [customEvent interstitialDidAppear:nil];
            });

            it(@"should send the message to rewardedVideoDidAppearForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
            });
        });

        context(@"when interstitialWillAppear: called", ^{
            beforeEach(^{
                [customEvent interstitialWillAppear:nil];
            });

            it(@"should send the message to rewardedVideoWillAppearForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoWillAppearForCustomEvent:));
            });
        });

        context(@"when interstitialDidFailToLoadAd: called", ^{
            beforeEach(^{
                [customEvent interstitialDidFailToLoadAd:nil];
            });

            it(@"should send the message to rewardedVideoDidFailToLoadAdForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:));
            });
        });

        context(@"when interstitialWillDisappear: called", ^{
            beforeEach(^{
                [customEvent interstitialWillDisappear:nil];
            });

            it(@"should send the message to rewardedVideoWillDisappearForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
            });
        });

        context(@"when interstitialDidDisappear: called", ^{
            beforeEach(^{
                spy_on(customEvent);
                [customEvent interstitialDidDisappear:nil];
            });

            it(@"should send the message to rewardedVideoDidDisappearForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
                [customEvent hasAdAvailable] should be_falsy;
            });
        });

        context(@"when interstitialDidReceiveTapEvent: called", ^{
            beforeEach(^{
                [customEvent interstitialDidReceiveTapEvent:nil];
            });

            it(@"should send the message to rewardedVideoDidReceiveTapEventForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoDidReceiveTapEventForCustomEvent:));
            });
        });

        context(@"when interstitialWillLeaveApplication: called", ^{
            beforeEach(^{
                [customEvent interstitialWillLeaveApplication:nil];
            });

            it(@"should send the message to rewardedVideoWillLeaveApplicationForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoWillLeaveApplicationForCustomEvent:));
            });
        });

        context(@"when interstitialRewardedVideoEnded: called", ^{
            beforeEach(^{
                [customEvent interstitialRewardedVideoEnded];
            });

            it(@"should send the message to rewardedVideoShouldRewardUserForCustomEvent", ^{
                delegate should have_received(@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:));
            });
        });

    });

});

SPEC_END
