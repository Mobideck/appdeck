#import "MRAdView.h"
#import "MPAdDestinationDisplayAgent.h"
#import "FakeMRJavaScriptEventEmitter.h"
#import "MRProperty.h"
#import "MRBundleManager.h"
#import "UIWebView+MPAdditions.h"
#import "MRAdView_MPSpecs.h"
#import "MRAdViewDisplayController.h"
#import "UIApplication+MPSpecs.h"
#import "CedarAsync.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MRAdView ()

@property (nonatomic, assign) BOOL userInteractedWithWebView;

@end

SPEC_BEGIN(MRAdViewSpec)

describe(@"MRAdView", ^{
    __block MRAdView *view;
    __block id<CedarDouble, MRAdViewDelegate> delegate;
    __block MPAdDestinationDisplayAgent<CedarDouble> *destinationDisplayAgent;
    __block FakeMRJavaScriptEventEmitter *jsEventEmitter;
    __block MRCalendarManager<CedarDouble> *calendarManager;
    __block MRPictureManager<CedarDouble> *pictureManager;
    __block MRVideoPlayerManager<CedarDouble> *videoPlayerManager;
    __block UIWebView *webView;
    __block UIViewController *presentingViewController;
    __block UIWindow *window;

    beforeEach(^{
        webView = [[UIWebView alloc] init];
        fakeProvider.fakeUIWebView = webView;

        destinationDisplayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
        fakeCoreProvider.fakeMPAdDestinationDisplayAgent = destinationDisplayAgent;

        jsEventEmitter = [[FakeMRJavaScriptEventEmitter alloc] initWithWebView:nil];
        fakeProvider.fakeMRJavaScriptEventEmitter = jsEventEmitter;

        calendarManager = nice_fake_for([MRCalendarManager class]);
        fakeProvider.fakeMRCalendarManager = calendarManager;

        pictureManager = nice_fake_for([MRPictureManager class]);
        fakeProvider.fakeMRPictureManager = pictureManager;

        videoPlayerManager = nice_fake_for([MRVideoPlayerManager class]);
        fakeProvider.fakeMRVideoPlayerManager = videoPlayerManager;

        presentingViewController = [[UIViewController alloc] init];

        view = [[MPInstanceProvider sharedProvider] buildMRAdViewWithFrame:CGRectMake(0, 0, 320, 50)
                                                           allowsExpansion:YES
                                                          closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                             placementType:MRAdViewPlacementTypeInline
                                                                  delegate:nil];
        view.userInteractedWithWebView = YES;

        delegate = nice_fake_for(@protocol(MRAdViewDelegate));
        delegate stub_method("viewControllerForPresentingModalView").and_return(presentingViewController);
        view.delegate = delegate;

        window = [[UIWindow alloc] init];
        [window makeKeyAndVisible];
    });

    afterEach(^{
        [window resignKeyWindow];
    });

    describe(@"loading an HTML string", ^{
        __block NSString *HTMLString;

        context(@"when the string is a 'fragment' without <html>, <head>, or MRAID <script> tags", ^{
            beforeEach(^{
                HTMLString = @"<script src='ad.js'></script>";
                [view loadCreativeWithHTMLString:HTMLString baseURL:nil];
            });

            it(@"should wrap the string with the requisite tags before loading it", ^{
                NSString *loadedHTMLString = [webView loadedHTMLString];
                loadedHTMLString should_not be_nil;

                // Must contain the original string.
                loadedHTMLString should contain(HTMLString);

                // Must be wrapped in an HTML tag.
                loadedHTMLString should contain(@"<html>");
                loadedHTMLString should contain(@"</html>");

                // Must have a head tag.
                loadedHTMLString should contain(@"<head>");
                loadedHTMLString should contain(@"</head>");

                // Must have an MRAID script tag.
                loadedHTMLString should contain(@"mraid.js");
            });

            describe(@"javascript dialog disabled", ^{
                it(@"should have executed the dialog disabling javascript", ^{
                    NSArray *executedJS = [webView executedJavaScripts];
                    executedJS.count should equal(1);

                    NSString *dialogDisableJS = [executedJS objectAtIndex:0];
                    dialogDisableJS should equal(kJavaScriptDisableDialogSnippet);
                });
            });
        });

        context(@"when the MRAID bundle is not available", ^{
            __block MRBundleManager<CedarDouble> *fakeBundleManager;

            beforeEach(^{
                fakeBundleManager = fake_for([MRBundleManager class]);
                fakeBundleManager stub_method("mraidPath").and_return((NSString *)nil);
                fakeProvider.fakeMRBundleManager = fakeBundleManager;

                NSString *HTMLString = @"<h1>Hi, dudes!</h1>";
                [view loadCreativeWithHTMLString:HTMLString baseURL:nil];
            });

            it(@"should not load the string into its webview", ^{
                [webView loadedHTMLString] should be_nil;
            });

            it(@"should tell its delegate that the ad failed to load", ^{
                delegate should have_received(@selector(adDidFailToLoad:));
            });
        });
    });

    describe(@"Pre-caching", ^{
        __block NSString *HTMLString;

        context(@"when loading an ad that requires precaching", ^{
            beforeEach(^{
                view.adType = MRAdViewAdTypePreCached;

                HTMLString = @"<script src='ad.js'></script>";
                [view loadCreativeWithHTMLString:HTMLString baseURL:nil];
            });

            it(@"should not notify the delegate when the webview finishes loading", ^{
                [view webViewDidFinishLoad:nil];

                delegate should_not have_received(@selector(adDidLoad:));
            });

            it(@"should notify the delegate when the pre-cache complete URL is sent", ^{
                [view performActionForMoPubSpecificURL:[NSURL URLWithString:@"mopub://precacheComplete"]];

                delegate should have_received(@selector(adDidLoad:));
            });
        });
    });

    describe(@"when performing URL navigation", ^{
        __block NSURL *URL;

        context(@"when the scheme is mopub://", ^{
            it(@"should not load anything", ^{
                URL = [NSURL URLWithString:@"mopub://close"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });
        });

        context(@"when the scheme is ios-log://", ^{
            it(@"should not load anything", ^{
                URL = [NSURL URLWithString:@"ios-log://something.to.be.printed"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });
        });

        context(@"when the scheme is not tel or telprompt", ^{
            it(@"should not attempt to display the alert view (by calling show on the MPTelephoneConfirmationController)", ^{
                URL = [NSURL URLWithString:@"tel://5555555555"];
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;
                view = [[MPInstanceProvider sharedProvider] buildMRAdViewWithFrame:CGRectMake(0, 0, 320, 50)
                                                                   allowsExpansion:YES
                                                                  closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                     placementType:MRAdViewPlacementTypeInline
                                                                          delegate:nil];
                view.userInteractedWithWebView = YES;

                URL = [NSURL URLWithString:@"twitter://food"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;

                URL = [NSURL URLWithString:@"http://www.ddf.com"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;

                URL = [NSURL URLWithString:@"apple://pear"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;
            });
        });

        context(@"when the scheme is tel://", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"tel://5555555555"];
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;
                view = [[MPInstanceProvider sharedProvider] buildMRAdViewWithFrame:CGRectMake(0, 0, 320, 50)
                                                                   allowsExpansion:YES
                                                                  closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                     placementType:MRAdViewPlacementTypeInline
                                                                          delegate:nil];
                view.userInteractedWithWebView = YES;
            });

            it(@"should not load anything", ^{
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
            });

            it(@"should attempt to display the alert view (by calling show on the MPTelephoneConfirmationController)", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                [UIAlertView currentAlertView] should be_nil;
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
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
                view = [[MPInstanceProvider sharedProvider] buildMRAdViewWithFrame:CGRectMake(0, 0, 320, 50)
                                                                   allowsExpansion:YES
                                                                  closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                     placementType:MRAdViewPlacementTypeInline
                                                                          delegate:nil];
                view.userInteractedWithWebView = YES;
            });

            it(@"should not load anything", ^{
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
            });

            it(@"should attempt to display the alert view (by calling show on the MPTelephoneConfirmationController)", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                [UIAlertView currentAlertView] should be_nil;
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                UIAlertView *currentAlert = [UIAlertView currentAlertView];
                currentAlert.numberOfButtons should equal(2);
                currentAlert.title should_not be_nil;
                currentAlert.message should_not be_nil;
            });
        });

        context(@"when told to stop handling requests", ^{
            beforeEach(^{
                [view disableRequestHandling];
                URL = [NSURL URLWithString:@"mraid://close"];
            });

            it(@"should never load anything", ^{
                [view webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                delegate should_not have_received(@selector(adDidClose:));
            });

            it(@"should tell its destination display agent to cancel any open url requests", ^{
                destinationDisplayAgent should have_received(@selector(cancel));
            });

            context(@"when told to continue handling requests", ^{
                it(@"should load things again", ^{
                    [view enableRequestHandling];
                    [view webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidClose:)).with(view);
                });
            });
        });

        context(@"when loading a deeplink", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"dontgohere://noway.com"];
            });

            it(@"should not load the deeplink without user interaction", ^{
                view.userInteractedWithWebView = NO;
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });

            it(@"should load the deeplink if nav type is clicked but our gesture recognizer hasn't responded yet", ^{
                view.userInteractedWithWebView = NO;
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(YES);
            });

            it(@"should load the deeplink with user interaction", ^{
                view.userInteractedWithWebView = YES;
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
            });

            it(@"should load about scheme without user interaction", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"about:blahblahblah"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
            });
        });

        context(@"when the creative hasn't finished loading", ^{
            __block NSString *HTMLString;

            beforeEach(^{
                HTMLString = @"<h1>Hi, dudes!</h1>";
                [view loadCreativeWithHTMLString:HTMLString baseURL:nil];
            });

            context(@"when the MRAID bundle is available", ^{
                it(@"should load the URL in the webview", ^{
                    URL = [NSURL URLWithString:@"http://www.donuts.com"];
                    [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                    [webView loadedHTMLString] should contain(HTMLString);
                });

                context(@"when the creative finishes loading", ^{
                    __block NSMutableURLRequest *request;
                    beforeEach(^{
                        URL = [NSURL URLWithString:@"http://www.donuts.com"];
                        request = [NSMutableURLRequest requestWithURL:URL];
                        request.mainDocumentURL = URL;
                        [view webViewDidFinishLoad:nil];
                    });

                    it(@"should initialize some properties on the MRAID JavaScript bridge", ^{
                        [jsEventEmitter containsProperty:[MRStateProperty propertyWithState:MRAdViewStateDefault]] should equal(YES);
                        [jsEventEmitter containsProperty:[MRSupportsProperty defaultProperty]] should equal(YES);
                        [jsEventEmitter containsProperty:[MRScreenSizeProperty propertyWithSize:[[UIScreen mainScreen] applicationFrame].size]] should equal(YES);
                        jsEventEmitter.didFireReadyEvent should equal(YES);
                    });

                    context(@"when the navigation type is other", ^{
                        it(@"should ask the destination display agent to load the URL", ^{
                            [view webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                            destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                        });
                    });

                    context(@"when the navigation type is clicked", ^{
                        it(@"should ask the destination display agent to load the URL", ^{
                            [view webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                            destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                        });
                    });

                    context(@"when the requested URL is an iframe", ^{
                        it(@"should not ask the destionation display agent to load the URL", ^{
                            NSURL *documentURL = [NSURL URLWithString:@"http://www.donuts.com"];
                            NSURL *iframeURL = [NSURL URLWithString:@"http://www.jelly.com"];
                            NSMutableURLRequest *iframeURLRequest = [NSMutableURLRequest requestWithURL:iframeURL];
                            iframeURLRequest.mainDocumentURL = documentURL;
                            [view webView:nil shouldStartLoadWithRequest:iframeURLRequest navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });

                        it(@"should not load a deeplink without user interaction", ^{
                            view.userInteractedWithWebView = NO;

                            NSURL *documentURL = [NSURL URLWithString:@"http://www.donuts.com"];
                            NSURL *iframeURL = [NSURL URLWithString:@"dontgohere://www.jelly.com"];
                            NSMutableURLRequest *iframeURLRequest = [NSMutableURLRequest requestWithURL:iframeURL];
                            iframeURLRequest.mainDocumentURL = documentURL;
                            [view webView:nil shouldStartLoadWithRequest:iframeURLRequest navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });
                    });

                    context(@"when the navigation type is anything else", ^{
                        it(@"should ask the destination display agent to load the URL", ^{
                            [view webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeReload] should equal(YES);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });
                    });
                });
            });
        });
    });

    describe(@"handling MRAID commands", ^{
        __block NSURL *URL;
        __block MRAdViewDisplayController<CedarDouble> *adDisplayController;

        beforeEach(^{
            adDisplayController = nice_fake_for([MRAdViewDisplayController class]);
            view.displayController = adDisplayController;

            [jsEventEmitter.errorEvents removeAllObjects];
            jsEventEmitter.lastCompletedCommand = nil;
        });

        context(@"when the command is invalid", ^{
            it(@"should tell its delegate that the command could not be executed", ^{
                URL = [NSURL URLWithString:@"mraid://invalid"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                jsEventEmitter.errorEvents.count should equal(1);
            });
        });

        context(@"when the command is 'close'", ^{
            it(@"should tell its display manager to close the ad", ^{
                URL = [NSURL URLWithString:@"mraid://close"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                adDisplayController should have_received(@selector(close));
            });

            it(@"should NOT tell its display manager to close the ad if the user did not tap the webview", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"mraid://close"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                adDisplayController should_not have_received(@selector(close));
            });
        });

        context(@"when the command is 'createCalendarEvent'", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"mraid://createCalendarEvent?title=Great%20Day"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
            });

            it(@"should tell its calendar manager to create a calendar event", ^{
                calendarManager should have_received(@selector(createCalendarEventWithParameters:)).with(@{@"title": @"Great Day"});
            });

            context(@"when the calendar manager is about to present a calendar editor", ^{
                beforeEach(^{
                    [view calendarManagerWillPresentCalendarEditor:calendarManager];
                });

                it(@"should tell its delegate that modal content will be presented", ^{
                    delegate should have_received(@selector(appShouldSuspendForAd:)).with(view);
                });

                it(@"should present the calendar editor from the proper view controller", ^{
                    UIViewController *viewController = [view viewControllerForPresentingCalendarEditor];
                    viewController should_not be_nil;
                    viewController should be_same_instance_as(presentingViewController);
                });

                context(@"when the calendar editor is dismissed", ^{
                    beforeEach(^{
                        [view calendarManagerDidDismissCalendarEditor:calendarManager];
                    });

                    it(@"should tell its delegate that modal content has been dismissed", ^{
                        delegate should have_received(@selector(appShouldResumeFromAd:)).with(view);
                    });
                });
            });

            context(@"when the event is created successfully", ^{
                it(@"should tell its delegate that the command finished", ^{
                    jsEventEmitter.lastCompletedCommand should equal(@"createCalendarEvent");
                });
            });

            context(@"when the event cannot be created", ^{
                it(@"should emit a JavaScript error event", ^{
                    [view calendarManager:calendarManager didFailToCreateCalendarEventWithErrorMessage:@"message"];
                    jsEventEmitter.errorEvents should contain(@"createCalendarEvent");
                });
            });
        });

        context(@"when the command is 'createCalendarEvent' and the user did not tap the webview", ^{
            it(@"should NOT tell its calendar manager to create a calendar event", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"mraid://createCalendarEvent?title=Great%20Day"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                calendarManager should_not have_received(@selector(createCalendarEventWithParameters:));
            });
        });

        context(@"when the command is 'expand'", ^{
            it(@"should tell its display manager to expand the ad", ^{
                URL = [NSURL URLWithString:@"mraid://expand"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                adDisplayController should have_received(@selector(expandToFrame:withURL:useCustomClose:isModal:shouldLockOrientation:));
            });

            it(@"should NOT tell its display manager to expand the ad if the user did not tap the webview", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"mraid://expand"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                adDisplayController should_not have_received(@selector(expandToFrame:withURL:useCustomClose:isModal:shouldLockOrientation:));
            });
        });

        context(@"when the command is 'open'", ^{
            it(@"should tell the ad view to open something", ^{
                URL = [NSURL URLWithString:@"mraid://open?url=http://www.google.com"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:));
            });

            it(@"should NOT tell the ad view to open something if the user did not tap the webview", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"mraid://open?url=http://www.google.com"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
            });
        });

        context(@"when the command is 'playVideo'", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
            });

            it(@"should tell its video manager to play the video", ^{
                videoPlayerManager should have_received(@selector(playVideo:)).with([NSURL URLWithString:@"a_video"]);
            });

            context(@"when the video cannot be played", ^{
                it(@"should emit a JavaScript error event", ^{
                    [view videoPlayerManager:videoPlayerManager didFailToPlayVideoWithErrorMessage:@"message"];
                    jsEventEmitter.errorEvents should contain(@"playVideo");
                });
            });

            context(@"when the video is about to appear on-screen", ^{
                beforeEach(^{
                    [view videoPlayerManagerWillPresentVideo:videoPlayerManager];
                });

                it(@"should tell its delegate that modal content will be presented", ^{
                    delegate should have_received(@selector(appShouldSuspendForAd:)).with(view);
                });

                it(@"should present the video player from the proper view controller", ^{
                    UIViewController *viewController = [view viewControllerForPresentingVideoPlayer];
                    viewController should_not be_nil;
                    viewController should be_same_instance_as(presentingViewController);
                });

                context(@"when the video has finished playing", ^{
                    it(@"should tell its delegate that modal content has been dismissed", ^{
                        [view videoPlayerManagerDidDismissVideo:videoPlayerManager];
                        delegate should have_received(@selector(appShouldResumeFromAd:)).with(view);
                    });
                });
            });
        });

        context(@"when the command is 'playVideo' and the user did not tap the banner webview", ^{
            it(@"should NOT tell its video manager to play the video", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                videoPlayerManager should_not have_received(@selector(playVideo:));
            });
        });

        context(@"when the command is 'playVideo' from an interstitial", ^{
            beforeEach(^{
                view = [[MPInstanceProvider sharedProvider] buildMRAdViewWithFrame:CGRectMake(0, 0, 320, 50)
                                                                   allowsExpansion:YES
                                                                  closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                     placementType:MRAdViewPlacementTypeInterstitial
                                                                          delegate:nil];
            });

            context(@"when the user did not click the webview", ^{
                beforeEach(^{
                    view.userInteractedWithWebView = NO;
                });

                it(@"should tell its video manager to play the video", ^{
                    URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                    [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                    videoPlayerManager should have_received(@selector(playVideo:));
                });
            });

            context(@"when the user did click the webview", ^{
                beforeEach(^{
                    view.userInteractedWithWebView = YES;
                });

                it(@"should tell its video manager to play the video", ^{
                    URL = [NSURL URLWithString:@"mraid://playVideo?uri=a_video"];
                    [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                    videoPlayerManager should have_received(@selector(playVideo:));
                });
            });
        });

        context(@"when the command is 'storePicture'", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"mraid://storePicture?uri=an_image"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];
            });

            it(@"should tell its picture manager to store a picture", ^{
                pictureManager should have_received(@selector(storePicture:)).with([NSURL URLWithString:@"an_image"]);
            });

            context(@"when the picture is stored successfully", ^{
                it(@"should tell its delegate that the command finished", ^{
                    jsEventEmitter.lastCompletedCommand should equal(@"storePicture");
                });
            });

            context(@"when the picture cannot be stored", ^{
                it(@"should emit a JavaScript error event", ^{
                    [view pictureManager:pictureManager didFailToStorePictureWithErrorMessage:@"message"];
                    jsEventEmitter.errorEvents should contain(@"storePicture");
                });
            });
        });

        context(@"when the command is 'storePicture' and the user did not tap the webview", ^{
            it(@"should NOT tell its picture manager to store a picture", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"mraid://storePicture?uri=an_image"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                pictureManager should_not have_received(@selector(storePicture:));
            });
        });

        context(@"when the command is 'useCustomClose'", ^{
            it(@"should tell its display manager", ^{
                URL = [NSURL URLWithString:@"mraid://usecustomclose?shouldUseCustomClose=1"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                adDisplayController should have_received(@selector(useCustomClose:)).with(YES);
            });

            it(@"should tell its display manager even if the user did not tap the webview", ^{
                view.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"mraid://usecustomclose?shouldUseCustomClose=1"];
                [view webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                adDisplayController should have_received(@selector(useCustomClose:)).with(YES);
            });
        });
    });

    describe(@"mraid://open", ^{
        context(@"when the ad is in the default state", ^{
            it(@"should ask the destination display agent to load the URL", ^{
                NSURL *URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [view handleMRAIDOpenCallForURL:URL];
                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
            });
        });

        context(@"when the ad is in the expanded state", ^{
            __block NSURL *URL;

            beforeEach(^{
                NSURL *expandCommandURL = [NSURL URLWithString:@"mraid://expand"];
                NSURLRequest *expandRequest = [NSURLRequest requestWithURL:expandCommandURL];
                [view webView:nil
                      shouldStartLoadWithRequest:expandRequest
                      navigationType:UIWebViewNavigationTypeOther];
                in_time([[[UIApplication sharedApplication] keyWindow] subviews]) should contain(view);

                URL = [NSURL URLWithString:@"http://www.donuts.com"];
                [view handleMRAIDOpenCallForURL:URL];
            });

            it(@"should ask the destination display agent to load the URL", ^{
                destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
            });

            context(@"when the destination display agent presents a modal view controller", ^{
                beforeEach(^{
                    [view displayAgentWillPresentModal];
                });

                it(@"should temporarily hide the expanded ad", ^{
                    [[[UIApplication sharedApplication] keyWindow] subviews] should contain(view);
                    view.hidden should equal(YES);
                });

                context(@"when the modal view controller is dismissed", ^{
                    beforeEach(^{
                        [view displayAgentDidDismissModal];
                    });

                    it(@"should un-hide the expanded ad", ^{
                        view.hidden should equal(NO);
                    });

                    it(@"should not tell the delegate that the ad has been dismissed", ^{
                        delegate should_not have_received(@selector(appShouldResumeFromAd:));
                    });
                });
            });
        });
    });

    describe(@"MPAdDestinationDisplayAgentDelegate", ^{
        context(@"when asked for a view controller to present modal views", ^{
            it(@"should ask the MRAdViewDelegate for one", ^{
                [view viewControllerForPresentingModalView] should equal(presentingViewController);
            });
        });

        context(@"when a modal is presented", ^{
            beforeEach(^{
                [view displayAgentWillPresentModal];
            });

            it(@"should tell the delegate", ^{
                delegate should have_received(@selector(appShouldSuspendForAd:)).with(view);
            });

            context(@"when the modal is dismissed", ^{
                it(@"should tell the delegate", ^{
                    [view displayAgentDidDismissModal];
                    delegate should have_received(@selector(appShouldResumeFromAd:)).with(view);
                });
            });
        });
    });
});

SPEC_END
