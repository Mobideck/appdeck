#import <Cedar/Cedar.h>
#import "MPRewardedVideoConnection.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPRewardedVideoConnection()

@property (nonatomic) NSTimeInterval accumulatedRetryInterval;
@property (nonatomic, weak) id<MPRewardedVideoConnectionDelegate> delegate;

- (NSTimeInterval)backoffTime:(NSUInteger)retryCount;
- (void)retryRewardedVideoCompletionRequest;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@end

SPEC_BEGIN(MPRewardedVideoConnectionSpec)

describe(@"MPRewardedVideoConnectionSpec", ^{

    __block MPRewardedVideoConnection *connection;
    __block id<MPRewardedVideoConnectionDelegate, CedarDouble> delegate;


    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPRewardedVideoConnectionDelegate));
        connection = [[MPRewardedVideoConnection alloc] initWithUrl:[NSURL URLWithString:@"http://ads.mopub.com/m/rewarded_video_completion?req=332dbe5798d644309d9d950321d37e3c&reqt=1460590468.0&id=54c94899972a4d4fb00c9cbf0fd08141&cid=303d4529ee3b42e7ac1f5c19caf73515&udid=ifa%3A3E67D059-6F94-4C88-AD2A-72539FE13795&cppck=09CCC"] delegate:delegate];
    });

    context(@"backoffTime:", ^{
        context(@"when retryCount is 0", ^{
            it(@"backOffTime should be 5", ^{
                [connection backoffTime:0] should equal(5);
            });
        });

        context(@"when retryCount is 1", ^{
            it(@"backOffTime should be 10", ^{
                [connection backoffTime:1] should equal(10);
            });
        });

        context(@"when retryCount is 2", ^{
            it(@"backOffTime should be 20", ^{
                [connection backoffTime:2] should equal(20);
            });
        });

        context(@"when retryCount is 3", ^{
            it(@"backOffTime should be 40", ^{
                [connection backoffTime:3] should equal(40);
            });
        });

        context(@"when retryCount is 4", ^{
            it(@"backOffTime should be 60", ^{
                [connection backoffTime:4] should equal(60);
            });
        });

        context(@"when retryCount is 5", ^{
            it(@"backOffTime should be 60", ^{
                [connection backoffTime:5] should equal(60);
            });
        });
    });

    describe(@"connection:didFailWithError:", ^{
        context(@"when errorCode is timeout", ^{
            beforeEach(^{
                spy_on(connection);
                NSError *error = [NSError errorWithDomain:@"ads.mopub.com" code:NSURLErrorTimedOut userInfo:nil];
                [connection connection:nil didFailWithError:error];
            });
            it(@"should call retryRewardedVideoCompletionRequest", ^{
                connection should have_received(@selector(retryRewardedVideoCompletionRequest));
            });
        });

        context(@"when errorCode is non-timeout or connection related", ^{
            beforeEach(^{
                spy_on(connection);
                NSError *error = [NSError errorWithDomain:@"ads.mopub.com" code:NSURLErrorUnknown userInfo:nil];
                [connection connection:nil didFailWithError:error];
            });
            it(@"should not call retryRewardedVideoCompletionRequest", ^{
                connection should_not have_received(@selector(retryRewardedVideoCompletionRequest));
            });
        });
    });

    describe(@"connection:didReceiveResponse:", ^{
        context(@"when statusCode >= 500", ^{
            beforeEach(^{
                spy_on(connection);
                NSURLResponse<CedarDouble> *mockResponse = nice_fake_for([NSURLResponse class]);
                mockResponse stub_method(@selector(statusCode)).and_return(500);

                [connection connection:nil didReceiveResponse:mockResponse];
            });
            it(@"should call retryRewardedVideoCompletionRequest", ^{
                connection should have_received(@selector(retryRewardedVideoCompletionRequest));
            });
        });

        context(@"when statusCode is < 500", ^{
            beforeEach(^{
                spy_on(connection);
                NSURLResponse<CedarDouble> *mockResponse = nice_fake_for([NSURLResponse class]);
                mockResponse stub_method(@selector(statusCode)).and_return(404);

                [connection connection:nil didReceiveResponse:mockResponse];
            });
            it(@"should not call retryRewardedVideoCompletionRequest", ^{
                connection should_not have_received(@selector(retryRewardedVideoCompletionRequest));
            });
        });
    });

    describe(@"when retryRewardedVideoCompletionRequest is called", ^{
        context(@"when retry interval < kMaximumRequestRetryInterval, retry once", ^{
            beforeEach(^{
                spy_on(connection.delegate);
                // accumulated retry interval: 5s
                [connection retryRewardedVideoCompletionRequest];
            });
            it(@"should retry (rewardedVideoConnectionCompleted:url: should not be called)", ^{
                connection.delegate should_not have_received(@selector(rewardedVideoConnectionCompleted:url:));
            });
        });

        context(@"when retry interval < kMaximumRequestRetryInterval, retry twice", ^{
            beforeEach(^{
                spy_on(connection.delegate);
                // accumulated retry interval: 5+10 = 15s
                [connection retryRewardedVideoCompletionRequest];
                [connection retryRewardedVideoCompletionRequest];
            });
            it(@"should retry (rewardedVideoConnectionCompleted:url: should not be called)", ^{
                connection.delegate should_not have_received(@selector(rewardedVideoConnectionCompleted:url:));
            });
        });

        context(@"when retry interval < kMaximumRequestRetryInterval (retry 17 times)", ^{
            beforeEach(^{
                spy_on(connection.delegate);
                // accumulated retry interval: 5+10+20+40+60*13 = 855s
                for (int i = 0; i < 17; i++) {
                    [connection retryRewardedVideoCompletionRequest];
                }
            });
            it(@"should retry (rewardedVideoConnectionCompleted:url: should not be called)", ^{
                connection.delegate should_not have_received(@selector(rewardedVideoConnectionCompleted:url:));
            });
        });

        context(@"when retry interval > kMaximumRequestRetryInterval (retry 18 times)", ^{
            beforeEach(^{
                spy_on(connection.delegate);
                // accumulated retry interval: 5+10+20+40+60*14 = 915s
                for (int i = 0; i < 18; i++) {
                    [connection retryRewardedVideoCompletionRequest];
                }
            });
            it(@"should not retry anymore (rewardedVideoConnectionCompleted:url: should be called)", ^{
                connection.delegate should have_received(@selector(rewardedVideoConnectionCompleted:url:));
            });
        });

    });

});

SPEC_END
