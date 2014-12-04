#import "MRJavaScriptEventEmitter.h"
#import "MRProperty.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRJavaScriptEventEmitterSpec)

describe(@"MRJavaScriptEventEmitter", ^{
    __block MRJavaScriptEventEmitter *jsEventEmitter;
    __block UIWebView *webView;

    beforeEach(^{
        webView = [[UIWebView alloc] init];
        jsEventEmitter = [[MRJavaScriptEventEmitter alloc] initWithWebView:webView];
    });

    describe(@"-fireChangeEventWithProperty:", ^{
        __block MRProperty *property;

        beforeEach(^{
            property = [MRStateProperty propertyWithState:MRAdViewStateDefault];
            [jsEventEmitter fireChangeEventForProperty:property];
        });

        it(@"should execute JavaScript in the webview to update the given MRAID property", ^{
            [[webView executedJavaScripts] count] should equal(1);
            (NSString *)[[webView executedJavaScripts] lastObject] should contain([property description]);
        });
    });

    describe(@"-fireChangeEventWithProperties:", ^{
        __block MRProperty *property1;
        __block MRProperty *property2;

        beforeEach(^{
            property1 = [MRStateProperty propertyWithState:MRAdViewStateDefault];
            property2 = [MRScreenSizeProperty propertyWithSize:CGSizeZero];
            [jsEventEmitter fireChangeEventsForProperties:@[property1, property2]];
        });

        it(@"should execute JavaScript in the webview to update the given MRAID properties", ^{
            [[webView executedJavaScripts] count] should equal(1);
            (NSString *)[[webView executedJavaScripts] lastObject] should contain([property1 description]);
            (NSString *)[[webView executedJavaScripts] lastObject] should contain([property2 description]);
        });
    });

    describe(@"-fireReadyEvent", ^{
        beforeEach(^{
            [jsEventEmitter fireReadyEvent];
        });

        it(@"should execute JavaScript in the webview to signal that the SDK is ready", ^{
            [[webView executedJavaScripts] count] should equal(1);
            (NSString *)[[webView executedJavaScripts] lastObject] should equal(@"window.mraidbridge.fireReadyEvent();");
        });
    });

    describe(@"-fireErrorEventForAction:withMessage:", ^{
        beforeEach(^{
            [jsEventEmitter fireErrorEventForAction:@"open" withMessage:@"sesame"];
        });

        it(@"should execute JavaScript in the webview to signal the error", ^{
            [[webView executedJavaScripts] count] should equal(1);
            (NSString *)[[webView executedJavaScripts] lastObject] should contain(@"open");
            (NSString *)[[webView executedJavaScripts] lastObject] should contain(@"sesame");
        });
    });

    describe(@"-fireNativeCommandCompleteEvent", ^{
        beforeEach(^{
            [jsEventEmitter fireNativeCommandCompleteEvent:@"march"];
        });

        it(@"should execute JavaScript in the webview to signal that the command completed", ^{
            [[webView executedJavaScripts] count] should equal(1);
            (NSString *) [[webView executedJavaScripts] lastObject] should contain(@"march");
        });
    });
});

SPEC_END
