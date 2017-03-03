#import "MPAnalyticsTracker.h"
#import "MPAdConfigurationFactory.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAnalyticsTrackerSpec)

describe(@"MPAnalyticsTracker", ^{
    __block MPAnalyticsTracker *analyticsTracker;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
        analyticsTracker = [MPAnalyticsTracker tracker];
    });

    context(@"when told to track an impression", ^{
        __block NSURLConnection *connection;

        beforeEach(^{
            [analyticsTracker trackImpressionForConfiguration:configuration];
            connection = [NSURLConnection lastConnection];
        });

        it(@"should make a URL connection to the passed in URL", ^{
            connection.request.URL should equal(configuration.impressionTrackingURL);
        });

        it(@"should configure the request and connection correctly", ^{
            connection.request.cachePolicy should equal(NSURLRequestReloadIgnoringCacheData);
            [connection.request valueForHTTPHeaderField:@"User-Agent"] should equal(@"FAKE_TEST_USER_AGENT_STRING");
            connection.delegate should be_nil;
        });
    });

    context(@"when told to track a click", ^{
        __block NSURLConnection *connection;

        beforeEach(^{
            [analyticsTracker trackClickForConfiguration:configuration];
            connection = [NSURLConnection lastConnection];
        });

        it(@"should make a URL connection to the passed in URL", ^{
            connection.request.URL should equal(configuration.clickTrackingURL);
        });

        it(@"should configure the request and connection correctly", ^{
            connection.request.cachePolicy should equal(NSURLRequestReloadIgnoringCacheData);
            [connection.request valueForHTTPHeaderField:@"User-Agent"] should equal(@"FAKE_TEST_USER_AGENT_STRING");
            connection.delegate should be_nil;
        });
    });
});

SPEC_END
