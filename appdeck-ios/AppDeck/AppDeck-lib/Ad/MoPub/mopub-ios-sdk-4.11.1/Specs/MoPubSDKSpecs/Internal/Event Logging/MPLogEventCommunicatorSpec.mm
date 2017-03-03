#import "MPLogEventCommunicator.h"
#import "MPLogEvent.h"
#import "CedarAsync.h"
#import "NSURLConnection+MPSpecs.h"
#import "MPNetworkManager.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPNetworkManager ()

@property (strong, readonly) NSOperationQueue *networkTransferQueue;

@end

@interface MPMainRunLoopNetworkManager : MPNetworkManager

@end

@implementation MPMainRunLoopNetworkManager

// Overridden to keep operations on the main run loop.
- (void)addNetworkTransferOperation:(NSOperation *)operation
{
    [self.networkTransferQueue addOperation:operation];
}

@end

SPEC_BEGIN(MPLogEventCommunicatorSpec)

describe(@"MPLogEventCommunicator", ^{
    __block MPLogEventCommunicator *communicator;
    __block MPLogEvent *event;

    beforeEach(^{
        communicator = [[MPLogEventCommunicator alloc] init];
        event = [[MPLogEvent alloc] init];
        fakeCoreProvider.fakeNetworkManager = [[MPMainRunLoopNetworkManager alloc] init];
    });

    describe(@"when getting the current connection limit status with -isOverLimit", ^{
        it(@"should return YES if the connection queue is over limit", ^{
            [communicator sendEvents:@[event]];
            in_time([communicator isOverLimit]) should be_truthy;
        });

        it(@"should return NO if the connection queue is empty", ^{
            [communicator isOverLimit] should be_falsy;
        });
    });

    describe(@"when sending events with -sendEvents:", ^{
        beforeEach(^{
            [communicator sendEvents:@[event]];
        });

        it(@"should enqueue an operation using the shared network manager", ^{
            in_time([fakeCoreProvider.fakeNetworkManager networkTransferOperationCount]) should equal(1);
        });

        it(@"should eventually send the proper request to the server", ^{
            // Sanity check.
            [NSURLConnection lastConnection] should be_nil;

            // Allow time for the operation to be enqueued.
            in_time([fakeCoreProvider.fakeNetworkManager networkTransferOperationCount]) should equal(1);

            // Allow time for the operation to kick off the connection.
            in_time([NSURLConnection lastConnection]) should_not be_nil;

            // Confirm the request URL, method, and POST body.
            NSURLRequest *request = [[NSURLConnection lastConnection] request];
            request.URL.absoluteString should equal(@"https://analytics.mopub.com/i/jot/exchange_client_event");
            request.HTTPMethod should equal(@"POST");

            NSData *expectedJSON = [NSJSONSerialization dataWithJSONObject:@[[event asDictionary]] options:0 error:nil];
            NSString *expectedJSONString = [[NSString alloc] initWithData:expectedJSON encoding:NSUTF8StringEncoding];
            NSString *expectedBodyString = [NSString stringWithFormat:@"log=%@", [expectedJSONString mp_URLEncodedString]];
            request.HTTPBodyAsString should equal(expectedBodyString);
        });

        context(@"when the request finishes", ^{
            beforeEach(^{
                // Sanity check.
                [NSURLConnection lastConnection] should be_nil;

                // Allow time for the operation to be enqueued.
                in_time([fakeCoreProvider.fakeNetworkManager networkTransferOperationCount]) should equal(1);

                // Allow time for the operation to kick off the connection.
                in_time([NSURLConnection lastConnection]) should_not be_nil;
            });

            it(@"should complete the operation if the request was successful", ^{
                [[NSURLConnection lastConnection] receiveSuccessfulResponse:@""];

                in_time([fakeCoreProvider.fakeNetworkManager networkTransferOperationCount]) should equal(0);
            });

            it(@"should complete the operation if the request failed with a non-retryable status code", ^{
                [[NSURLConnection lastConnection] receiveResponseWithStatusCode:400 body:@""];

                in_time([fakeCoreProvider.fakeNetworkManager networkTransferOperationCount]) should equal(0);
            });

            xit(@"should retry later if the server appears overloaded", ^{
            });
        });
    });
});

SPEC_END
