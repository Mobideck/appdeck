#import "MPVideoConfig.h"
#import "MPVASTManager.h"
#import "CedarAsync.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

NSString *TrackingEventURL(MPVASTTrackingEvent *event) {
    return [event.URL absoluteString];
}

SPEC_BEGIN(MPVideoConfigSpec)

describe(@"MPVideoConfig", ^{
    __block MPVideoConfig *config;
    __block void (^completion)(MPVASTResponse *, NSError *);
    __block NSData *VASTData;
    __block MPVASTResponse *VASTResponse;

    beforeEach(^{
        completion = [^(MPVASTResponse *resp, NSError *err) {
            VASTResponse = resp;
        } copy];

        VASTData = nil;
        VASTResponse = nil;
    });

    describe(@"when the VAST response has a wrapper", ^{
        beforeEach(^{
            // The test setup is a bit complicated. We ask the VAST manager to parse a wrapper and
            // then insert a canned response when the manager attempts the wrapper redirect.
            VASTData = dataFromXMLFileNamed(@"wrapper-with-tracking");
            [MPVASTManager fetchVASTWithData:VASTData completion:completion];

            // Wait for the redirect to materialize.
            in_time([NSURLConnection lastConnection]) should_not be_nil;
            NSURLConnection *redirectConnection = [NSURLConnection lastConnection];
            [[[redirectConnection request] URL] absoluteString] should equal(@"http://cl.ly/code/3w3i0O1p3m1Q/longvideoVAST.xml");
            NSString *redirectFile = [[NSBundle mainBundle] pathForResource:@"vast-w-companion-ad" ofType:@"xml"];
            NSString *redirectVAST = [NSString stringWithContentsOfFile:redirectFile encoding:NSUTF8StringEncoding error:nil];
            [redirectConnection receiveSuccessfulResponse:redirectVAST];

            // Wait for the parsing to finish.
            in_time(VASTResponse) should_not be_nil;

            config = [[MPVideoConfig alloc] initWithVASTResponse:VASTResponse];
        });

//        it(@"should append the wrapper's tracking events to any tracking events from post-wrapper ads", ^{
//            // These events are merged with events from the wrapper.
//            [config.creativeViewTrackers count] should equal(3);
//            TrackingEventURL(config.creativeViewTrackers[0]) should equal(@"http://myTrackingURL/creativeView");
//            TrackingEventURL(config.creativeViewTrackers[1]) should equal(@"http://wrapperTrackingURL/creativeView1");
//            TrackingEventURL(config.creativeViewTrackers[2]) should equal(@"http://wrapperTrackingURL/creativeView2");
//
//            // These events are from the nested ad.
//            [config.startTrackers count] should equal(1);
//            [config.midpointTrackers count] should equal(1);
//            [config.firstQuartileTrackers count] should equal(1);
//            [config.thirdQuartileTrackers count] should equal(1);
//            TrackingEventURL(config.startTrackers[0]) should equal(@"http://myTrackingURL/start");
//            TrackingEventURL(config.midpointTrackers[0]) should equal(@"http://myTrackingURL/midpoint");
//            TrackingEventURL(config.firstQuartileTrackers[0]) should equal(@"http://myTrackingURL/firstQuartile");
//            TrackingEventURL(config.thirdQuartileTrackers[0]) should equal(@"http://myTrackingURL/thirdQuartile");
//
//            // These events are present only in the wrapper.
//            [config.skipTrackers count] should equal(2);
//            TrackingEventURL(config.skipTrackers[0]) should equal(@"http://wrapperTrackingURL/skip1");
//            TrackingEventURL(config.skipTrackers[1]) should equal(@"http://wrapperTrackingURL/skip2");
//        });
    });

    describe(@"when the VAST response doesn't have a valid video candidate", ^{
        context(@"when the VAST response doesn't have a MediaFile", ^{
            beforeEach(^{
                VASTData = dataFromXMLFileNamed(@"invalid-3");
                [MPVASTManager fetchVASTWithData:VASTData completion:completion];

                // Since the VAST manager executes asynchronously, we want to wait until the results
                // come back before proceeding with any test.
                in_time(VASTResponse) should_not be_nil;
            });

            it(@"MPVideoConfig should not throw an exception when processing it", ^{
                ^{
                    config = [[MPVideoConfig alloc] initWithVASTResponse:VASTResponse];
                } should_not raise_exception;

            });
        });
    });

    describe(@"handling extensions", ^{
        describe(@"properties derived from the MoPubViewabilityTracker extension", ^{
            context(@"when the extension contains valid data", ^{
                beforeEach(^{
                    VASTData = dataFromXMLFileNamed(@"extension-mopubviewabilitytracker-valid");
                    [MPVASTManager fetchVASTWithData:VASTData completion:completion];

                    // Since the VAST manager executes asynchronously, we want to wait until the results
                    // come back before proceeding with any test.
                    in_time(VASTResponse) should_not be_nil;

                    config = [[MPVideoConfig alloc] initWithVASTResponse:VASTResponse];
                });

                it(@"should extract the correct values", ^{
                    config.minimumViewabilityTimeInterval should equal(30.5);
                    config.minimumFractionOfVideoVisible should equal(0.6);
                    config.viewabilityTrackingURL.absoluteString should equal(@"http://ad.server.com/impression/dot.gif");
                });
            });

            context(@"when the extension contains invalid data", ^{
                beforeEach(^{
                    VASTData = dataFromXMLFileNamed(@"extension-mopubviewabilitytracker-invalid");
                    [MPVASTManager fetchVASTWithData:VASTData completion:completion];

                    // Since the VAST manager executes asynchronously, we want to wait until the results
                    // come back before proceeding with any test.
                    in_time(VASTResponse) should_not be_nil;

                    config = [[MPVideoConfig alloc] initWithVASTResponse:VASTResponse];
                });

                it(@"should not set any of the viewability properties", ^{
                    config.minimumViewabilityTimeInterval should equal(0);
                    config.minimumFractionOfVideoVisible should equal(0);
                    config.viewabilityTrackingURL should be_nil;
                });
            });

            context(@"when there are multiple <MoPubViewabilityTracker> elements under one <Extension>", ^{
                beforeEach(^{
                    VASTData = dataFromXMLFileNamed(@"extension-mopubviewabilitytracker-multiple");
                    [MPVASTManager fetchVASTWithData:VASTData completion:completion];

                    // Since the VAST manager executes asynchronously, we want to wait until the results
                    // come back before proceeding with any test.
                    in_time(VASTResponse) should_not be_nil;

                    config = [[MPVideoConfig alloc] initWithVASTResponse:VASTResponse];
                });

                it(@"should use the values from the first element that it sees", ^{
                    config.minimumViewabilityTimeInterval should equal(30.5);
                    config.minimumFractionOfVideoVisible should equal(0.6);
                    config.viewabilityTrackingURL.absoluteString should equal(@"http://ad.server.com/impression/dot.gif");
                });
            });

            context(@"when there are multiple <Extension> elements under <Extensions>", ^{
                beforeEach(^{
                    VASTData = dataFromXMLFileNamed(@"extensions-multiple");
                    [MPVASTManager fetchVASTWithData:VASTData completion:completion];

                    // Since the VAST manager executes asynchronously, we want to wait until the results
                    // come back before proceeding with any test.
                    in_time(VASTResponse) should_not be_nil;

                    config = [[MPVideoConfig alloc] initWithVASTResponse:VASTResponse];
                });

                it(@"should still be able to get the correct values", ^{
                    config.minimumViewabilityTimeInterval should equal(30.5);
                    config.minimumFractionOfVideoVisible should equal(0.6);
                    config.viewabilityTrackingURL.absoluteString should equal(@"http://ad.server.com/impression/dot.gif");
                });
            });
        });
    });
});

SPEC_END
