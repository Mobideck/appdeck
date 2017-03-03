#import "MPNativePositionSource.h"
#import "MPIdentityProvider.h"
#import "MPConstants.h"
#import "CedarAsync.h"
#import "MPAPIEndpoints.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#define TEST_ID @"AD_UNIT_ID"

////////////////////////////////////////////////////////////////////////////////////////////////////

// Expose properties to test backoff mechanism.

@interface MPNativePositionSource (Spec) <NSURLConnectionDataDelegate>

@property (nonatomic, assign) NSTimeInterval maximumRetryInterval;
@property (nonatomic, assign) NSTimeInterval minimumRetryInterval;
@property (nonatomic, assign) NSTimeInterval retryInterval;
@property (nonatomic, assign) NSUInteger retryCount;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

SPEC_BEGIN(MPNativePositionSourceSpec)

describe(@"MPNativePositionSource", ^{
    __block MPNativePositionSource *positionSource;

    beforeEach(^{
        positionSource = [[MPNativePositionSource alloc] init];
    });

    describe(@"-loadPositionsWithAdUnitIdentifier:completionHandler:", ^{
        describe(@"usage failures", ^{
            it(@"should raise an exception if given a nil completion handler", ^{
                ^{
                    [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:nil];
                } should raise_exception;
            });

            it(@"should invoke the completion handler with an error when given a nil identifier", ^{
                __block NSError *returnedError = nil;
                [positionSource loadPositionsWithAdUnitIdentifier:nil completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                    returnedError = error;
                }];
                returnedError should_not be_nil;

                // Make sure no request was made.
                [NSURLConnection lastConnection] should be_nil;
            });
        });

        describe(@"valid usage", ^{
            __block BOOL didCallCompletionHandler;
            __block MPAdPositioning *returnedPositioning;
            __block NSError *returnedError;

            beforeEach(^{
                didCallCompletionHandler = NO;

                // Disable retries for these tests. Retry logic is tested separately.
                positionSource.maximumRetryInterval = 0;

                [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                    didCallCompletionHandler = YES;
                    returnedPositioning = positioning;
                    returnedError = error;
                }];
            });

            it(@"should make an ad server request", ^{
                NSURL *requestURL = [[[NSURLConnection lastConnection] request] URL];
                requestURL.host should equal(@"ads.mopub.com");
                requestURL.path should equal(@"/m/pos");

                NSString *queryString = requestURL.query;
                queryString should contain([NSString stringWithFormat:@"id=%@", TEST_ID]);
                queryString should contain([NSString stringWithFormat:@"v=%@", MP_SERVER_VERSION]);
                queryString should contain([NSString stringWithFormat:@"nsv=%@", MP_SDK_VERSION]);
                queryString should contain([NSString stringWithFormat:@"udid=%@", [MPIdentityProvider identifier]]);
            });

            context(@"when HTTPS is disabled", ^{
                beforeEach(^{
                    [MPAPIEndpoints setUsesHTTPS:NO];
                });

                afterEach(^{
                    [MPAPIEndpoints setUsesHTTPS:YES];
                });

                it(@"should make an ad server request over HTTP", ^{
                    [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                        didCallCompletionHandler = YES;
                        returnedPositioning = positioning;
                        returnedError = error;
                    }];

                    NSURL *requestURL = [[[NSURLConnection lastConnection] request] URL];
                    requestURL.scheme should equal(@"http");
                    requestURL.host should equal(@"ads.mopub.com");
                    requestURL.path should equal(@"/m/pos");
                });
            });

            context(@"when the server returns valid JSON", ^{
                it(@"should invoke the completion handler indicating success", ^{
                    [[NSURLConnection lastConnection] receiveSuccessfulResponse:@"{\"repeating\": {\"interval\": 5}}"];

                    didCallCompletionHandler should be_truthy;
                    returnedError should be_nil;
                    returnedPositioning should_not be_nil;
                });
            });

            context(@"when the server returns something invalid", ^{
                it(@"should invoke the completion handler with an error", ^{
                    [[NSURLConnection lastConnection] receiveSuccessfulResponse:@"this-is-not-json"];

                    didCallCompletionHandler should be_truthy;
                    returnedError should_not be_nil;
                    returnedPositioning should be_nil;
                });
            });

            context(@"when the server returns an empty payload", ^{
                it(@"should invoke the completion handler with an error", ^{
                    // If the server returns 200 but with no content, -connectionDidFinishLoading:
                    // can be called with no calls to -connection:didReceiveData:.
                    [positionSource connectionDidFinishLoading:[NSURLConnection lastConnection]];

                    didCallCompletionHandler should be_truthy;
                    returnedError should_not be_nil;
                    returnedPositioning should be_nil;
                });
            });

            context(@"when the connection fails", ^{
                it(@"should invoke the completion handler with an error", ^{
                    [[NSURLConnection lastConnection] failWithError:[NSErrorFactory genericError]];

                    didCallCompletionHandler should be_truthy;
                    returnedError should_not be_nil;
                    returnedPositioning should be_nil;
                });
            });

            describe(@"making a request while another is in-flight", ^{
                it(@"should cancel the first request", ^{
                    // Receive some data for the first request, but don't complete the request.
                    NSURLConnection *firstConnection = [NSURLConnection lastConnection];
                    NSData *dataForFirstRequest = [@"some_data" dataUsingEncoding:NSUTF8StringEncoding];
                    [positionSource connection:firstConnection didReceiveData:dataForFirstRequest];

                    [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                        didCallCompletionHandler = YES;
                        returnedPositioning = positioning;
                        returnedError = error;
                    }];

                    // Verify that the first connection has been canceled.
                    [NSURLConnection connections] should_not contain(firstConnection);
                    didCallCompletionHandler should be_falsy;

                    // Verify that a new connection has started.
                    [NSURLConnection lastConnection] should_not be_nil;
                    [NSURLConnection lastConnection] should_not be_same_instance_as(firstConnection);

                    [[NSURLConnection lastConnection] receiveSuccessfulResponse:@"{\"repeating\": {\"interval\": 5}}"];
                    didCallCompletionHandler should be_truthy;
                    returnedError should be_nil;
                    returnedPositioning.repeatingInterval should equal(5);
                });
            });
        });
    });

    describe(@"retry behavior details", ^{
        beforeEach(^{
            // Set up a case where the maximum number of retries will be 3.
            positionSource.minimumRetryInterval = 0.2;
            positionSource.maximumRetryInterval = 1.0; // Retries will be 0.2, 0.4, 0.8.
        });

        xit(@"should retry on failure but stop retrying once the server returns a valid response", ^{
            __block BOOL didCallCompletionHandler = NO;
            __block MPAdPositioning *returnedPositioning;

            [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                didCallCompletionHandler = YES;
                returnedPositioning = positioning;
            }];

            // Fail the first request using an invalid response.
            [[NSURLConnection lastConnection] receiveSuccessfulResponse:@"this-is-not-json"];
            didCallCompletionHandler should be_falsy;

            // Allow some time for the retry to happen.
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
            [positionSource retryCount] should equal(1);

            // Allow the second request to succeed.
            [[NSURLConnection lastConnection] receiveSuccessfulResponse:@"{\"repeating\": {\"interval\": 5}}"];
            didCallCompletionHandler should be_truthy;
            returnedPositioning.repeatingInterval should equal(5);

            // Verify that no additional retries occur.
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
            [positionSource retryCount] should equal(1);
        });

        it(@"should retry multiple times up to its maximum backoff limit", ^{
            __block NSInteger completionHandlerCallCount = 0;

            [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                completionHandlerCallCount++;
            }];

            with_timeout(2.0, ^{
                NSUInteger (^myBlock)(void) = ^{
                    // Simulate continual failures.
                    [[NSURLConnection lastConnection] failWithError:[NSErrorFactory genericError]];
                    return [positionSource retryCount];
                };

                in_time(myBlock()) should equal(3);
            });

            // After 3 failed retries, the completion handler should be called.
            completionHandlerCallCount should equal(1);
        });

        it(@"should reset its backoff interval when calling -loadPositions again", ^{
            __block NSInteger completionHandlerCallCount = 0;

            [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                completionHandlerCallCount++;
            }];

            with_timeout(2.0, ^{
                NSUInteger (^myBlock)(void) = ^{
                    // Simulate continual failures.
                    [[NSURLConnection lastConnection] failWithError:[NSErrorFactory genericError]];
                    return [positionSource retryCount];
                };

                in_time(myBlock()) should equal(3);
            });

            // After 3 failed retries, the completion handler should be called.
            completionHandlerCallCount should equal(1);

            // If we re-do the same request, it should reset its backoff interval and allow 3
            // additional retries.

            completionHandlerCallCount = 0;

            [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                completionHandlerCallCount++;
            }];

            with_timeout(2.0, ^{
                NSUInteger (^myBlock)(void) = ^{
                    // Simulate continual failures.
                    [[NSURLConnection lastConnection] failWithError:[NSErrorFactory genericError]];
                    return [positionSource retryCount];
                };

                in_time(myBlock()) should equal(3);
            });

            completionHandlerCallCount should equal(1);
        });

        it(@"should not retry a request that failed due to the response being empty", ^{
            __block BOOL didCallCompletionHandler = NO;
            [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                didCallCompletionHandler = YES;
            }];

            // Fail the request using an empty response.
            [[NSURLConnection lastConnection] receiveSuccessfulResponse:@""];

            // Verify that no additional retries occur.
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
            [positionSource retryCount] should equal(0);
            didCallCompletionHandler should be_truthy;
        });
    });

    describe(@"cancellation", ^{
        it(@"should cancel the current request", ^{
            __block NSInteger completionHandlerCallCount = 0;
            [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                completionHandlerCallCount++;
            }];

            // Save off the current connection, since -lastConnection will return nil once the
            // connection is canceled.
            NSURLConnection *connection = [NSURLConnection lastConnection];
            connection should_not be_nil;

            [positionSource cancel];

            // Verify that the completion handler doesn't get called even if the request succeeds.
            [connection receiveSuccessfulResponse:@"{\"repeating\": {\"interval\": 5}}"];
            completionHandlerCallCount should equal(0);
        });

        context(@"when a retry has been scheduled", ^{
            beforeEach(^{
                // A case where a retry will occur.
                positionSource.minimumRetryInterval = 0.3;
            });

            it(@"should cancel the retry", ^{
                __block NSInteger completionHandlerCallCount = 0;
                [positionSource loadPositionsWithAdUnitIdentifier:TEST_ID completionHandler:^(MPAdPositioning *positioning, NSError *error) {
                    completionHandlerCallCount++;
                }];

                // Simulate a failure (which should schedule a retry) and then cancel.
                [[NSURLConnection lastConnection] failWithError:[NSErrorFactory genericError]];
                positionSource.retryInterval should_not be_close_to(0.3);
                [positionSource cancel];

                // Allow time for the retry.
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

                // Verify that the retry didn't occur.
                positionSource.retryCount should equal(0);
                completionHandlerCallCount should equal(0);
            });
        });
    });
});

SPEC_END
