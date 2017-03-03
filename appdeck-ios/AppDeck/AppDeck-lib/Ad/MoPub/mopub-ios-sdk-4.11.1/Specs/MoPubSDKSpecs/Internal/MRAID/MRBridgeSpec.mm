#import "MRBridge+MPSpecs.h"
#import "MRProperty.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRBridgeSpec)

describe(@"MRBridge", ^{
    __block MRBridge *bridge;
    __block MPWebView *webView;
    __block id<MRBridgeDelegate> delegate;

    beforeEach(^{
        webView = [[MPWebView alloc] init];
        delegate = nice_fake_for(@protocol(MRBridgeDelegate));

        bridge = [[MRBridge alloc] initWithWebView:webView];
        bridge.shouldHandleRequests = YES;
        bridge.delegate = delegate;
    });

//    describe(@"-fireChangeEventWithProperty:", ^{
//        __block MRProperty *property;
//
//        beforeEach(^{
//            property = [MRStateProperty propertyWithState:MRAdViewStateDefault];
//            [bridge fireChangeEventForProperty:property];
//        });
//
//        it(@"should execute JavaScript in the webview to update the given MRAID property", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain([property description]);
//        });
//    });

//    describe(@"-fireChangeEventWithProperties:", ^{
//        __block MRProperty *property1;
//        __block MRProperty *property2;
//
//        beforeEach(^{
//            property1 = [MRStateProperty propertyWithState:MRAdViewStateDefault];
//            property2 = [MRScreenSizeProperty propertyWithSize:CGSizeZero];
//            [bridge fireChangeEventsForProperties:@[property1, property2]];
//        });
//
//        it(@"should execute JavaScript in the webview to update the given MRAID properties", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain([property1 description]);
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain([property2 description]);
//        });
//    });

//    describe(@"-fireReadyEvent", ^{
//        beforeEach(^{
//            [bridge fireReadyEvent];
//        });
//
//        it(@"should execute JavaScript in the webview to signal that the SDK is ready", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *)[[webView executedJavaScripts] lastObject] should equal(@"window.mraidbridge.fireReadyEvent();");
//        });
//    });

//    describe(@"-fireErrorEventForAction:withMessage:", ^{
//        beforeEach(^{
//            [bridge fireErrorEventForAction:@"open" withMessage:@"sesame"];
//        });
//
//        it(@"should execute JavaScript in the webview to signal the error", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain(@"open");
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain(@"sesame");
//        });
//    });

//    describe(@"-fireNativeCommandCompleteEvent", ^{
//        beforeEach(^{
//            [bridge fireNativeCommandCompleteEvent:@"march"];
//        });
//
//        it(@"should execute JavaScript in the webview to signal that the command completed", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *) [[webView executedJavaScripts] lastObject] should contain(@"march");
//        });
//    });

//    describe(@"-fireSetCurrentPositionWithPositionRect", ^{
//        beforeEach(^{
//            [bridge fireSetCurrentPositionWithPositionRect:CGRectMake(0, 0, 480, 320)];
//        });
//
//        it(@"should execute Javascript in the webview", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain(@"window.mraidbridge.setCurrentPosition");
//        });
//    });

//    describe(@"-fireSetDefaultPositionWithPositionRect", ^{
//        beforeEach(^{
//            [bridge fireSetDefaultPositionWithPositionRect:CGRectMake(0, 0, 480, 320)];
//        });
//
//        it(@"should execute Javascript in the webview", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain(@"window.mraidbridge.setDefaultPosition");
//        });
//    });

//    describe(@"-fireSetMaxSize", ^{
//        beforeEach(^{
//            [bridge fireSetMaxSize:CGSizeMake(480, 320)];
//        });
//
//        it(@"should execute Javascript in the webview", ^{
//            [[webView executedJavaScripts] count] should equal(1);
//            (NSString *)[[webView executedJavaScripts] lastObject] should contain(@"window.mraidbridge.setMaxSize");
//        });
//    });

    describe(@"WebView Handling", ^{
        __block NSURL *URL;

        describe(@"Loading links (e.g. http://www.google.com)", ^{
            it(@"should let the delegate handle it by calling handleDisplayForDestinationURL if the delegate's view had been tapped", ^{
                URL = [NSURL URLWithString:@"http://www.google.com"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                request.mainDocumentURL = URL;
                [bridge webView:webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

                delegate should have_received(@selector(bridge:handleDisplayForDestinationURL:)).with(bridge).and_with(URL);
            });
        });

        describe(@"Handling telephone URLs", ^{
            context(@"When the scheme is tel://", ^{
                beforeEach(^{
                    URL = [NSURL URLWithString:@"tel://5555555555"];
                });

                it(@"should let the delegate handle it by calling handleDisplayForDestinationURL", ^{
                    [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                    delegate should have_received(@selector(bridge:handleDisplayForDestinationURL:)).with(bridge).and_with(URL);
                });
            });

            context(@"When the scheme is telPrompt://", ^{
                beforeEach(^{
                    URL = [NSURL URLWithString:@"telPrompt://5555555555"];
                });

                it(@"should let the delegate handle it by calling handleDisplayForDestinationURL", ^{
                    [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                    delegate should have_received(@selector(bridge:handleDisplayForDestinationURL:)).with(bridge).and_with(URL);
                });
            });
        });

        describe(@"Handling mopub specific URLs", ^{
            it(@"should rely on the delegate to perform an action for the mopub url", ^{
                URL = [NSURL URLWithString:@"mopub://whatup"];
                [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                delegate should have_received(@selector(bridge:performActionForMoPubSpecificURL:)).with(bridge).and_with(URL);
            });
        });

        describe(@"Native commands that get routed to the delegate", ^{
            context(@"when the user has interacted with the delegate's view", ^{
                beforeEach(^{
                    delegate stub_method(@selector(hasUserInteractedWithWebViewForBridge:)).and_return(YES);
                });

                context(@"when the command is 'open'", ^{
                    it(@"should forward the open command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://open?url=http://www.google.com"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleDisplayForDestinationURL:)).with(bridge).and_with([NSURL URLWithString:@"http://www.google.com"]);
                    });
                });

                context(@"when the command is 'close'", ^{
                    it(@"should forward the close command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://close"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(handleNativeCommandCloseWithBridge:)).with(bridge);
                    });
                });

                context(@"when the command is 'expand'", ^{
                    it(@"should forward the expand command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://expand"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleNativeCommandExpandWithURL:useCustomClose:));
                    });
                });

                context(@"when the command is 'resize'", ^{
                    it(@"should forward the resize command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://resize"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleNativeCommandResizeWithParameters:));
                    });
                });

                context(@"when the command is 'setOrientationProperties'", ^{
                    it(@"should forward the command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://setOrientationProperties?allowOrientationChange=false&forceOrientation=portrait"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:)).with(bridge).and_with(UIInterfaceOrientationMaskPortrait);
                    });
                });

                context(@"when the command is 'useCustomClose'", ^{
                    it(@"should forward the useCustomClose command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://usecustomclose?shouldUseCustomClose=1"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleNativeCommandUseCustomClose:)).with(bridge).and_with(YES);
                    });
                });
            });

            context(@"when the user has not interacted with the delegate's view", ^{
                beforeEach(^{
                    delegate stub_method(@selector(hasUserInteractedWithWebViewForBridge:)).and_return(NO);
                });
                context(@"when the command is 'open'", ^{
                    it(@"should not forward the open command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://open?url=http://www.google.com"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleDisplayForDestinationURL:));
                    });
                });

                context(@"when the command is 'close'", ^{
                    it(@"should not forward the close command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://close"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(handleNativeCommandCloseWithBridge:));
                    });
                });

                context(@"when the command is 'expand'", ^{
                    it(@"should not forward the expand command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://expand"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleNativeCommandExpandWithURL:useCustomClose:));
                    });
                });

                context(@"when the command is 'resize'", ^{
                    it(@"should not forward the resize command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://resize"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleNativeCommandResizeWithParameters:));
                    });
                });

                context(@"when the command is 'useCustomClose'", ^{
                    it(@"should still forward the useCustomClose command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://usecustomclose?shouldUseCustomClose=1"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleNativeCommandUseCustomClose:));
                    });
                });
            });

            context(@"when the bridge has its requests disabled", ^{
                beforeEach(^{
                    bridge.shouldHandleRequests = NO;

                    // Let's make this test stricter by also saying the user has tapped on the webview.
                    delegate stub_method(@selector(hasUserInteractedWithWebViewForBridge:)).and_return(YES);
                });

                context(@"when the command is 'open'", ^{
                    it(@"should not forward the open command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://open?url=http://www.google.com"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleDisplayForDestinationURL:));
                    });
                });

                context(@"when the command is 'close'", ^{
                    it(@"should not forward the close command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://close"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(handleNativeCommandCloseWithBridge:));
                    });
                });

                context(@"when the command is 'expand'", ^{
                    it(@"should not forward the expand command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://expand"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleNativeCommandExpandWithURL:useCustomClose:));
                    });
                });

                context(@"when the command is 'resize'", ^{
                    it(@"should not forward the resize command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://resize"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleNativeCommandResizeWithParameters:));
                    });
                });

                // Custom close gets a free pass as its safe to run even when we have disabled request handling.
                context(@"when the command is 'useCustomClose'", ^{
                    it(@"should forward the useCustomClose command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://usecustomclose?shouldUseCustomClose=1"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleNativeCommandUseCustomClose:));
                    });
                });

                context(@"when the command is 'setOrientationProperties'", ^{
                    it(@"should forward the command to the delegate", ^{
                        URL = [NSURL URLWithString:@"mraid://setOrientationProperties?allowOrientationChange=false&forceOrientation=portrait"];
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should have_received(@selector(bridge:handleNativeCommandSetOrientationPropertiesWithForceOrientationMask:));
                    });
                });

                context(@"when the scheme is telPrompt://", ^{
                    beforeEach(^{
                        URL = [NSURL URLWithString:@"telPrompt://5555555555"];
                    });

                    it(@"should not let the delegate handle it by calling handleDisplayForDestinationURL", ^{
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleDisplayForDestinationURL:));
                    });
                });

                context(@"when the scheme is tel://", ^{
                    beforeEach(^{
                        URL = [NSURL URLWithString:@"tel://5555555555"];
                    });

                    it(@"should not let the delegate handle it by calling handleDisplayForDestinationURL", ^{
                        [bridge webView:webView shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleDisplayForDestinationURL:));
                    });
                });

                context(@"when loading links (e.g. http://www.google.com)", ^{
                    it(@"should not let the delegate handle it by calling handleDisplayForDestinationURL if the delegate's view had been tapped", ^{
                        URL = [NSURL URLWithString:@"http://www.google.com"];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
                        request.mainDocumentURL = URL;
                        [bridge webView:webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

                        delegate should_not have_received(@selector(bridge:handleDisplayForDestinationURL:));
                    });
                });
            });
        });
    });

    describe(@"HTML loading", ^{
        context(@"when starting load", ^{
            beforeEach(^{
                spy_on(webView);
                [bridge webViewDidStartLoad:webView];
            });

            it(@"should disable javascript alerts", ^{
                webView should have_received(@selector(disableJavaScriptDialogs));
            });
        });

        context(@"when html finishes loading", ^{
            beforeEach(^{
                spy_on(bridge);
                delegate stub_method(@selector(isLoadingAd)).and_return(YES);
                [bridge webViewDidFinishLoad:webView];
            });

            it(@"should notify the delegate", ^{
                delegate should have_received(@selector(bridge:didFinishLoadingWebView:));
            });
        });

        context(@"when the html fails to load", ^{
            it(@"should notify the delegate as long as the request wasn't cancelled", ^{
                NSInteger notCancelledErrorCode = NSURLErrorCancelled-1;
                [bridge webView:webView didFailLoadWithError:[NSError errorWithDomain:@"" code:notCancelledErrorCode userInfo:nil]];

                delegate should have_received(@selector(bridge:didFailLoadingWebView:error:));
            });

            it(@"should not notify the delegate for a cancelled request", ^{
                [bridge webView:webView didFailLoadWithError:[NSError errorWithDomain:@"" code:NSURLErrorCancelled userInfo:nil]];

                delegate should_not have_received(@selector(bridge:didFailLoadingWebView:error:));
            });
        });
    });
});

SPEC_END
