#import "MPAdWebViewAgent.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPWebView.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPAdAlertManager.h"
#import "UIWebView+MPAdditions.h"
#import "UIApplication+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface MPAdWebViewAgent ()

@property (nonatomic, assign) BOOL userInteractedWithWebView;

@end

SPEC_BEGIN(MPAdWebViewAgentSpec)

describe(@"MPAdWebViewAgent", ^{
    __block MPAdWebViewAgent *agent;
    __block id<CedarDouble, MPAdWebViewAgentDelegate> delegate;
    __block MPAdConfiguration *bannerConfiguration;
    __block MPAdConfiguration *interstitialConfiguration;
    __block MPWebView *webView;
    __block MPAdDestinationDisplayAgent *destinationDisplayAgent;
    __block FakeMPAdAlertManager *fakeAdAlertManager;

    beforeEach(^{
        fakeAdAlertManager = [[FakeMPAdAlertManager alloc] init];
        fakeCoreProvider.fakeAdAlertManager = fakeAdAlertManager;

        delegate = nice_fake_for(@protocol(MPAdWebViewAgentDelegate));

        destinationDisplayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
        fakeCoreProvider.fakeMPAdDestinationDisplayAgent = destinationDisplayAgent;

        agent = [[MPAdWebViewAgent alloc] initWithAdWebViewFrame:CGRectMake(0,0,30,20)
                                                         delegate:delegate];
        webView = agent.view;
        agent.userInteractedWithWebView = YES;
        bannerConfiguration = [MPAdConfigurationFactory defaultBannerConfiguration];
        interstitialConfiguration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
    });

    describe(@"when an interstitial configuration is loaded", ^{
        context(@"setting the frame", ^{
            beforeEach(^{
                interstitialConfiguration.preferredSize = CGSizeMake(123, 123);

//                spy_on(webView);

                [agent loadConfiguration:interstitialConfiguration];
            });

            it(@"should ignore the frame size", ^{
                agent.view.frame.size.width should equal(30);
                agent.view.frame.size.height should equal(20);
            });

            // test is non-functional because of a change of where webviews are alloc/inited
//            it(@"should load the html with a base url of http://ads.mopub.com", ^{
//                webView should have_received(@selector(loadHTMLString:baseURL:)).with(interstitialConfiguration.adResponseHTMLString).and_with([NSURL URLWithString:@"http://ads.mopub.com"]);
//            });
        });
    });

    describe(@"when the configuration is loaded", ^{
        subjectAction(^{ [agent loadConfiguration:bannerConfiguration]; });

        describe(@"setting the frame", ^{
            context(@"when the frame sizes are valid", ^{
                it(@"should set its frame", ^{
                    agent.view.frame.size.width should equal(320);
                    agent.view.frame.size.height should equal(50);
                });
            });

            context(@"when the frame sizes are invalid", ^{
                beforeEach(^{
                    bannerConfiguration.preferredSize = CGSizeMake(0, 0);
                });

                it(@"should not set its frame", ^{
                    agent.view.frame.size.width should equal(30);
                    agent.view.frame.size.height should equal(20);
                });
            });
        });

        describe(@"setting scrollability", ^{
            context(@"when the configuration says no", ^{
                beforeEach(^{
                    bannerConfiguration.scrollable = NO;
                });

                it(@"should disable scrolling", ^{
                    agent.view.scrollView.scrollEnabled should equal(NO);
                });
            });

            context(@"when the configuration says yes", ^{
                beforeEach(^{
                    bannerConfiguration.scrollable = YES;
                });

                it(@"should enable scrolling", ^{
                    agent.view.scrollView.scrollEnabled should equal(YES);
                });
            });
        });

//        describe(@"loading webview data", ^{
//            it(@"should load the ad's HTML data into the webview", ^{
//                agent.view.loadedHTMLString should equal(@"Publisher's Ad");
//            });
//        });

        describe(@"initializing the ad alert manager", ^{
            it(@"should be the delegate of the ad alert manager", ^{
                fakeAdAlertManager.delegate should equal((id<MPAdAlertManagerDelegate>)agent);
            });
        });

//        describe(@"javascript dialog disabled", ^{
//            it(@"should have executed the dialog disabling javascript", ^{
//                NSArray *executedJS = [agent.view executedJavaScripts];
//                executedJS.count should equal(1);
//
//                NSString *dialogDisableJS = [executedJS objectAtIndex:0];
//                dialogDisableJS should equal(kJavaScriptDisableDialogSnippet);
//            });
//        });
    });

    describe(@"MPAdDestinationDisplayAgentDelegate", ^{
        context(@"when asked for a view controller to present modal views", ^{
            it(@"should ask the MPAdWebViewAgentDelegate for one", ^{
                UIViewController *presentingViewController = [[UIViewController alloc] init];
                delegate stub_method("viewControllerForPresentingModalView").and_return(presentingViewController);
                [agent viewControllerForPresentingModalView] should equal(presentingViewController);
            });
        });

        context(@"when a modal is presented", ^{
            it(@"should tell the delegate", ^{
                [agent displayAgentWillPresentModal];
                delegate should have_received(@selector(adActionWillBegin:)).with(agent.view);
            });
        });

        context(@"when a modal is dismissed", ^{
            it(@"should tell the delegate", ^{
                [agent displayAgentDidDismissModal];
                delegate should have_received(@selector(adActionDidFinish:)).with(agent.view);
            });
        });

        context(@"when leaving the application", ^{
            it(@"should tell the delegate", ^{
                [agent displayAgentWillLeaveApplication];
                delegate should have_received(@selector(adActionWillLeaveApplication:)).with(agent.view);
            });
        });
    });

    describe(@"handling webview navigation", ^{
        __block NSURL *URL;

        subjectAction(^{ [agent loadConfiguration:bannerConfiguration]; });

        context(@"when told to stop handling requests", ^{
            beforeEach(^{
                [agent disableRequestHandling];
                URL = [NSURL URLWithString:@"mopub://close"];
            });

            it(@"should never load anything", ^{
                [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                delegate should_not have_received(@selector(adDidClose:)).with(agent.view);
            });

            it(@"should tell its destination display agent to cancel any open url requests", ^{
                destinationDisplayAgent should have_received(@selector(cancel));
            });

            context(@"when told to continue handling requests", ^{
                it(@"should load things again", ^{
                    [agent enableRequestHandling];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidClose:)).with(agent.view);
                });
            });
        });

        context(@"when the URL scheme is mopub://", ^{
            context(@"when the host is 'close'", ^{
                it(@"should tell the delegate that adDidClose:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://close"];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidClose:)).with(agent.view);
                });
            });

            context(@"when the host is 'finishLoad'", ^{
                it(@"should tell the delegate that adDidFinishLoadingAd:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://finishLoad"];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidFinishLoadingAd:)).with(agent.view);
                });
            });

            context(@"when the host is 'failLoad'", ^{
                it(@"should tell the delegate that adDidFailToLoadAd:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://failLoad"];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidFailToLoadAd:)).with(agent.view);
                });
            });

            context(@"when the host is something else", ^{
                beforeEach(^{
                    URL = [NSURL URLWithString:@"mopub://other"];
                });

                it(@"should not blow up and prevent the web view from handling the URL", ^{
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                });
            });
        });

        context(@"when loading a deeplink", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"dontgohere://noway.com"];
            });

            it(@"should not load the deeplink without user interaction", ^{
                agent.userInteractedWithWebView = NO;
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
            });

            it(@"should load the deeplink with user interaction", ^{
                agent.userInteractedWithWebView = YES;
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
            });

            it(@"should load about scheme without user interaction", ^{
                agent.userInteractedWithWebView = NO;
                URL = [NSURL URLWithString:@"about:blahblahblah"];
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
            });
        });

        context(@"when the scheme is not mopub", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"http://yay.com"];
            });

            context(@"when navigation should not be intercepted", ^{
                beforeEach(^{
                    bannerConfiguration.shouldInterceptLinks = NO;
                });

                it(@"should tell the webview to load the URL", ^{
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                });
            });

            context(@"when navigation should be intercepted", ^{
                beforeEach(^{
                    bannerConfiguration.shouldInterceptLinks = YES;
                });

                context(@"when the navigation type is a click", ^{
                    it(@"should ask an ad destination display agent to handle the URL, prepended with a click tracker", ^{
                        NSURL *expectedRedirectURL = [NSURL URLWithString:@"http://ads.mopub.com/m/clickThroughTracker?a=1&r=http%3A%2F%2Fyay.com"];

                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(expectedRedirectURL);
                    });
                });

                context(@"when the navigation type is Other", ^{
                    context(@"when the URL has the 'click detection' URL prefix", ^{
                        beforeEach(^{
                            URL = [NSURL URLWithString:@"http://publisher.com/foo"];
                        });

                        it(@"should ask an ad destination display agent to handle the URL, prepended with a click tracker", ^{
                            NSURL *expectedRedirectURL = [NSURL URLWithString:@"http://ads.mopub.com/m/clickThroughTracker?a=1&r=http%3A%2F%2Fpublisher.com%2Ffoo"];

                            [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                            destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(expectedRedirectURL);
                        });
                    });

                    context(@"otherwise", ^{
                        it(@"should tell the webview to load the URL", ^{
                            URL = [NSURL URLWithString:@"http://not-publisher.com/foo"];

                            [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });
                    });
                });

                context(@"when the navigation type is something else", ^{
                    it(@"should tell the webview to load the URL", ^{
                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeReload] should equal(YES);
                        destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                    });
                });

                context(@"when the click tracker is missing", ^{
                    beforeEach(^{
                        bannerConfiguration.clickTrackingURL = nil;
                    });

                    it(@"should ask an ad destination display agent to handle the URL, without prepending the click tracker", ^{
                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                    });
                });
            });
        });
    });

    describe(@"when working with telephone schemes", ^{
        __block NSURL *URL;

        context(@"when the scheme isn't tel or telprompt", ^{
            it(@"should not show a telephone prompt", ^{
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;

                agent = [[MPAdWebViewAgent alloc] initWithAdWebViewFrame:CGRectMake(0,0,30,20)
                                                                 delegate:delegate];

                URL = [NSURL URLWithString:@"twitter://food"];
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;

                URL = [NSURL URLWithString:@"http://www.ddf.com"];
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;

                URL = [NSURL URLWithString:@"apple://pear"];
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                [UIAlertView currentAlertView] should be_nil;
            });
        });

        context(@"when the scheme is tel://", ^{

            beforeEach(^{
                URL = [NSURL URLWithString:@"tel://5555555555"];
                fakeCoreProvider.fakeMPAdDestinationDisplayAgent = nil;

                agent = [[MPAdWebViewAgent alloc] initWithAdWebViewFrame:CGRectMake(0,0,30,20)
                                                                 delegate:delegate];
            });

            it(@"should not load anything", ^{
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
            });

            it(@"should attempt to display the alert view (by calling show on the MPTelephoneConfirmationController) with a tel scheme", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                [UIAlertView currentAlertView] should be_nil;
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
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

                agent = [[MPAdWebViewAgent alloc] initWithAdWebViewFrame:CGRectMake(0,0,30,20)
                                                                 delegate:delegate];
                webView = agent.view;
            });

            it(@"should not load anything", ^{
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
            });

            it(@"should attempt to display the alert view (by calling show on the MPTelephoneConfirmationController) with a tel scheme", ^{
                [[UIApplication sharedApplication] mp_setCanOpenTelephoneSchemes:YES];
                [UIAlertView currentAlertView] should be_nil;
                [agent webView:nil shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked];
                UIAlertView *currentAlert = [UIAlertView currentAlertView];
                currentAlert.numberOfButtons should equal(2);
                currentAlert.title should_not be_nil;
                currentAlert.message should_not be_nil;
            });
        });
    });

//    describe(@"when orientations change", ^{
//        subjectAction(^{ [agent loadConfiguration:bannerConfiguration]; });
//
//        it(@"should tell the web view via javascript", ^{
//            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
//            [agent rotateToOrientation:UIInterfaceOrientationLandscapeRight];
//            NSString *JS = [agent.view executedJavaScripts][1];
//            JS should contain(@"return -90");
//            JS = [agent.view executedJavaScripts][2];
//            JS should contain(@"width=320");
//        });
//    });

//    describe(@"invoking JS", ^{
//        subjectAction(^{ [agent loadConfiguration:bannerConfiguration]; });
//
//        it(@"should support MPAdWebViewEventAdDidAppear", ^{
//            [agent invokeJavaScriptForEvent:MPAdWebViewEventAdDidAppear];
//            [agent.view executedJavaScripts][1] should equal(@"webviewDidAppear();");
//        });
//
//        it(@"should support MPAdWebViewEventAdDidDisappear", ^{
//            [agent invokeJavaScriptForEvent:MPAdWebViewEventAdDidDisappear];
//            [agent.view executedJavaScripts][1] should equal(@"webviewDidClose();");
//        });
//    });
});

SPEC_END

#pragma clang diagnostic pop
