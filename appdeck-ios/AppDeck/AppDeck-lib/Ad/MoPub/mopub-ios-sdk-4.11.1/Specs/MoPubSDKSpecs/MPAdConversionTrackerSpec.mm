#import "MPAdConversionTracker.h"
#import "MPIdentityProvider.h"
#import "NSErrorFactory.h"
#import "MPAPIEndpoints.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdConversionTrackerSpec)

describe(@"MPAdConversionTracker", ^{
    __block MPAdConversionTracker *tracker;
    __block NSString *applicationID;

    beforeEach(^{
        tracker = [[MPAdConversionTracker alloc] init];
        applicationID = @"128405";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.mopub.conversion"];
    });

    context(@"when told to report", ^{
        __block NSURLConnection *connection;

        beforeEach(^{
            [NSURLConnection connections] should be_empty;
            [tracker reportApplicationOpenForApplicationID:applicationID];
            connection = [[NSURLConnection connections] lastObject];
        });

        it(@"should tell MoPub that the application has been installed", ^{
            NSURLRequest *request = [connection request];
            [request valueForHTTPHeaderField:@"User-Agent"] should equal(@"FAKE_TEST_USER_AGENT_STRING");

            NSString *URL = request.URL.absoluteString;
            URL should contain(@"https://ads.mopub.com/m/open?v=8");
            URL should contain(@"&id=128405");
            URL should contain(@"&av=1.0");

            NSString *expectedIdentifierQuery = [NSString stringWithFormat:@"&udid=%@", [MPIdentityProvider identifier]];
            URL should contain(expectedIdentifierQuery);
        });

        context(@"when the request succeeds", ^{
            it(@"should never tell MoPub again", ^{
                [connection receiveSuccesfulResponseWithBody:@"OK"];

                [NSURLConnection resetAll];
                [tracker reportApplicationOpenForApplicationID:applicationID];
                [NSURLConnection connections] should be_empty;
            });
        });

        context(@"when the request fails", ^{
            context(@"because the connection failed", ^{
                it(@"should try to tell MoPub the next time", ^{
                    [connection failWithError:[NSErrorFactory genericError]];

                    [NSURLConnection resetAll];
                    [tracker reportApplicationOpenForApplicationID:applicationID];
                    [NSURLConnection connections] should_not be_empty;
                });
            });

            context(@"because of an empty body", ^{
                it(@"should try to tell MoPub the next time", ^{
                    [connection receiveSuccessfulResponse:@""];

                    [NSURLConnection resetAll];
                    [tracker reportApplicationOpenForApplicationID:applicationID];
                    [NSURLConnection connections] should_not be_empty;
                });
            });

            context(@"because of a failed status code", ^{
                it(@"should try to tell MoPub the next time", ^{
                    [connection receiveResponseWithStatusCode:500 body:@"UH OH!"];

                    [NSURLConnection resetAll];
                    [tracker reportApplicationOpenForApplicationID:applicationID];
                    [NSURLConnection connections] should_not be_empty;
                });
            });
        });
    });

    context(@"when HTTPS is disabled", ^{
        beforeEach(^{
            [MPAPIEndpoints setUsesHTTPS:NO];
        });

        afterEach(^{
            [MPAPIEndpoints setUsesHTTPS:YES];
        });

        it(@"should make its API call over HTTP", ^{
            [tracker reportApplicationOpenForApplicationID:applicationID];
            NSURLConnection *connection = [[NSURLConnection connections] lastObject];

            NSURLRequest *request = [connection request];
            NSString *URL = request.URL.absoluteString;
            URL should contain(@"http://ads.mopub.com/m/open?v=8");
        });
    });
});

SPEC_END
