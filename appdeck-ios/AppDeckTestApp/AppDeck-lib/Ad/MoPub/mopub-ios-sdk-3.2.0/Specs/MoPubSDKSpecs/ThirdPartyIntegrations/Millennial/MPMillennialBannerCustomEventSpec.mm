#import "MPMillennialBannerCustomEvent.h"
#import "FakeMMAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMillennialBannerCustomEventSpec)

describe(@"MPMillennialBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block MPMillennialBannerCustomEvent *event;
    __block FakeMMAdView *banner;
    __block CLLocation *location;
    __block NSDictionary *customEventInfo;
    __block UIViewController *viewController;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        banner = [[FakeMMAdView alloc] initWithFrame:CGRectMake(0,0,32,10)];
        fakeProvider.fakeMMAdView = banner;

        event = [[MPMillennialBannerCustomEvent alloc] init];
        event.delegate = delegate;

        location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                  altitude:11
                                        horizontalAccuracy:12.3
                                          verticalAccuracy:10
                                                 timestamp:[NSDate date]];
        delegate stub_method("location").and_return(location);

        viewController = [[UIViewController alloc] init];
        delegate stub_method("viewControllerForPresentingModalView").and_return(viewController);

        customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@728, @"adHeight":@90};
    });

    subjectAction(^{
        [event requestAdWithSize:CGSizeZero customEventInfo:customEventInfo];
    });

    it(@"should disallow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    describe(@"notifications", ^{
        __block FakeMMAdView *anotherBanner;

        beforeEach(^{
            anotherBanner = [[FakeMMAdView alloc] initWithFrame:CGRectMake(0,0,32,10)];
            anotherBanner.apid = @"mmmmmmm";
        });

        it(@"should ignore notifications from other MMAdViews", ^{
            [delegate reset_sent_messages];

            [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo:anotherBanner.userInfo];

            [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillAppear object:nil userInfo:anotherBanner.userInfo];

            [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidDismiss object:nil userInfo:anotherBanner.userInfo];

            delegate.sent_messages should be_empty;
        });

        context(@"MillennialMediaAdWasTapped", ^{

            // XXX: As of Millennial SDK version 5.1.0, a "tapped" notification for an MMAdView is
            // accompanied by the presentation of a modal loading indicator (spinner). Although this
            // spinner is modal, the Millennial SDK does not appropriately fire the
            // MillennialMediaAdModalWillAppear notification until much later. Specifically, the
            // notification is not fired until other modal content (e.g. browser or StoreKit) is about
            // to come on-screen and replace the spinner.
            //
            // In previous Millennial SDK versions, it was sufficient for MoPub to use the "will appear"
            // and "did dismiss" notifications to determine whether an MMAdView could be deallocated.
            // However, in 5.1.0, MMAdView causes crashes if deallocated while its spinner is on-screen.
            // Thus, we must call [self.delegate bannerCustomEventWillBeginAction:self] as soon as we
            // detect that the spinner has been presented.

            it(@"should track a click (only the first time) and tell the delegate that a modal will appear", ^{
                [delegate reset_sent_messages];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo:banner.userInfo];
                verify_fake_received_selectors(delegate, @[@"trackClick", @"bannerCustomEventWillBeginAction:"]);

                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo:banner.userInfo];
                verify_fake_received_selectors(delegate, @[@"bannerCustomEventWillBeginAction:"]);
            });
        });

        context(@"MillennialMediaAdModalWillAppear", ^{

            // XXX: See note above.

            it(@"should not tell the delegate anything", ^{
                [delegate reset_sent_messages];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillAppear object:nil userInfo:banner.userInfo];
                delegate.sent_messages should be_empty;
            });
        });

        context(@"MillennialMediaAdModalDidDismiss", ^{
            it(@"should tell the delegate that a modal was dismissed", ^{
                [delegate reset_sent_messages];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidDismiss object:nil userInfo:banner.userInfo];
                verify_fake_received_selectors(delegate, @[@"bannerCustomEventDidFinishAction:"]);
            });
        });

        context(@"MillennialMediaAdWillTerminateApplication with a modal first", ^{
            it(@"should tell the delegate that user action has completed", ^{
                [delegate reset_sent_messages];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo:banner.userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalWillAppear object:nil userInfo:banner.userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWillTerminateApplication object:nil userInfo:banner.userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdModalDidDismiss object:nil userInfo:banner.userInfo];
                verify_fake_received_selectors(delegate, @[@"trackClick", @"bannerCustomEventWillBeginAction:", @"bannerCustomEventWillLeaveApplication:", @"bannerCustomEventDidFinishAction:"]);
            });
        });

        context(@"MillennialMediaAdWillTerminateApplication without a modal first", ^{
            it(@"should tell the delegate that user action has completed", ^{
                [delegate reset_sent_messages];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWasTapped object:nil userInfo:banner.userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWillTerminateApplication object:nil userInfo:banner.userInfo];
                verify_fake_received_selectors(delegate, @[@"trackClick", @"bannerCustomEventWillBeginAction:", @"bannerCustomEventWillLeaveApplication:", @"bannerCustomEventDidFinishAction:"]);
            });
        });

        context(@"MillennialMediaAdWillTerminateApplication received without a click", ^{
           it(@"should not tell the delegate anything", ^{
               [delegate reset_sent_messages];
               [[NSNotificationCenter defaultCenter] postNotificationName:MillennialMediaAdWillTerminateApplication object:nil userInfo:banner.userInfo];
               delegate.sent_messages should be_empty;
           });
        });
    });

    context(@"when asked to fetch a banner", ^{
        it(@"should set the banner's ad unit ID and delegate", ^{
            banner.apid should equal(@"mmmmmmm");
            banner.rootViewController should equal(viewController);
            banner.request.location should equal(location);
            banner.request.dataParameters[@"vendor"] should equal(@"mopubsdk");
        });

        context(@"the banner size", ^{
            context(@"when the banner size matches the regular banner size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@320, @"adHeight":@50};
                });

                it(@"should fetch a banner of the right size and type", ^{
                    banner.frame should equal(CGRectMake(0, 0, 320, 50));
                });
            });

            context(@"when the banner size matches the leaderboard banner size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@728, @"adHeight":@90};
                });

                it(@"should fetch a banner of the right size and type", ^{
                    banner.frame should equal(CGRectMake(0, 0, 728, 90));
                });
            });

            context(@"when the banner size matches the rectangle size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@300, @"adHeight":@250};
                });

                it(@"should fetch a banner of the right size and type", ^{
                    banner.frame should equal(CGRectMake(0, 0, 300, 250));
                });
            });

            context(@"when the size doesn't match one of the above", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@370, @"adHeight":@250};
                });

                it(@"should fetch a banner of the 320x53 size and top type", ^{
                    banner.frame should equal(CGRectMake(0, 0, 320, 50));
                });
            });

            context(@"when the size is not present", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm"};
                });

                it(@"should fetch a banner of the 320x53 size and top type", ^{
                    banner.frame should equal(CGRectMake(0, 0, 320, 50));
                });
            });
        });
    });
});

SPEC_END
