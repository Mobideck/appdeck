#import "MPMillennialInterstitialCustomEvent.h"
#import "FakeMMInterstitial.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPInstanceProvider (MillennialInterstitialsSpec)

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(id<MMAdDelegate>)delegate;

@end

@interface MPMillennialInterstitialCustomEvent (spec)

- (void)invalidate;

@end

SPEC_BEGIN(MPMillennialInterstitialCustomEventSpec)

describe(@"MPMillennialInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block MPMillennialInterstitialCustomEvent *event;
    __block FakeMMInterstitial *interstitial;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        event = [[MPMillennialInterstitialCustomEvent alloc] init];
        event.delegate = delegate;
        interstitial = [[FakeMMInterstitial alloc] init];
        fakeProvider.fakeMMInterstitial = interstitial;
    });

    context(@"when asked to fetch a configuration without an adunitid", ^{
        beforeEach(^{
            [event requestInterstitialWithCustomEventInfo:@{}];
        });

        it(@"should tell its delegate that it failed", ^{
            delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
        });
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    describe(@"edge cases involving notifications", ^{
        it(@"should filter out irrelevant notifications (e.g. for other objects, APIDs)", ^{
            [event requestInterstitialWithCustomEventInfo:@{@"adUnitID":@"foo"}];
            [interstitial fetchCompletionBlock:@"foo"](YES, 0);
            [delegate reset_sent_messages];

            // Ignore notifications fired for an interstitial with a different APID.
            [interstitial simulateInterstitialWillAppear:@"bar"];
            [interstitial simulateInterstitialDidAppear:@"bar"];
            [interstitial simulateInterstitialTap];
            [interstitial simulateInterstitialWillDismiss:@"bar"];
            [interstitial simulateInterstitialDidDismiss:@"bar"];
            delegate.sent_messages should be_empty;

            // Taps on the interstitial should be ignored if the interstitial is not onscreen yet
            [interstitial simulateInterstitialTap];
            delegate.sent_messages should be_empty;

            // Allow notifications fired for the right APID, but only once.
            [interstitial simulateInterstitialWillAppear:@"foo"];
            delegate should have_received(@selector(interstitialCustomEventWillAppear:));
            [delegate reset_sent_messages];

            [interstitial simulateInterstitialDidAppear:@"foo"];
            delegate should have_received(@selector(interstitialCustomEventDidAppear:));
            [delegate reset_sent_messages];

            // Millennial will fire another set of notifications if the interstitial presents a
            // modal. In these cases, don't message the delegate again.
            [interstitial simulateInterstitialWillAppear:@"foo"];
            [interstitial simulateInterstitialDidAppear:@"foo"];
            delegate.sent_messages should be_empty;

            // Taps on the presented modal should be ignored
            [interstitial simulateInterstitialTap];
            delegate should_not have_received(@selector(interstitialCustomEventDidReceiveTapEvent:));

            // Don't message the delegate if a second-level modal is being dismissed.
            [interstitial simulateInterstitialWillDismiss:@"foo"];
            [interstitial simulateInterstitialDidDismiss:@"foo"];
            delegate.sent_messages should be_empty;

            // Taps on the interstitial itself should be received
            [interstitial simulateInterstitialTap];
            delegate should have_received(@selector(interstitialCustomEventDidReceiveTapEvent:));

            // Do message the delegate if the actual interstitial is being dismissed.
            [interstitial simulateInterstitialWillDismiss:@"foo"];
            delegate should have_received(@selector(interstitialCustomEventWillDisappear:));

            [interstitial simulateInterstitialDidDismiss:@"foo"];
            delegate should have_received(@selector(interstitialCustomEventDidDisappear:));
        });
    });

    describe(@"edge cases involving multiple events", ^{
        context(@"when an event is invalidated after it starts loading, but before the fetch returns", ^{
            it(@"should ignore the result of the fetch", ^{
                [event requestInterstitialWithCustomEventInfo:@{@"adUnitID":@"foo"}];
                [delegate reset_sent_messages];
                [event invalidate];
                [interstitial fetchCompletionBlock:@"foo"](YES, 0);
                delegate.sent_messages should be_empty;
            });
        });

        context(@"when a new event is added while the first event is still loading (but has been invalidated)", ^{
            it(@"should ignore the result of the fetch for the first event, but let the second event know", ^{
                [event requestInterstitialWithCustomEventInfo:@{@"adUnitID":@"foo"}];
                [delegate reset_sent_messages];
                [event invalidate];

                MMCompletionBlock completionBlock = [interstitial fetchCompletionBlock:@"foo"];

                id<CedarDouble, MPInterstitialCustomEventDelegate> anotherDelegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
                MPMillennialInterstitialCustomEvent *anotherEvent = [[MPMillennialInterstitialCustomEvent alloc] init];
                anotherEvent.delegate = anotherDelegate;
                [anotherEvent requestInterstitialWithCustomEventInfo:@{@"adUnitID":@"foo"}];
                [anotherDelegate reset_sent_messages];

                MMCompletionBlock anotherCompletionBlock = [interstitial fetchCompletionBlock:@"foo"];

                completionBlock(YES, 0);
                delegate.sent_messages should be_empty;
                anotherDelegate.sent_messages should be_empty;

                anotherCompletionBlock(YES, 0);
                delegate.sent_messages should be_empty;
                anotherDelegate should have_received(@selector(interstitialCustomEvent:didLoadAd:)).with(anotherEvent).and_with((nil));
            });
        });


        context(@"when an event is invalidated after it starts displaying, but before the display returns", ^{
            it(@"should ignore the result of the display", ^{
                [event requestInterstitialWithCustomEventInfo:@{@"adUnitID":@"foo"}];
                [interstitial setAvailabilityOfApid:@"foo" to:YES];
                [interstitial fetchCompletionBlock:@"foo"](YES, 0);

                [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
                [delegate reset_sent_messages];
                [event invalidate];
                [interstitial simulateSuccesfulPresentation:@"foo"];
                delegate.sent_messages should be_empty;
            });
        });
    });
});

SPEC_END
