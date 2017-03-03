#import "MPAdAlertManager.h"
#import "FakeMPAdAlertGestureRecognizer.h"
#import "FakeUITouch.h"
#import "MPAdConfigurationFactory.h"
#import "CedarAsync.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface MPAdAlertManager () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) MPAdAlertGestureRecognizer *adAlertGestureRecognizer;

@end

SPEC_BEGIN(MPAdAlertManagerSpec)

describe(@"MPAdAlertManager", ^{
    __block MPAdAlertManager *alertManager;
    __block id<MPAdAlertManagerDelegate, CedarDouble> delegate;
    __block UIView *targetAdView;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        FakeMPAdAlertGestureRecognizer *fakeGestureRecognizer = [[FakeMPAdAlertGestureRecognizer alloc] init];
        fakeCoreProvider.fakeAdAlertGestureRecognizer = fakeGestureRecognizer;

        UIViewController *presentingController = [[UIViewController alloc] init];

        alertManager = [[MPAdAlertManager alloc] init];
        delegate = nice_fake_for(@protocol(MPAdAlertManagerDelegate));
        delegate stub_method(@selector(viewControllerForPresentingMailVC)).and_return(presentingController);
        alertManager.delegate = delegate;

        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
        alertManager.adConfiguration = configuration;

        targetAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        alertManager.targetAdView = targetAdView;
    });

    afterEach(^{
        alertManager.delegate = nil;
        alertManager.targetAdView = nil;
    });

    context(@"when the manager starts to monitor gestures", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [alertManager beginMonitoringAlerts];
        });

        it(@"should add the gesture recognizer to the target ad view", ^{
            targetAdView.gestureRecognizers should contain(alertManager.adAlertGestureRecognizer);
        });

        context(@"when beginMonitoringAlerts is called multiple times", ^{
           it(@"should only add one gesture recognizer to the target ad view", ^{
               [alertManager beginMonitoringAlerts];
               targetAdView.gestureRecognizers.count should equal(1);
           });
        });

        context(@"when the the ad alert manager stops monitoring alerts", ^{
            beforeEach(^{
                [alertManager endMonitoringAlerts];
            });

            it(@"should remove the gesture recognizer from the target view", ^{
                targetAdView.gestureRecognizers should_not contain(alertManager.adAlertGestureRecognizer);
            });
        });

        context(@"when a gesture is recognized", ^{
            it(@"should tell the delegate", ^{
                FakeMPAdAlertGestureRecognizer *fakeGestureRecognizer = (FakeMPAdAlertGestureRecognizer *)alertManager.adAlertGestureRecognizer;
                [fakeGestureRecognizer simulateGestureRecognized];
                delegate should have_received(@selector(adAlertManagerDidTriggerAlert:)).with(alertManager);
            });

//            context(@"when the manager is asked to process the alert", ^{
//                beforeEach(^{
//                    delegate stub_method("adAlertManagerDidTriggerAlert:").and_do(^(NSInvocation * inv) {
//                        [alertManager processAdAlertOnce];
//                    });
//                    FakeMPAdAlertGestureRecognizer *fakeGestureRecognizer = (FakeMPAdAlertGestureRecognizer *)alertManager.adAlertGestureRecognizer;
//                    [fakeGestureRecognizer simulateGestureRecognized];
//                });
//
//                it(@"should actually process the alert", PENDING);
//
//                it(@"should tell the delegate when done", ^{
//                    in_time(delegate) should have_received(@selector(adAlertManagerDidProcessAlert:)).with(alertManager);
//                });
//
//                it(@"should only process the alert once", ^{
//                    [delegate reset_sent_messages];
//
//                    FakeMPAdAlertGestureRecognizer *fakeGestureRecognizer = (FakeMPAdAlertGestureRecognizer *)alertManager.adAlertGestureRecognizer;
//                    [fakeGestureRecognizer simulateGestureRecognized];
//
//                    in_time(delegate) should_not have_received(@selector(adAlertManagerDidProcessAlert:)).with(alertManager);
//                });
//            });
        });
    });

    context(@"when determining if the gesture recognizer should handle a touch", ^{
        __block FakeUITouch *fakeTouch;

        beforeEach(^{
            fakeTouch = [[FakeUITouch alloc] init];
        });

        it(@"should handle a touch in our view", ^{
            fakeTouch.view = [[UIView alloc] initWithFrame:CGRectZero];
            BOOL shouldHandle = [alertManager gestureRecognizer:nil shouldReceiveTouch:fakeTouch];
            shouldHandle should equal(YES);
        });

        it(@"should not handle a touch on a UIButton", ^{
            fakeTouch.view = [[UIButton alloc] initWithFrame:CGRectZero];
            BOOL shouldHandle = [alertManager gestureRecognizer:nil shouldReceiveTouch:fakeTouch];
            shouldHandle should equal(NO);
        });
    });
});

SPEC_END

#pragma clang diagnostic pop
