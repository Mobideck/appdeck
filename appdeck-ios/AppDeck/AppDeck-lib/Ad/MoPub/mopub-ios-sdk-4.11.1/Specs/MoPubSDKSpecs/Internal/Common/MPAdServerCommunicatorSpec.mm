#import "MPAdServerCommunicator.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPLogEventRecorder.h"
#import "MPLogEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface FakeMPAdServerCommunicatorDelegate : NSObject <MPAdServerCommunicatorDelegate>

@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, strong) NSError *error;

@end

@implementation FakeMPAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfiguration *)configuration
{
    self.configuration = configuration;
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.error = error;
}

@end

@interface MPAdServerCommunicator (MPSpecs)

@property (nonatomic) MPLogEvent *adRequestLatencyEvent;

@end

SPEC_BEGIN(MPAdServerCommunicatorSpec)

describe(@"MPAdServerCommunicator", ^{
    __block MPAdServerCommunicator *communicator;
    __block FakeMPAdServerCommunicatorDelegate *delegate;
    __block FakeMPLogEventRecorder *eventRecorder;

    beforeEach(^{
        eventRecorder = [[FakeMPLogEventRecorder alloc] init];
        spy_on(eventRecorder);
        fakeCoreProvider.fakeLogEventRecorder = eventRecorder;

        delegate = [[FakeMPAdServerCommunicatorDelegate alloc] init];
        communicator = [[MPAdServerCommunicator alloc] initWithDelegate:delegate];
    });

    describe(@"when told to load a URL", ^{
        __block NSURL *URL;
        __block NSURLConnection *connection;

        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.mopub.com"];
            [communicator loadURL:URL];
            connection = [NSURLConnection lastConnection];
        });

        it(@"should make a connection", ^{
            connection.request.URL should equal(URL);
        });

        it(@"should be loading", ^{
            communicator.loading should equal(YES);
        });

        it(@"should create a log event", ^{
            communicator.adRequestLatencyEvent should_not be_nil;
        });

        context(@"when the request succeeds", ^{
            beforeEach(^{
                NSDictionary *headers = [MPAdConfigurationFactory defaultBannerHeaders];
                PSHKFakeHTTPURLResponse *response = [[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:200
                                                                                             andHeaders:headers
                                                                                                andBody:@"<h1>Foo</h1>"];
                [connection receiveResponse:response];
            });

            it(@"should create a configuration and notify the delegate", ^{
                delegate.configuration.preferredSize.height should equal(50);
                delegate.configuration.adResponseHTMLString should equal(@"<h1>Foo</h1>");
            });

            it(@"should not be loading", ^{
                communicator.loading should equal(NO);
            });

            it(@"should log an event with data about the request", ^{
                eventRecorder should have_received(@selector(addEvent:));

                MPLogEvent *event = eventRecorder.events[0];
                event.requestStatusCode should equal(200);
                event.requestURI should equal(URL.absoluteString);
                event.adType should equal(@"html");
                event.eventCategory should equal(@"requests");
            });

            it(@"should log an event that records the correct performanceDurationMs", PENDING);
        });

        context(@"when the request fails", ^{
            context(@"because the request is not in the success range", ^{
                beforeEach(^{
                    PSHKFakeHTTPURLResponse *response = [[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:404
                                                                                                 andHeaders:nil
                                                                                                    andBody:nil];
                    [connection receiveResponse:response];
                });

                it(@"should notify the delegate", ^{
                    delegate.configuration should be_nil;
                    delegate.error.code should equal(404);
                });

                it(@"should not be loading", ^{
                    communicator.loading should equal(NO);
                });

                it(@"should not log an event", ^{
                    eventRecorder should_not have_received(@selector(addEvent:));
                });
            });

            context(@"because the connection failed", ^{
                __block NSError *error;

                beforeEach(^{
                    error = [NSErrorFactory genericError];
                    [connection failWithError:error];
                });

                it(@"should notify the delegate", ^{
                    delegate.configuration should be_nil;
                    delegate.error should equal(error);
                });

                it(@"should not be loading", ^{
                    communicator.loading should equal(NO);
                });

                it(@"should not log an  event", ^{
                    eventRecorder should_not have_received(@selector(addEvent:));
                });
            });
        });

        describe(@"when cancelled", ^{
            beforeEach(^{
                [communicator cancel];
            });

            it(@"should cancel the request", ^{
                [NSURLConnection connections] should be_empty;
            });

            it(@"should not be loading", ^{
                communicator.loading should equal(NO);
            });

            it(@"should not submit a latency log event", ^{
                eventRecorder should_not have_received(@selector(addEvent:));
            });
        });
    });
});

SPEC_END
