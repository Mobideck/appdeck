//
//  MPMRAIDInterstitialViewControllerSpec.mm
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPMRAIDInterstitialViewController.h"
#import "MRController.h"
#import "MPAdConfigurationFactory.h"
#import "MPInstanceProvider.h"
#import "CedarAsync.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMRAIDInterstitialViewControllerSpec)

describe(@"MPMRAIDInterstitialViewController", ^{
    __block MPMRAIDInterstitialViewController *controller;
    __block MRController *backingController;
    __block MPAdConfiguration *configuration;
    __block id<CedarDouble, MPInterstitialViewControllerDelegate> delegate;
    __block UIViewController *presentingViewController;

    beforeEach(^{
        presentingViewController = [[UIViewController alloc] init];
        configuration = [MPAdConfigurationFactory defaultMRAIDInterstitialConfiguration];
        delegate = nice_fake_for(@protocol(MPInterstitialViewControllerDelegate));

        backingController = nice_fake_for([MRController class]);
        fakeProvider.fakeMRController = backingController;

        controller = [[MPMRAIDInterstitialViewController alloc] initWithAdConfiguration:configuration];
        controller.delegate = delegate;

        [presentingViewController presentViewController:controller animated:NO completion:nil];
    });

    describe(@"when it will be dismissed", ^{
        beforeEach(^{
            [controller willDismissInterstitial];
        });

        it(@"should tell its backing view to stop handling requests", ^{
            backingController should have_received(@selector(disableRequestHandling));
        });

        it(@"should tell its delegate interstitialWillDisappear:", ^{
            delegate should have_received(@selector(interstitialWillDisappear:)).with(controller);
        });

        describe(@"after being dismissed", ^{
            beforeEach(^{
                [controller didDismissInterstitial];
            });

            it(@"should tell the backing view that it was dismissed", ^{
                backingController should have_received(@selector(disableRequestHandling));
            });

            it(@"should tell its delegate interstitialDidDisappear:", ^{
                delegate should have_received(@selector(interstitialDidDisappear:)).with(controller);
            });
        });
    });

    describe(@"when it will be presented", ^{
        beforeEach(^{
            [controller willPresentInterstitial];
        });

        it(@"should tell its delegate interstitialWillAppear:", ^{
            in_time(delegate) should have_received(@selector(interstitialWillAppear:)).with(controller);
        });

        describe(@"after being presented", ^{
            beforeEach(^{
                [controller didPresentInterstitial];
            });

            it(@"should tell the backing controller that it was presented", ^{
                in_time(backingController) should have_received(@selector(handleMRAIDInterstitialDidPresentWithViewController:));
            });

            it(@"should tell its delegate interstitialDidAppear:", ^{
                in_time(delegate) should have_received(@selector(interstitialDidAppear:)).with(controller);
            });
        });
    });
});

SPEC_END
