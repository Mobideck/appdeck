#import "MPBaseBannerAdapter.h"
#import "MPConstants.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ConcreteBannerAdapter : MPBaseBannerAdapter

- (void)simulateLoadingFinished;

@end

@implementation ConcreteBannerAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
}

- (void)simulateLoadingFinished
{
    [self didStopLoading];
}

@end

SPEC_BEGIN(MPBaseBannerAdapterSpec)

describe(@"MPBaseBannerAdapter", ^{
    __block ConcreteBannerAdapter *adapter;
    __block id<CedarDouble, MPBannerAdapterDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerAdapterDelegate));
        adapter = [[ConcreteBannerAdapter alloc] initWithDelegate:delegate];
    });

    describe(@"timing out requests", ^{
        context(@"when beginning a request", ^{
            beforeEach(^{
                [adapter _getAdWithConfiguration:nil containerSize:CGSizeZero];
            });

            it(@"should timeout and tell the delegate about the failure after 10 seconds", ^{
                [fakeCoreProvider advanceMPTimers:10];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            context(@"when the request finishes before the timeout", ^{
                beforeEach(^{
                    [fakeCoreProvider advanceMPTimers:5];
                    [adapter simulateLoadingFinished];
                });

                it(@"should not, later, fire the timeout", ^{
                    [delegate reset_sent_messages];
                    [fakeCoreProvider advanceMPTimers:5];
                    delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
                });
            });
        });

        context(@"when beginning a request with a 60 second configured timeout", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"60"};
                configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should not timeout before the configurable value", ^{
                [fakeCoreProvider advanceMPTimers:59];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            it(@"should timeout and tell the delegate after 60 seconds", ^{
                [fakeCoreProvider advanceMPTimers:60];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            // NOTE: Not testing "when the request finishes" here since that behavior will always be the same
            //       regardless of what timeout value is set
        });

        context(@"when beginning a request with a 1 second configured timeout", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"1"};
                configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should not timeout before the configurable value", ^{
                [fakeCoreProvider advanceMPTimers:0];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            it(@"should timeout and tell the delegate after 1 second", ^{
                [fakeCoreProvider advanceMPTimers:1];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });
        });

        context(@"when beginning a request with a 0 second configured timeout", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"0"};
                configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should never time out", ^{
                // should technically wait forever, not passing MAX val here since the impl of
                // fakeProvider's fake timer does involve a loop and would slow the test too much
                [fakeCoreProvider advanceMPTimers:999999];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });
        });

        context(@"when beginning a request with an configured timeout that is a negative value", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"-1"};
                configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should not timeout before the default timeout interval", ^{
                [fakeCoreProvider advanceMPTimers:BANNER_TIMEOUT_INTERVAL - 1];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            it(@"should timeout and tell the delegate using the default timeout interval", ^{
                [fakeCoreProvider advanceMPTimers:BANNER_TIMEOUT_INTERVAL];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });
        });
    });
});

SPEC_END
