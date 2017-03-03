#import "MRController+Specs.h"
#import "FakeMRBridge.h"
#import "MRProperty.h"
#import "MPAdConfigurationFactory.h"
#import "UIWebView+MPAdditions.h"
#import "MRBundleManager.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MRVideoPlayerManager.h"
#import "CedarAsync.h"
#import "MRCommand.h"
#import "MRNativeCommandHandler.h"
#import "MRExpandModalViewController.h"
#import "MPClosableView+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface MRNativeCommandHandler () <MRVideoPlayerManagerDelegate, MRCommandDelegate>

@end

SPEC_BEGIN(MRControllerSpec)

describe(@"MRController", ^{
    __block FakeMRController *controller;
    __block FakeMRBridge *fakeMRBridge;
    __block MPWebView *webView;
    __block UIViewController *presentingViewController;
    __block MPAdDestinationDisplayAgent *destinationDisplayAgent;
    __block id<MRControllerDelegate> controllerDelegate;
    __block MPAdConfiguration *configuration;
    __block MRVideoPlayerManager<CedarDouble> *videoPlayerManager;
    __block UIWindow *window;

    beforeEach(^{
        webView = [[MPWebView alloc] init];

        videoPlayerManager = nice_fake_for([MRVideoPlayerManager class]);
        fakeProvider.fakeMRVideoPlayerManager = videoPlayerManager;

        fakeMRBridge = [[FakeMRBridge alloc] initWithWebView:webView];
        fakeProvider.fakeMRBridge = fakeMRBridge;

        destinationDisplayAgent = [[MPCoreInstanceProvider sharedProvider] buildMPAdDestinationDisplayAgentWithDelegate:nil];
        fakeCoreProvider.fakeMPAdDestinationDisplayAgent = destinationDisplayAgent;
        spy_on(destinationDisplayAgent);

        presentingViewController = [[UIViewController alloc] init];
        controllerDelegate = nice_fake_for(@protocol(MRControllerDelegate));
        controllerDelegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingViewController);

        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];

        controller = [[FakeMRController alloc] initWithAdViewFrame:CGRectMake(0, 0, 20, 20) adPlacementType:MRAdViewPlacementTypeInline];
        controller.delegate = controllerDelegate;
        [controller loadAdWithConfiguration:configuration];
        spy_on(controller);

        destinationDisplayAgent.delegate = controller;

        fakeMRBridge.delegate = controller;
        fakeMRBridge.shouldHandleRequests = YES;

        controller.userInteractedWithWebViewOverride = YES;

        window = [[UIWindow alloc] init];
        [window makeKeyAndVisible];
    });

    describe(@"initial autoresizing mask", ^{
        it(@"should be UIViewAutoresizingNone on a banner mraidAdView.", ^{
            controller.mraidAdView.autoresizingMask should equal(UIViewAutoresizingNone);
        });

        it(@"should be flexible width/height on an interstitial mraidAdView.", ^{
            controller = [[FakeMRController alloc] initWithAdViewFrame:CGRectMake(0, 0, 20, 20) adPlacementType:MRAdViewPlacementTypeInterstitial];

            // load ad so the closable views are non-nil
            [controller loadAdWithConfiguration:configuration];

            controller.mraidAdView.autoresizingMask should equal(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        });
    });

    describe(@"updateMRAIDProperties", ^{
        subjectAction(^{
            // XXX: We need to add the ad view to the view hierarchy; otherwise, any code that
            // performs visibility checks will think that the ad is not visible.
            [window addSubview:controller.mraidAdView];

            // XXX: The act of placing the ad in a view hierarchy generates a lot of messages.
            // To keep the tests clean, we'll ignore messages before the next updateMRAIDProperties.
            [(id<CedarDouble>)controller reset_sent_messages];

            [controller updateMRAIDProperties];
        });

        // Test that updateMRAIDProperties is called eventually.
        xit(@"should make sure the controller timer calls updateMRAIDProperties", ^{

        });

        context(@"when not animating the ad size", ^{
            beforeEach(^{
                controller.isAnimatingAdSize = NO;
            });

            context(@"if the application is in the active state", ^{
                beforeEach(^{
                    controller.isViewable = NO;
                    spy_on([UIApplication sharedApplication]);
                    [UIApplication sharedApplication] stub_method("applicationState").and_return(UIApplicationStateActive);
                });

                it(@"should report that the ad is viewable", ^{
                    controller.isViewable should equal(YES);
                    [fakeMRBridge containsProperty:[MRViewableProperty propertyWithViewable:YES]] should equal(YES);
                    [fakeMRBridge containsProperty:[MRViewableProperty propertyWithViewable:NO]] should equal(NO);
                });

                it(@"should call updateCurrentPosition", ^{
                    controller should have_received(@selector(updateCurrentPosition));
                });

                it(@"should call updateDefaultPosition", ^{
                    controller should have_received(@selector(updateDefaultPosition));
                });

                it(@"should call updateScreenSize", ^{
                    controller should have_received(@selector(updateScreenSize));
                });

                it(@"should call updateMaxSize", ^{
                    controller should have_received(@selector(updateMaxSize));
                });

                it(@"should call updateEventSizeChange", ^{
                    controller should have_received(@selector(updateEventSizeChange));
                });
            });

            context(@"if the application is in the inactive state", ^{
                beforeEach(^{
                    controller.isViewable = YES;
                    spy_on([UIApplication sharedApplication]);
                    [UIApplication sharedApplication] stub_method("applicationState").and_return(UIApplicationStateInactive);
                });

                it(@"should report that the ad is not viewable", ^{
                    controller.isViewable should equal(NO);
                    [fakeMRBridge containsProperty:[MRViewableProperty propertyWithViewable:NO]] should equal(YES);
                    [fakeMRBridge containsProperty:[MRViewableProperty propertyWithViewable:YES]] should equal(NO);
                });
            });

            context(@"if the application is in the background state", ^{
                beforeEach(^{
                    controller.isViewable = YES;
                    spy_on([UIApplication sharedApplication]);
                    [UIApplication sharedApplication] stub_method("applicationState").and_return(UIApplicationStateBackground);
                });

                it(@"should report that the ad is not viewable", ^{
                    controller.isViewable should equal(NO);
                    [fakeMRBridge containsProperty:[MRViewableProperty propertyWithViewable:NO]] should equal(YES);
                    [fakeMRBridge containsProperty:[MRViewableProperty propertyWithViewable:YES]] should equal(NO);
                });
            });
        });

        context(@"when animating the ad size", ^{
            beforeEach(^{
                controller.isAnimatingAdSize = YES;
            });

            it(@"should not attempt to update the visibility of the view", ^{
                controller should_not have_received(@selector(checkViewability));
            });
            it(@"should not call updateCurrentPosition", ^{
                controller should_not have_received(@selector(updateCurrentPosition));
            });

            it(@"should not call updateDefaultPosition", ^{
                controller should_not have_received(@selector(updateDefaultPosition));
            });

            it(@"should not call updateScreenSize", ^{
                controller should_not have_received(@selector(updateScreenSize));
            });

            it(@"should not call updateMaxSize", ^{
                controller should_not have_received(@selector(updateMaxSize));
            });

            it(@"should not call updateEventSizeChange", ^{
                controller should_not have_received(@selector(updateEventSizeChange));
            });
        });
    });

    describe(@"hasUserInteractedWithWebViewForBridge", ^{
        __block MRController *realController;

        beforeEach(^{
            realController = [[MRController alloc] initWithAdViewFrame:CGRectMake(0, 0, 20, 20) adPlacementType:MRAdViewPlacementTypeInline];
            [realController loadAdWithConfiguration:configuration];
        });

        context(@"when the ad is expanded", ^{
            beforeEach(^{
                realController.currentState = MRAdViewStateExpanded;
            });

            it(@"should return true for hasUserInteractedWithWebViewForBridge", ^{
                in_time(realController.currentState) should equal(MRAdViewStateExpanded);
                [realController hasUserInteractedWithWebViewForBridge:fakeMRBridge] should be_truthy;
            });
        });

        context(@"when the ad is an interstitial", ^{
            beforeEach(^{
                realController = [[MRController alloc] initWithAdViewFrame:CGRectMake(0, 0, 20, 20) adPlacementType:MRAdViewPlacementTypeInterstitial];
            });

            it(@"should return true for hasUserInteractedWithWebViewForBridge", ^{
                realController.currentState should equal(MRAdViewStateDefault);
                [realController hasUserInteractedWithWebViewForBridge:fakeMRBridge] should be_truthy;
            });
        });

        context(@"when the ad is in default state and not an interstitial", ^{
            it(@"should return YES for hasUserInteractedWithWebViewForBridge if the webview has been tapped", ^{
                // First make the view act like it was tapped.
                spy_on(realController.mraidAdView);
                realController.mraidAdView stub_method(@selector(wasTapped)).and_return(YES);
                realController.currentState should equal(MRAdViewStateDefault);
                [realController hasUserInteractedWithWebViewForBridge:fakeMRBridge] should be_truthy;
            });

            it(@"should return NO for hasUserInteractedWithWebViewForBridge if the webview hasn't been tapped", ^{
                // First make the view act like it was tapped.
                spy_on(realController.mraidAdView);
                realController.mraidAdView stub_method(@selector(wasTapped)).and_return(NO);
                realController.currentState should equal(MRAdViewStateDefault);
                [realController hasUserInteractedWithWebViewForBridge:fakeMRBridge] should be_falsy;
            });
        });
    });

    context(@"when orientation changes", ^{

        beforeEach(^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        });

        afterEach(^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        });

        context(@"before the ad view is added to the view heirarchy", ^{
            it(@"should not have orientationDidChange: called on an orientation change", ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
                controller should_not have_received(@selector(orientationDidChange:));
            });
        });

        context(@"after the ad view is added to the view heirarchy", ^{
            beforeEach(^{
                [controller closableView:controller.mraidAdView didMoveToWindow:[UIApplication sharedApplication].keyWindow];
            });

            it(@"should have its currentInterfaceOrientation match the application's interface orientation before rotation", ^{
                controller.currentInterfaceOrientation should equal([UIApplication sharedApplication].statusBarOrientation);
            });

            it(@"should have orientationDidChange: called on an orientation change", ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
                controller should have_received(@selector(orientationDidChange:));
            });

            it(@"should change its currentInterfaceOrientation to the new orientation when the device rotates", ^{
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];
                [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
                controller.currentInterfaceOrientation should equal(UIInterfaceOrientationPortraitUpsideDown);

            });
        });

        context(@"when not animating an mraid expand animation", ^{
            it(@"should update mraid properties", ^{
                controller.isAnimatingAdSize = NO;
                spy_on(controller);
                [controller orientationDidChange:nil];

                controller should have_received(@selector(updateCurrentPosition));
                controller should have_received(@selector(updateDefaultPosition));
                controller should have_received(@selector(updateScreenSize));
                controller should have_received(@selector(updateMaxSize));
                controller should have_received(@selector(updateEventSizeChange));
            });
        });

        context(@"when animating an mraid expand animation", ^{
            it(@"should not update positioning mraid properties but still update the other mraid properties", ^{
                controller.isAnimatingAdSize = YES;
                spy_on(controller);
                [controller orientationDidChange:nil];

                controller should have_received(@selector(updateMRAIDProperties));
            });
        });

        context(@"when the ad is in a resized state", ^{
            it(@"should return to the default state", ^{
                controller.currentState = MRAdViewStateResized;
                controller.isAnimatingAdSize = NO;
                spy_on(controller);
                [controller orientationDidChange:nil];

                controller should have_received(@selector(closeFromResizedState));
                in_time(controller.currentState) should equal(MRAdViewStateDefault);
                controller should have_received(@selector(updateMRAIDProperties));
            });
        });
    });

    context(@"when asked to close from the default state", ^{
        it(@"should let the creative know", ^{
            controller.currentState = MRAdViewStateDefault;
            [controller handleNativeCommandCloseWithBridge:fakeMRBridge];

            [fakeMRBridge containsProperty:[MRStateProperty propertyWithState:MRAdViewStateHidden]] should equal(YES);
        });
    });

    context(@"when asked to close from the resized state", ^{
        beforeEach(^{
            controller.currentState = MRAdViewStateResized;
            [controller handleNativeCommandCloseWithBridge:fakeMRBridge];
        });

        it(@"should let the creative know", ^{
            in_time(controller.currentState) should equal(MRAdViewStateDefault);
            [fakeMRBridge containsProperty:[MRStateProperty propertyWithState:MRAdViewStateDefault]] should equal(YES);
        });

        it(@"should update mraid properties", ^{
            controller should have_received(@selector(updateMRAIDProperties));
        });
    });

    describe(@"expansion", ^{
        __block UIWindow *window;

        beforeEach(^{
            window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            [window makeKeyWindow];
        });

        context(@"when asked to expand with a URL", ^{
            __block FakeMRBridge *fakeDefaultBridge;
            __block FakeMRBridge *fakeTwoPartBridge;

            beforeEach(^{
                // Set the controller's default bridge to something besides the fakeMRBridge since we're testing two bridge methods.
                // Let the two part equal our fakeMRBridge we've been using since the controller will use that for the two part when the
                // two-part is created.
                fakeDefaultBridge = [[FakeMRBridge alloc] initWithWebView:[[MPWebView alloc] init]];
                fakeTwoPartBridge = fakeMRBridge;

                controller.mraidBridge = fakeDefaultBridge;
                [controller bridge:fakeDefaultBridge handleNativeCommandExpandWithURL:[NSURL URLWithString:@"http://www.mopub.com"]
                    useCustomClose:NO];
            });

            it(@"should have autoresizing width and height on mraidAdViewTwoPart.", ^{
                controller.mraidAdViewTwoPart.autoresizingMask should equal(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            });

            it(@"should create the two-part expansion view", ^{
                controller.mraidAdViewTwoPart should_not be_nil;
            });

            it(@"should move the two-part expansion view to the expand modal view controller", ^{
                in_time(controller.mraidAdViewTwoPart.superview) should equal(controller.expandModalViewController.view);
            });

            it(@"should let the creatives know", ^{
                controller.currentState should equal(MRAdViewStateExpanded);

                [fakeDefaultBridge containsProperty:[MRStateProperty propertyWithState:controller.currentState]] should equal(YES);
                [fakeTwoPartBridge containsProperty:[MRStateProperty propertyWithState:controller.currentState]] should equal(YES);
            });

            it(@"should call willBeginAnimatingAdSize", ^{
                in_time(controller) should have_received(@selector(willBeginAnimatingAdSize));
            });

            context(@"when a two part expand is done loading", ^{
                beforeEach(^{
                    [controller bridge:fakeMRBridge didFinishLoadingWebView:webView];
                });

                context(@"when we're already viewable", ^{
                    beforeEach(^{
                        controller.isViewable = YES;
                    });

                    it(@"should tell the two-part bridge that the webview is visible" , ^{
                        [fakeTwoPartBridge containsProperty:[MRViewableProperty propertyWithViewable:YES]] should be_truthy;
                    });
                });

                context(@"when we're not already viewable", ^{
                    beforeEach(^{
                        controller.isViewable = NO;
                    });

                    it(@"should tell the two-part bridge that the webview is visible" , ^{
                        controller should have_received(@selector(updateViewabilityWithBool:)).with(YES);
                    });
                });
            });

            context(@"when asked to close from the expanded state", ^{
                beforeEach(^{
                    [controller handleNativeCommandCloseWithBridge:fakeMRBridge];
                });

                it(@"should not have autoresizing masks on the banner mraidAdView.", ^{
                    in_time(controller.mraidAdView.autoresizingMask) should equal(UIViewAutoresizingNone);
                });

                it(@"should let the default creative know", ^{
                    in_time(controller.currentState) should equal(MRAdViewStateDefault);
                    [fakeDefaultBridge containsProperty:[MRStateProperty propertyWithState:MRAdViewStateDefault]] should equal(YES);
                });

                it(@"should update mraid properties", ^{
                    in_time(controller) should have_received(@selector(updateMRAIDProperties));
                });

                it(@"should call didEndAnimatingAdSize", ^{
                    in_time(controller) should have_received(@selector(didEndAnimatingAdSize));
                });
            });
        });

        context(@"when asked to expand without a URL", ^{
            beforeEach(^{
                [controller bridge:fakeMRBridge handleNativeCommandExpandWithURL:nil
                    useCustomClose:NO];
            });

            it(@"should have autoresizing width and height on mraidAdView.", ^{
                controller.mraidAdView.autoresizingMask should equal(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            });

            it(@"should not create the two-part expansion view", ^{
                controller.mraidAdViewTwoPart should be_nil;
            });

            it(@"should move the view to the expand modal view controller", ^{
                in_time(controller.mraidAdView.superview) should equal(controller.expandModalViewController.view);
            });

            it(@"should call willBeginAnimatingAdSize", ^{
                in_time(controller) should have_received(@selector(willBeginAnimatingAdSize));
            });

            context(@"when asked to close from the expanded state", ^{
                beforeEach(^{
                    [controller handleNativeCommandCloseWithBridge:fakeMRBridge];
                });

                it(@"should not have autoresizing masks on the banner mraidAdView.", ^{
                    controller.mraidAdView.autoresizingMask should equal(UIViewAutoresizingNone);
                });

                it(@"should let the creative know", ^{
                    in_time(controller.currentState) should equal(MRAdViewStateDefault);
                    [fakeMRBridge containsProperty:[MRStateProperty propertyWithState:MRAdViewStateDefault]] should equal(YES);
                });

                it(@"should update mraid properties", ^{
                    in_time(controller) should have_received(@selector(updateMRAIDProperties));
                });

                it(@"should call didEndAnimatingAdSize", ^{
                    in_time(controller) should have_received(@selector(didEndAnimatingAdSize));
                });
            });
        });
    });

    describe(@"resizing", ^{
        __block NSMutableDictionary *resizeParams;
        __block UIWindow *window;

        beforeEach(^{
            resizeParams = [@{@"width":@(320),
                             @"height":@(200),
                             @"offsetX":@(0),
                             @"offsetY":@(20),
                             @"allowOffscreen":@YES,
                             @"customClosePosition":@"top-right"} mutableCopy];

            spy_on(fakeMRBridge);

            window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            UIViewController *rootViewController = [[UIViewController alloc] init];

            // We're forcing this view controller into portrait with a hard coded frame size as resize tests rely heavily on the
            // device's frame and we do not want outside orientation settings affecting the frame.
            spy_on(rootViewController);
            rootViewController stub_method(@selector(supportedInterfaceOrientations)).and_return(UIInterfaceOrientationMaskPortrait);

            [rootViewController.view addSubview:controller.mraidAdView];
            window.rootViewController = rootViewController;
            [window makeKeyWindow];
        });

        context(@"when resizing an ad", ^{
            it(@"controller.mraidAdView should have UIViewAutoresizingNone while resized", ^{
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                in_time(controller.currentState) should equal(MRAdViewStateResized);
                in_time(controller.mraidAdView.autoresizingMask) should equal(UIViewAutoresizingNone);
            });
        });

        context(@"when closing a resized ad", ^{
            beforeEach(^{
                // A little bit hacky approach to setting resized state, but we really just want to test
                // for (absense of) side effects of the close logic so it works.
                controller.currentState = MRAdViewStateResized;
                [controller handleNativeCommandCloseWithBridge:fakeMRBridge];
            });

            it (@"controller.mraidAdView should have UIViewAutoresizing after it's closed", ^{
                in_time(controller.currentState) should equal(MRAdViewStateDefault);
                in_time(controller.mraidAdView.autoresizingMask) should equal(UIViewAutoresizingNone);

            });
        });

        context(@"when asked to resize with different width values", ^{
            it(@"should report an error when width is not present", ^{
                [resizeParams removeObjectForKey:@"width"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should report an error when width is less than 50", ^{
                [resizeParams setObject:@(49) forKey:@"width"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should resize when width is valid", ^{
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
                in_time(controller.currentState) should equal(MRAdViewStateResized);
            });
        });

        context(@"when asked to resize with different height values", ^{
            it(@"should report an error when height is not present", ^{
                [resizeParams removeObjectForKey:@"height"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should report an error when height is less than 50", ^{
                [resizeParams setObject:@(49) forKey:@"height"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should resize when height is valid", ^{
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
                in_time(controller.currentState) should equal(MRAdViewStateResized);
            });
        });

        context(@"when asked to resize with different offsetX values", ^{
            it(@"should report an error when offsetX is not present", ^{
                [resizeParams removeObjectForKey:@"offsetX"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should resize when offsetX is valid", ^{
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
                in_time(controller.currentState) should equal(MRAdViewStateResized);
            });
        });

        context(@"when asked to resize with different offsetY values", ^{
            it(@"should report an error when offsetY is not present", ^{
                [resizeParams removeObjectForKey:@"offsetY"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should resize when offsetY is valid", ^{
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
                in_time(controller.currentState) should equal(MRAdViewStateResized);
            });
        });

        context(@"when asked to resize with different customCloseLocation values", ^{
            it(@"should default to top-right when not included in params", ^{
                [resizeParams removeObjectForKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationTopRight);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should default to top-right when given a garbage value", ^{
                [resizeParams setObject:@"MoPubRules!!!!" forKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationTopRight);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should place button in top right when position is top-right", ^{
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationTopRight);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should place button in top left when position is top-left", ^{
                [resizeParams setObject:@"top-left" forKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationTopLeft);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should place button in top left when position is top-center", ^{
                [resizeParams setObject:@"top-center" forKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationTopCenter);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should place button in top right when position is bottom-right", ^{
                [resizeParams setObject:@"bottom-right" forKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationBottomRight);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should place button in top left when position is bottom-left", ^{
                [resizeParams setObject:@"bottom-left" forKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationBottomLeft);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should place button in top left when position is bottom-center", ^{
                [resizeParams setObject:@"bottom-center" forKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationBottomCenter);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should place button in center when position is center", ^{
                [resizeParams setObject:@"center" forKey:@"customClosePosition"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller.mraidAdView.closeButtonLocation should equal(MPClosableViewCloseButtonLocationCenter);
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });

            it(@"should fire an error when the close button is offscreen", ^{
                [resizeParams setObject:@(300) forKey:@"offsetX"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });
        });

        context(@"when asked to resize with different allowOffscreen values", ^{
            it(@"should allow the ad to be offscreen if the param is not present (defaults to YES)", ^{
                [resizeParams removeObjectForKey:@"allowOffscreen"];
                [resizeParams setObject:@(-100) forKey:@"offsetX"];
                [resizeParams setObject:@(400) forKey:@"width"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
                in_time(controller.currentState) should equal(MRAdViewStateResized);
            });

            it(@"should move the ad to be onscreen if allowOffscreen is NO and it would have been offscreen", ^{
                [resizeParams setObject:@NO forKey:@"allowOffscreen"];
                [resizeParams setObject:@(100) forKey:@"offsetX"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                controller should have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
                in_time(controller.currentState) should equal(MRAdViewStateResized);
            });

            it(@"should fire an error if allowOffscreen is NO and it can't fit the ad onscreen", ^{
                [resizeParams setObject:@NO forKey:@"allowOffscreen"];
                [resizeParams setObject:@(-100) forKey:@"offsetX"];
                [resizeParams setObject:@(400) forKey:@"width"];
                [controller bridge:fakeMRBridge handleNativeCommandResizeWithParameters:resizeParams];
                fakeMRBridge should have_received(@selector(fireErrorEventForAction:withMessage:));
                controller should_not have_received(@selector(animateViewFromDefaultStateToResizedState:withFrame:));
            });
        });
    });

    describe(@"loading an ad configuration", ^{
        context(@"when the MRAID bundle is not available", ^{
            __block MRBundleManager<CedarDouble> *fakeBundleManager;
            __block NSString *HTMLString;

            beforeEach(^{
                spy_on(fakeMRBridge);
                fakeBundleManager = nice_fake_for([MRBundleManager class]);
                fakeBundleManager stub_method("mraidPath").and_return((NSString *)nil);
                fakeProvider.fakeMRBundleManager = fakeBundleManager;

                HTMLString = @"<h1>Hi, dudes!</h1>";
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:nil HTMLString:HTMLString];
                [controller loadAdWithConfiguration:configuration];
            });

//            it(@"should not load the string into its webview", ^{
//                [webView loadedHTMLString] should be_nil;
//            });

            it(@"should use http://ads.mopub.com for the baseURL", ^{
                fakeMRBridge should have_received(@selector(loadHTMLString:baseURL:)).with(HTMLString).and_with([NSURL URLWithString:@"http://ads.mopub.com"]);
            });

            it(@"should tell its delegate that the ad failed to load", ^{
                controllerDelegate should have_received(@selector(adDidFailToLoad:));
            });
        });
    });

    context(@"when an ad finishes loading and appears on the screen", ^{
        beforeEach(^{
            NSString *HTMLString = @"Hello, world!";
            configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:nil
                                                                                 HTMLString:HTMLString];
            [controller loadAdWithConfiguration:configuration];
            [controller bridge:fakeMRBridge didFinishLoadingWebView:webView];
            [window addSubview:controller.mraidAdView];
        });

        it(@"should configure the MRAID JS with the version of the SDK that is being used", ^{
            NSString *expected = [NSString stringWithFormat:@"hostSDKVersion: '%@'", MP_SDK_VERSION];
            fakeMRBridge.changedProperties should contain(expected);
        });
    });

    describe(@"Pre-caching", ^{
        __block NSString *HTMLString;

        context(@"when loading an ad that requires precaching", ^{
            beforeEach(^{
                NSMutableDictionary *headers = [MPAdConfigurationFactory defaultInterstitialHeaders];
                headers[kPrecacheRequiredKey] = @YES;

                controller = [[FakeMRController alloc] initWithAdViewFrame:CGRectMake(0, 0, 20, 20) adPlacementType:MRAdViewPlacementTypeInterstitial];
                controller.delegate = controllerDelegate;
                fakeMRBridge.delegate = controller;

                HTMLString = @"<script src='ad.js'></script>";
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers HTMLString:HTMLString];
                [controller loadAdWithConfiguration:configuration];
            });

            it(@"should not notify the delegate when the webview finishes loading", ^{
                [fakeMRBridge webViewDidFinishLoad:webView];

                controllerDelegate should_not have_received(@selector(adDidLoad:));
            });

            it(@"should notify the delegate when the pre-cache complete URL is sent", ^{
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"mopub://precacheComplete"]];
                [fakeMRBridge webView:webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

                controllerDelegate should have_received(@selector(adDidLoad:));
            });

            it(@"should notify the delegate when the rewarded video finished playing", ^{
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"mopub://rewardedVideoEnded"]];
                [fakeMRBridge webView:webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

                controllerDelegate should have_received(@selector(rewardedVideoEnded));
            });
        });
    });

    describe(@"when performing URL navigation", ^{
        __block NSURL *URL;

        context(@"when the scheme is mopub://", ^{
            it(@"should not load anything", ^{
                URL = [NSURL URLWithString:@"mopub://close"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });

            it(@"should notify the delegate when the url is failLoad", ^ {
                URL = [NSURL URLWithString:@"mopub://failLoad"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);

                controllerDelegate should have_received(@selector(adDidFailToLoad:));
            });
        });

        context(@"when the scheme is ios-log://", ^{
            it(@"should not load anything", ^{
                URL = [NSURL URLWithString:@"ios-log://something.to.be.printed"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });
        });

        context(@"when the scheme is not tel or telprompt", ^{
            it(@"should not attempt to display the alert view (by calling show on the MPTelephoneConfirmationController)", ^{
                URL = [NSURL URLWithString:@"tel://5555555555"];
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;

                URL = [NSURL URLWithString:@"twitter://food"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;

                URL = [NSURL URLWithString:@"http://www.ddf.com"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;

                URL = [NSURL URLWithString:@"apple://pear"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;
            });
        });

        context(@"when the scheme is tel://", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"tel://5555555555"];
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;
            });

            it(@"should not load anything", ^{
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
            });

            it(@"should attempt to display the alert view (by calling show on the MPTelephoneConfirmationController)", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                [UIAlertView currentAlertView] should be_nil;
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                UIAlertView *currentAlert = [UIAlertView currentAlertView];
                currentAlert.numberOfButtons should equal(2);
                currentAlert.title should_not be_nil;
                currentAlert.message should_not be_nil;
            });
        });

        context(@"when the scheme is telPrompt://", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"telPrompt://5555555555"];
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;
            });

            it(@"should not load anything", ^{
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
            });

            it(@"should attempt to display the alert view (by calling show on the MPTelephoneConfirmationController)", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                [UIAlertView currentAlertView] should be_nil;
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                UIAlertView *currentAlert = [UIAlertView currentAlertView];
                currentAlert.numberOfButtons should equal(2);
                currentAlert.title should_not be_nil;
                currentAlert.message should_not be_nil;
            });
        });

        context(@"when told to stop handling requests and the ad hasn't been tapped", ^{
            beforeEach(^{
                [controller disableRequestHandling];
                URL = [NSURL URLWithString:@"mraid://close"];
            });

            it(@"should never load anything", ^{
                controller stub_method(@selector(hasUserInteractedWithWebViewForBridge:)).and_return(NO);
                [fakeMRBridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                controllerDelegate should_not have_received(@selector(adDidClose:));
            });

            it(@"should tell its destination display agent to cancel any open url requests", ^{
                destinationDisplayAgent should have_received(@selector(cancel));
            });

            context(@"when told to continue handling requests and has tapped the ad", ^{
                it(@"should load things again", ^{
                    controller stub_method(@selector(hasUserInteractedWithWebViewForBridge:)).and_return(YES);
                    [controller enableRequestHandling];
                    [fakeMRBridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    controllerDelegate should have_received(@selector(adDidClose:)).with(controller.mraidAdView);
                });
            });
        });

        context(@"when loading a deeplink", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"dontgohere://noway.com"];
                spy_on(controller);
            });

            it(@"should not load the deeplink without user interaction", ^{
                controller.userInteractedWithWebViewOverride = NO;
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });

            it(@"should load the deeplink if nav type is clicked but our gesture recognizer hasn't responded yet", ^{
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(YES);
            });

            it(@"should load the deeplink with user interaction", ^{
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
            });

            it(@"should load about scheme without user interaction", ^{
                controller.userInteractedWithWebViewOverride = NO;
                URL = [NSURL URLWithString:@"about:blahblahblah"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
            });
        });

        context(@"when the creative hasn't finished loading", ^{
            __block NSString *HTMLString;

            beforeEach(^{
                HTMLString = @"<h1>Hi, dudes!</h1>";
                configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:nil HTMLString:HTMLString];
                [controller loadAdWithConfiguration:configuration];
                spy_on(controller);
            });

            context(@"when the MRAID bundle is available", ^{
//                it(@"should load the URL in the webview", ^{
//                    URL = [NSURL URLWithString:@"http://www.donuts.com"];
//                    [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
//                    in_time(webView.loadedHTMLString) should contain(HTMLString);
//                });

                context(@"when the creative finishes loading", ^{
                    __block NSMutableURLRequest *request;
                    beforeEach(^{
                        URL = [NSURL URLWithString:@"http://www.donuts.com"];
                        request = [NSMutableURLRequest requestWithURL:URL];
                        request.mainDocumentURL = URL;
                        [fakeMRBridge webViewDidFinishLoad:nil];
                    });

                    context(@"when the banner ad is moved into the view hierarchy", ^{
                        beforeEach(^{
                            UIWindow *window = [[UIWindow alloc] init];
                            [window addSubview:controller.mraidAdView];
                        });

                        it(@"should initialize some properties on the MRAID JavaScript bridge and fire the ready event", ^{
                            [fakeMRBridge containsProperty:[MRStateProperty propertyWithState:MRAdViewStateDefault]] should equal(YES);
                            [fakeMRBridge containsProperty:[MRSupportsProperty defaultProperty]] should equal(YES);
                            fakeMRBridge.didFireReadyEvent should equal(YES);
                        });

                        it(@"should check if the ad is visible", ^{
                            controller should have_received(@selector(checkViewability));
                        });

                        it(@"should initialize the ad for mraid", ^{
                            controller should have_received(@selector(initializeLoadedAdForBridge:)).with(fakeMRBridge);
                        });

                        it(@"should forcefully trigger updating mraid properties", ^{
                            controller should have_received(@selector(updateMRAIDProperties));
                        });
                    });

                    context(@"when the interstitial ad is moved into the view hierarchy", ^{
                        beforeEach(^{
                            // A quick hack to make the controller think it has an interstitial.
                            controller.placementType = MRAdViewPlacementTypeInterstitial;
                            UIWindow *window = [[UIWindow alloc] init];
                            [window addSubview:controller.mraidAdView];
                        });

                        it(@"should initialize some properties on the MRAID JavaScript bridge and fire the ready event", ^{
                            [fakeMRBridge containsProperty:[MRStateProperty propertyWithState:MRAdViewStateDefault]] should equal(YES);
                            [fakeMRBridge containsProperty:[MRSupportsProperty defaultProperty]] should equal(YES);
                            fakeMRBridge.didFireReadyEvent should equal(YES);
                        });

                        it(@"should check if the ad is visible", ^{
                            controller should have_received(@selector(checkViewability));
                        });

                        it(@"should initialize the ad for mraid", ^{
                            controller should have_received(@selector(initializeLoadedAdForBridge:)).with(fakeMRBridge);
                        });

                        it(@"should forcefully trigger updating mraid properties", ^{
                            controller should have_received(@selector(updateMRAIDProperties));
                        });
                    });

                    context(@"when the navigation type is other", ^{
                        it(@"should ask the destination display agent to load the URL", ^{
                            [fakeMRBridge webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                            destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                        });
                    });

                    context(@"when the navigation type is clicked", ^{
                        it(@"should ask the destination display agent to load the URL", ^{
                            [fakeMRBridge webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                            destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                        });
                    });

                    context(@"when the requested URL is an iframe", ^{
                        it(@"should not ask the destionation display agent to load the URL", ^{
                            NSURL *documentURL = [NSURL URLWithString:@"http://www.donuts.com"];
                            NSURL *iframeURL = [NSURL URLWithString:@"http://www.jelly.com"];
                            NSMutableURLRequest *iframeURLRequest = [NSMutableURLRequest requestWithURL:iframeURL];
                            iframeURLRequest.mainDocumentURL = documentURL;
                            [fakeMRBridge webView:nil shouldStartLoadWithRequest:iframeURLRequest navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });

                        it(@"should not load a deeplink without user interaction", ^{
                            controller.userInteractedWithWebViewOverride = NO;

                            NSURL *documentURL = [NSURL URLWithString:@"http://www.donuts.com"];
                            NSURL *iframeURL = [NSURL URLWithString:@"dontgohere://www.jelly.com"];
                            NSMutableURLRequest *iframeURLRequest = [NSMutableURLRequest requestWithURL:iframeURL];
                            iframeURLRequest.mainDocumentURL = documentURL;
                            [fakeMRBridge webView:nil shouldStartLoadWithRequest:iframeURLRequest navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });
                    });

                    context(@"when the navigation type is anything else", ^{
                        it(@"should ask the destination display agent to load the URL", ^{
                            [fakeMRBridge webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeReload] should equal(YES);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });
                    });
                });
            });
        });
    });

    describe(@"handling MRAID commands", ^{
        __block NSURL *URL;

        beforeEach(^{
            [fakeMRBridge.errorEvents removeAllObjects];
            fakeMRBridge.lastCompletedCommand = nil;
        });

        context(@"when the command is invalid", ^{
            it(@"should tell its delegate that the command could not be executed", ^{
                URL = [NSURL URLWithString:@"mraid://invalid"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                fakeMRBridge.errorEvents.count should equal(1);
            });
        });

        context(@"when the command is 'playVideo'", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
            });

            it(@"should tell its video manager to play the video", ^{
                videoPlayerManager should have_received(@selector(playVideo:)).with([NSURL URLWithString:@"a_video"]);
            });

            context(@"when the video cannot be played", ^{
                it(@"should emit a JavaScript error event", ^{
                    [fakeMRBridge.nativeCommandHandler videoPlayerManager:videoPlayerManager didFailToPlayVideoWithErrorMessage:@"message"];
                    fakeMRBridge.errorEvents should contain(@"playVideo");
                });
            });

            context(@"when the video is about to appear on-screen", ^{
                beforeEach(^{
                    [fakeMRBridge.nativeCommandHandler videoPlayerManagerWillPresentVideo:videoPlayerManager];
                });

                it(@"should tell its delegate that modal content will be presented", ^{
                    controllerDelegate should have_received(@selector(appShouldSuspendForAd:)).with(controller.mraidAdView);
                });

                it(@"should present the video player from the proper view controller", ^{
                    UIViewController *viewController = [fakeMRBridge.nativeCommandHandler viewControllerForPresentingVideoPlayer];
                    viewController should_not be_nil;
                    viewController should be_same_instance_as(presentingViewController);
                });

                context(@"when the video has finished playing", ^{
                    it(@"should tell its delegate that modal content has been dismissed", ^{
                        [fakeMRBridge.nativeCommandHandler videoPlayerManagerDidDismissVideo:videoPlayerManager];
                        controllerDelegate should have_received(@selector(appShouldResumeFromAd:)).with(controller.mraidAdView);
                    });
                });
            });
        });

        context(@"when the command is 'playVideo' and the user did not tap the banner webview", ^{
            it(@"should NOT tell its video manager to play the video", ^{
                controller.userInteractedWithWebViewOverride = NO;
                URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                videoPlayerManager should_not have_received(@selector(playVideo:));
            });
        });

        context(@"when the command is 'playVideo' from an interstitial", ^{
            context(@"when the user did not click the webview", ^{
                beforeEach(^{
                    controller = [[FakeMRController alloc] initWithAdViewFrame:CGRectMake(0, 0, 20, 20) adPlacementType:MRAdViewPlacementTypeInterstitial];
                    controller.delegate = controllerDelegate;
                    spy_on(controller);

                    fakeMRBridge.delegate = controller;
                    fakeMRBridge.shouldHandleRequests = YES;
                    controller.userInteractedWithWebViewOverride = NO;
                });

                it(@"should tell its video manager to play the video", ^{
                    URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                    [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                    videoPlayerManager should have_received(@selector(playVideo:));
                });
            });

            context(@"when the user did click the webview", ^{
                beforeEach(^{
                    controller.userInteractedWithWebViewOverride = YES;
                });

                it(@"should tell its video manager to play the video", ^{
                    URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                    [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                    videoPlayerManager should have_received(@selector(playVideo:));
                });
            });
        });

        context(@"when the command is 'setOrientationProperties", ^{
            __block UIApplication *sharedApplication;
            __block UIViewController *rootViewController;

            beforeEach(^{
                sharedApplication = [UIApplication sharedApplication];
                spy_on(sharedApplication);

                rootViewController = [[UIViewController alloc] init];
                window.rootViewController = rootViewController;
                [window makeKeyWindow];

                URL = [NSURL URLWithString:@"mraid://setOrientationProperties?allowOrientationChange=false&forceOrientation=landscape"];
            });

            context(@"when our ad is an expanded banner", ^{
                __block MRExpandModalViewController *expandViewController;

                beforeEach(^{
                    controller.placementType = MRAdViewPlacementTypeInline;
                    controller.currentState = MRAdViewStateExpanded;
                    controller.mraidBridge.shouldHandleRequests = YES;

                    expandViewController = [[MRExpandModalViewController alloc] init];
                    controller.expandModalViewController = expandViewController;

                    [rootViewController presentViewController:expandViewController animated:NO completion:NULL];
                });

                context(@"when the app doesn't support the force orientation", ^{
                    beforeEach(^{
                        sharedApplication stub_method(@selector(mp_supportsOrientationMask:)).and_return(NO);

                        [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
                    });

                    it(@"should not attempt to force the orientation", ^{
                        controller should_not have_received(@selector(presentExpandModalViewControllerWithView:animated:completion:));
                    });
                });

                context(@"when the app supports the force orientation", ^{
                    beforeEach(^{
                        sharedApplication stub_method(@selector(mp_supportsOrientationMask:)).and_return(YES);
                    });

                    it(@"should not attempt to force the orientation", ^{
                        [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
                        controller should have_received(@selector(presentExpandModalViewControllerWithView:animated:completion:));
                    });

                    it(@"should nil out the forceOrientationAfterAnimationBlock", ^{
                        // Give the controller a random forceOrientationAfterAnimationBlock so we can determine if it gets set to nil when setOrientationProperties is called.
                        controller.forceOrientationAfterAnimationBlock = ^{
                            NSLog(@"hello");
                        };

                        [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
                        controller.forceOrientationAfterAnimationBlock should be_nil;
                    });

                    context(@"when the ad is currently animating", ^{
                        beforeEach(^{
                            controller.mraidBridge.shouldHandleRequests = NO;
                            [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
                        });

                        it(@"should create a block to execute the force orientation", ^{
                            controller.forceOrientationAfterAnimationBlock should_not be_nil;
                        });

                        it(@"should execute the block after the animation completes", ^{
                            [(id<CedarDouble>)controller reset_sent_messages];
                            controller should_not have_received(@selector(bridge:handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:));
                            [controller enableRequestHandling];
                            [controller handleMRAIDInterstitialDidPresentWithViewController:nil];
                            controller should have_received(@selector(bridge:handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:));
                            controller.forceOrientationAfterAnimationBlock should be_nil;
                        });
                    });

                });
            });

            context(@"when our ad type is interstitial", ^{
                __block UIViewController<CedarDouble> *presentingViewController;
                __block MPMRAIDInterstitialViewController *interstitialViewController;

                beforeEach(^{
                    presentingViewController = nice_fake_for([UIViewController class]);
                    interstitialViewController = [[MPMRAIDInterstitialViewController alloc] init];
                    spy_on(interstitialViewController);
                    interstitialViewController stub_method(@selector(presentingViewController)).and_return(presentingViewController);

                    controller.interstitialViewController = interstitialViewController;
                    controller.placementType = MRAdViewPlacementTypeInterstitial;

                    [rootViewController presentViewController:interstitialViewController animated:NO completion:NULL];
                });

                context(@"when the app doesn't support the force orientation", ^{
                    beforeEach(^{
                        sharedApplication stub_method(@selector(mp_supportsOrientationMask:)).and_return(NO);

                        controller.mraidBridge.shouldHandleRequests = YES;

                        [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
                    });

                    it(@"should not attempt to force the orientation", ^{
                        // We dismiss and then present the same view controller to force orientation. So we make sure we don't observe
                        // those methods after forcing the orientation.
                        controller.interstitialViewController should_not have_received(@selector(dismissViewControllerAnimated:completion:));
                        presentingViewController should_not have_received(@selector(presentViewController:animated:completion:));
                    });
                });

                context(@"when the app supports the force orientation", ^{
                    beforeEach(^{
                        sharedApplication stub_method(@selector(mp_supportsOrientationMask:)).and_return(YES);

                        controller.mraidBridge.shouldHandleRequests = YES;
                    });

                    it(@"should attempt to force the orientation", ^{
                        [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        // We dismiss and then present the same view controller to force orientation. We make sure we observe these methods to verify that we have forced orientation.
                        controller.interstitialViewController should have_received(@selector(dismissViewControllerAnimated:completion:));
                        presentingViewController should have_received(@selector(presentViewController:animated:completion:));
                    });

                    it(@"should nil out the forceOrientationAfterAnimationBlock", ^{
                        // Give the controller a random forceOrientationAfterAnimationBlock so we can determine if it gets set to nil when setOrientationProperties is called.
                        controller.forceOrientationAfterAnimationBlock = ^{
                            NSLog(@"hello");
                        };

                        [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
                        controller.forceOrientationAfterAnimationBlock should be_nil;
                    });

                    context(@"when the ad is currently animating", ^{
                        beforeEach(^{
                            controller.mraidBridge.shouldHandleRequests = NO;
                            [fakeMRBridge webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
                        });

                        it(@"should create a block to execute the force orientation", ^{
                            controller.forceOrientationAfterAnimationBlock should_not be_nil;
                        });

                        it(@"should execute the block after the animation completes", ^{
                            [(id<CedarDouble>)controller reset_sent_messages];
                            controller should_not have_received(@selector(bridge:handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:));
                            [controller enableRequestHandling];
                            [controller handleMRAIDInterstitialDidPresentWithViewController:nil];
                            controller should have_received(@selector(bridge:handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:));
                            controller.forceOrientationAfterAnimationBlock should be_nil;
                        });
                    });
                });
            });
        });
    });

    describe(@"mraid://open", ^{
        context(@"when the ad is in the default state", ^{
            it(@"should ask the destination display agent to load the URL", ^{
                NSURL *URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [controller bridge:fakeMRBridge handleDisplayForDestinationURL:URL];
                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
            });
        });

        context(@"when the ad is in the expanded state", ^{
            __block NSURL *URL;

            beforeEach(^{
                NSURL *expandCommandURL = [NSURL URLWithString:@"mraid://expand"];
                NSURLRequest *expandRequest = [NSURLRequest requestWithURL:expandCommandURL];
                [fakeMRBridge webView:nil
         shouldStartLoadWithRequest:expandRequest
                     navigationType:UIWebViewNavigationTypeOther];

                URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [controller bridge:fakeMRBridge handleDisplayForDestinationURL:URL];
            });

            it(@"should add the ad view as a subview of the expand modal view controller view", ^{
                in_time([controller.expandModalViewController.view subviews]) should contain(controller.mraidAdView);
            });

            it(@"should ask the destination display agent to load the URL", ^{
                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
            });

            context(@"when the destination display agent presents a modal view controller", ^{
                beforeEach(^{
                    [controller displayAgentWillPresentModal];
                });

                context(@"when the modal view controller is dismissed", ^{
                    beforeEach(^{
                        [controller displayAgentDidDismissModal];
                    });

                    it(@"should not tell the delegate that the ad has been dismissed", ^{
                        controllerDelegate should_not have_received(@selector(appShouldResumeFromAd:));
                    });
                });
            });
        });

        context(@"when the ad is in a resized state", ^{
            __block NSURL *URL;

            beforeEach(^{
                [controller setCurrentState:MRAdViewStateResized];
                URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [controller bridge:fakeMRBridge handleDisplayForDestinationURL:URL];
            });

            it(@"should ask the destination display agent to load the URL", ^{
                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
            });

            context(@"when the destination display agent presents a modal view controller", ^{
                beforeEach(^{
                    [controller displayAgentWillPresentModal];
                });

                context(@"when the modal view controller is dismissed", ^{
                    beforeEach(^{
                        [controller displayAgentDidDismissModal];
                    });

                    it(@"should not tell the delegate that the ad has been dismissed", ^{
                        controllerDelegate should_not have_received(@selector(appShouldResumeFromAd:));
                    });
                });
            });
        });
    });

    describe(@"MPAdDestinationDisplayAgentDelegate", ^{
        context(@"when asked for a view controller to present modal views", ^{
            it(@"should ask the MRAdViewDelegate for one", ^{
                [controller viewControllerForPresentingModalView] should equal(presentingViewController);
            });
        });

        context(@"when a modal is presented", ^{
            beforeEach(^{
                [controller displayAgentWillPresentModal];
            });

            it(@"should tell the delegate", ^{
                controllerDelegate should have_received(@selector(appShouldSuspendForAd:)).with(controller.mraidAdView);
            });

            context(@"when the modal is dismissed", ^{
                it(@"should tell the delegate", ^{
                    [controller displayAgentDidDismissModal];
                    controllerDelegate should have_received(@selector(appShouldResumeFromAd:)).with(controller.mraidAdView);
                });
            });
        });
    });

    describe(@"updating size event", ^{
        __block CGRect newFrame;
        __block CGRect currentFrame;

        beforeEach(^{
            currentFrame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
            controller.currentAdSize = currentFrame.size;
            spy_on(fakeMRBridge);
        });

        context(@"when the size hasn't changed", ^{
            beforeEach(^{
                newFrame = currentFrame;
                controller stub_method(@selector(activeAdFrameInScreenSpace)).and_return(newFrame);

                [controller updateMRAIDProperties];
            });

            it(@"should not tell the bridge the size has changed", ^{
                fakeMRBridge should_not have_received(@selector(fireSizeChangeEvent:));
            });
        });

        context(@"when the size has changed", ^{
            beforeEach(^{
                newFrame = CGRectMake(0.0f, 0.0f, 100.0f, 50.0f);
                controller stub_method(@selector(activeAdFrameInScreenSpace)).and_return(newFrame);

                [controller updateMRAIDProperties];
            });

            it(@"should tell the bridge the size has changed", ^{
                fakeMRBridge should have_received(@selector(fireSizeChangeEvent:)).with(newFrame.size);
            });
        });
    });

});

SPEC_END

#pragma clang diagnostic pop
