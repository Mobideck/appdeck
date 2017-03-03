#import "MPHTMLInterstitialViewController.h"
#import "MPWebView.h"
#import "MPAdConfigurationFactory.h"
#import "MPInstanceProvider.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPHTMLInterstitialViewControllerSpec)

describe(@"MPHTMLInterstitialViewController", ^{
    __block MPHTMLInterstitialViewController *controller;
    __block MPWebView *backingView;
    __block MPAdConfiguration *configuration;
    __block id<CedarDouble, MPInterstitialViewControllerDelegate> delegate;
    __block UIViewController *presentingViewController;
    __block MPAdWebViewAgent *agent;

    beforeEach(^{
        presentingViewController = [[UIViewController alloc] init];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
        delegate = nice_fake_for(@protocol(MPInterstitialViewControllerDelegate));

        backingView = [[MPWebView alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
        agent = nice_fake_for([MPAdWebViewAgent class]);
        agent stub_method("view").and_return(backingView);
        fakeProvider.fakeMPAdWebViewAgent = agent;

        controller = [[MPHTMLInterstitialViewController alloc] init];
        controller.delegate = delegate;
        [controller loadConfiguration:configuration];

        [presentingViewController presentViewController:controller animated:NO completion:nil];
    });

    describe(@"when loading a configuration", ^{
        it(@"should have a black background", ^{
            controller.view.backgroundColor should equal([UIColor blackColor]);
        });

        it(@"should add its backing view to the view hierarchy", ^{
            controller.view.subviews.lastObject should equal(backingView);
            backingView.autoresizingMask should equal(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        });

        it(@"should tell the agent to load the configuration", ^{
            agent should have_received(@selector(loadConfiguration:)).with(configuration);
        });
    });

    describe(@"when it will be presented", ^{
        beforeEach(^{
            [controller willPresentInterstitial];
        });

        it(@"should set its backing view's alpha to 0", ^{
            backingView.alpha should equal(0);
        });

        it(@"should tell its delegate interstitialWillAppear:", ^{
            delegate should have_received(@selector(interstitialWillAppear:)).with(controller);
        });

        describe(@"after being presented", ^{
            beforeEach(^{
                [controller didPresentInterstitial];
            });

            it(@"should tell the backing view that it was presented", ^{
                agent should have_received(@selector(enableRequestHandling));
                agent should have_received(@selector(invokeJavaScriptForEvent:)).with(MPAdWebViewEventAdDidAppear);
                backingView.alpha should equal(1);
            });

            it(@"should tell its delegate interstitialDidAppear:", ^{
                delegate should have_received(@selector(interstitialDidAppear:)).with(controller);
            });
        });
    });

    describe(@"when it will be dismissed", ^{
        beforeEach(^{
            [controller willDismissInterstitial];
        });

        it(@"should tell its backing view to stop handling requests", ^{
            agent should have_received(@selector(disableRequestHandling));
        });

        it(@"should tell its delegate interstitialWillDisappear:", ^{
            delegate should have_received(@selector(interstitialWillDisappear:)).with(controller);
        });

        describe(@"after being dismissed", ^{
            beforeEach(^{
                [controller didDismissInterstitial];
            });

            it(@"should tell the backing view that it was dismissed", ^{
                agent should have_received(@selector(disableRequestHandling));
                agent should have_received(@selector(invokeJavaScriptForEvent:)).with(MPAdWebViewEventAdDidDisappear);
            });

            it(@"should tell its delegate interstitialDidDisappear:", ^{
                delegate should have_received(@selector(interstitialDidDisappear:)).with(controller);
            });
        });
    });

    describe(@"MPAdWebViewAgentDelegate methods", ^{
        it(@"should be the presenting controller", ^{
            controller.viewControllerForPresentingModalView should equal(controller);
        });

        it(@"should forward adDidFinishLoadingAd:", ^{
            [controller adDidFinishLoadingAd:backingView];
            delegate should have_received(@selector(interstitialDidLoadAd:)).with(controller);
        });

        it(@"should forward adDidFailToLoadAd:", ^{
            [controller adDidFailToLoadAd:backingView];
            delegate should have_received(@selector(interstitialDidFailToLoadAd:)).with(controller);
        });

        it(@"should forward adActionWillLeaveApplication: and dismiss itself", ^{
            [controller adActionWillLeaveApplication:backingView];
            delegate should have_received(@selector(interstitialWillLeaveApplication:)).with(controller);
            presentingViewController.presentedViewController should be_nil;
        });
    });
});

SPEC_END
