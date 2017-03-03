#import "MPVASTManager.h"
#import "CedarAsync.h"
#import "MPVASTAd.h"
#import "MPVASTCreative.h"
#import "MPVASTInline.h"
#import "MPVASTLinearAd.h"
#import "MPVASTMediaFile.h"
#import "MPVASTWrapper.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

const int kLongWrapperChainDepth = 20;

void verifyBasicExample(MPVASTResponse *response) {
    [response.ads count] should equal(1);

    MPVASTAd *ad = response.ads[0];
    [ad.inlineAd.errorURLs count] should equal(1);
    ad.inlineAd.errorURLs should contain([NSURL URLWithString:@"http://myErrorURL/error"]);
    [ad.inlineAd.impressionURLs count] should equal(1);
    ad.inlineAd.impressionURLs should contain([NSURL URLWithString:@"http://myTrackingURL/impression"]);
    [ad.inlineAd.creatives count] should equal(2);

    MPVASTCreative *creative1 = ad.inlineAd.creatives[0];
    creative1.linearAd.clickThroughURL.absoluteString should equal(@"http://www.tremormedia.com/video");
    [creative1.linearAd.clickTrackingURLs count] should equal(1);
    creative1.linearAd.clickTrackingURLs should contain([NSURL URLWithString:@"http://myTrackingURL/click"]);
    creative1.linearAd.duration should equal(30);
    [creative1.linearAd.mediaFiles count] should equal(1);
    [creative1.linearAd.trackingEvents count] should equal(6);

    MPVASTMediaFile *mediaFile = creative1.linearAd.mediaFiles[0];
    mediaFile.identifier should equal(@"1");
    mediaFile.delivery should equal(@"progressive");
    mediaFile.mimeType should equal(@"video/mp4");
    mediaFile.bitrate should equal(457);
    mediaFile.width should equal(300);
    mediaFile.height should equal(225);
    mediaFile.URL.absoluteString should equal(@"http://f.cl.ly/items/39222F2i3z0z350Q1H11/big_buck_bunny_short.mp4");
}

NSString *XMLStringFromFileNamed(NSString *name) {
    NSString *file = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
    return [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
}

SPEC_BEGIN(MPVASTManagerSpec)

describe(@"MPVASTManager", ^{
    __block void (^completion)(MPVASTResponse *, NSError *);
    __block MPVASTResponse *response;
    __block NSError *error;
    __block NSURL *URL;

    beforeEach(^{
        // XXX: For our tests to work, we must be able to inspect network requests and inject fixed
        // responses. Unfortunately, third-party ad SDKs can hinder our ability to do this reliably;
        // they often phone home for config updates / analytics, introducing additional network
        // requests that don't result from code we've written. Since many of these "hidden" requests
        // happen on app startup, we can avoid them to a degree by introducing a one-time delay
        // before running these tests.
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
        });

        response = nil;
        error = nil;

        completion = [^(MPVASTResponse *resp, NSError *err) {
            response = resp;
            error = err;
        } copy];
    });

    describe(@"fetching a simple response from a URL", ^{
        __block NSString *VASTXMLString;

        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.placeholder.com"];
            VASTXMLString = XMLStringFromFileNamed(@"vast-w-companion-ad");
        });

        subjectAction(^{
            [MPVASTManager fetchVASTWithURL:URL completion:completion];
        });

        it(@"should parse correctly", ^{
            NSURLConnection *connection = [NSURLConnection lastConnection];
            [[connection request] URL] should equal(URL);
            [connection receiveSuccessfulResponse:VASTXMLString];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        });
    });

    describe(@"a wrapper ad", ^{
        __block NSString *VASTXMLString;

        subjectAction(^{
            [MPVASTManager fetchVASTWithURL:URL completion:completion];
        });

        context(@"which redirects to another (different) VAST response", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"http://this-will-redirect.com"];
                VASTXMLString = XMLStringFromFileNamed(@"basic-wrapper");
            });

            it(@"should return a consolidated response which contains the wrapped response", ^{
                NSURLConnection *connection = [NSURLConnection lastConnection];
                [[connection request] URL] should equal(URL);
                [connection receiveSuccessfulResponse:VASTXMLString];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

                NSURLConnection *redirectConnection = [NSURLConnection lastConnection];
                [[[redirectConnection request] URL] absoluteString] should equal(@"http://cl.ly/code/3w3i0O1p3m1Q/longvideoVAST.xml");
                NSString *redirectFile = [[NSBundle mainBundle] pathForResource:@"vast-w-companion-ad" ofType:@"xml"];
                NSString *redirectVAST = [NSString stringWithContentsOfFile:redirectFile encoding:NSUTF8StringEncoding error:nil];
                [redirectConnection receiveSuccessfulResponse:redirectVAST];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

                MPVASTAd *ad = response.ads[0];
                verifyBasicExample(ad.wrapper.wrappedVASTResponse);
            });
        });

        context(@"with a cycle in the chain of wrapper URLs", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"https://redirect-to-self.com"];
                VASTXMLString = XMLStringFromFileNamed(@"infinite-wrapper-cycle");

                // Set `response` to a placeholder, so we can check that it ends up being nil once
                // the completion block is called.
                response = [[MPVASTResponse alloc] init];
            });

            it(@"should terminate after some specified depth", ^{
                NSURLConnection *currentConnection = [NSURLConnection lastConnection];
                [[currentConnection request] URL] should equal(URL);
                [currentConnection receiveSuccessfulResponse:VASTXMLString];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

                int wrappersTraversed = 0;
                for (int i = 0; i <= kLongWrapperChainDepth; i++) {
                    if ([NSURLConnection lastConnection] && currentConnection != [NSURLConnection lastConnection]) {
                        currentConnection = [NSURLConnection lastConnection];
                        [[currentConnection request] URL] should equal(URL);
                        [currentConnection receiveSuccessfulResponse:VASTXMLString];
                        wrappersTraversed++;
                        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                    } else {
                        // Getting here means that we didn't create a new NSURLConnection (and
                        // therefore that the most recent wrapper didn't redirect). This is the
                        // desired behavior once we've reached a specified traversal depth.
                        break;
                    }
                }

                wrappersTraversed should equal(10);
                response should be_nil;
                error.code should equal(MPVASTErrorExceededMaximumWrapperDepth);
            });
        });
    });

    context(@"when a linear ad has a skipoffset", ^{
        __block NSData *VASTXMLData;

        subjectAction(^{
            [MPVASTManager fetchVASTWithData:VASTXMLData completion:completion];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        });

        context(@"which is an absolute time value", ^{
            context(@"that is greater than zero", ^{
                beforeEach(^{
                    VASTXMLData = dataFromXMLFileNamed(@"linear-absolute-skipoffset");
                });

                it(@"should parse correctly", ^{
                    MPVASTAd *ad = response.ads[0];
                    MPVASTCreative *creative = ad.inlineAd.creatives[0];
                    MPVASTDurationOffset *skipOffset = creative.linearAd.skipOffset;
                    skipOffset.type should equal(MPVASTDurationOffsetTypeAbsolute);
                    skipOffset.offset should equal(@"01:23:45.678");
                    [skipOffset timeIntervalForVideoWithDuration:100] should equal(5025.678);
                });
            });

            context(@"that is zero", ^{
                beforeEach(^{
                    VASTXMLData = dataFromXMLFileNamed(@"linear-absolute-skipoffset-zero");
                });

                it(@"should result in a parsed value that is zero", ^{
                    MPVASTAd *ad = response.ads[0];
                    MPVASTCreative *creative = ad.inlineAd.creatives[0];
                    MPVASTDurationOffset *skipOffset = creative.linearAd.skipOffset;
                    skipOffset.type should equal(MPVASTDurationOffsetTypeAbsolute);
                    skipOffset.offset should equal(@"00:00:00");
                    [skipOffset timeIntervalForVideoWithDuration:100] should equal(0);
                });
            });
        });

        context(@"which is a percentage", ^{
            beforeEach(^{
                VASTXMLData = dataFromXMLFileNamed(@"linear-percentage-skipoffset");
            });

            context(@"that is greater than zero", ^{
                it(@"should parse correctly", ^{
                    MPVASTAd *ad = response.ads[0];
                    MPVASTCreative *creative = ad.inlineAd.creatives[0];
                    MPVASTDurationOffset *skipOffset = creative.linearAd.skipOffset;
                    skipOffset.type should equal(MPVASTDurationOffsetTypePercentage);
                    skipOffset.offset should equal(@"65%");
                    [skipOffset timeIntervalForVideoWithDuration:100] should equal(65);
                });
            });

            context(@"that is zero", ^{
                beforeEach(^{
                    VASTXMLData = dataFromXMLFileNamed(@"linear-percentage-skipoffset-zero");
                });

                it(@"should result in a parsed value that is zero", ^{
                    MPVASTAd *ad = response.ads[0];
                    MPVASTCreative *creative = ad.inlineAd.creatives[0];
                    MPVASTDurationOffset *skipOffset = creative.linearAd.skipOffset;
                    skipOffset.type should equal(MPVASTDurationOffsetTypePercentage);
                    skipOffset.offset should equal(@"0%");
                    [skipOffset timeIntervalForVideoWithDuration:100] should equal(0);
                });
            });
        });
    });

    describe(@"failure cases", ^{
        context(@"when the XML is invalid", ^{
            __block NSData *VASTXMLData;

            it(@"should not explode", ^{
                VASTXMLData = dataFromXMLFileNamed(@"invalid-1");
                [MPVASTManager fetchVASTWithData:VASTXMLData completion:completion];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            });

            it(@"should also not explode", ^{
                VASTXMLData = dataFromXMLFileNamed(@"invalid-2");
                [MPVASTManager fetchVASTWithData:VASTXMLData completion:completion];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            });
        });
    });
});

SPEC_END
