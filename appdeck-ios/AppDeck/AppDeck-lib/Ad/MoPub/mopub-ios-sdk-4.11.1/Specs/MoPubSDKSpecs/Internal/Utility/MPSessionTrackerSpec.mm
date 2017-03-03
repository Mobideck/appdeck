#import "MPSessionTracker.h"
#import "MPIdentityProvider.h"
#import "MPGlobal.h"
#import "MPAPIEndpoints.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPSessionTrackerSpec)

describe(@"MPSessionTracker", ^{
    it(@"should notify MoPub when an application enters the foreground", ^{
        [NSURLConnection connections] should be_empty;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                            object:[UIApplication sharedApplication]];

        NSURLRequest *request = [[[NSURLConnection connections] objectAtIndex:0] request];
        [request valueForHTTPHeaderField:@"User-Agent"] should equal(@"FAKE_TEST_USER_AGENT_STRING");

        NSString *URL = request.URL.absoluteString;
        URL should contain(@"https://ads.mopub.com/m/open?v=8");
        URL should contain(@"&id=com.mopub.Specs");
        URL should contain(@"&av=1.0");
        URL should contain(@"&st=1");

        NSString *expectedIdentifierQuery = [NSString stringWithFormat:@"&udid=%@", [MPIdentityProvider identifier]];
        URL should contain(expectedIdentifierQuery);
    });

    it(@"should notify MoPub when an application finishes launching", ^{
        [NSURLConnection connections] should be_empty;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification
                                                            object:[UIApplication sharedApplication]];

        [NSURLConnection connections].count should equal(1);
        NSURLRequest *request = [[[NSURLConnection connections] lastObject] request];
        [request valueForHTTPHeaderField:@"User-Agent"] should equal(@"FAKE_TEST_USER_AGENT_STRING");

        NSString *URL = request.URL.absoluteString;
        URL should contain(@"https://ads.mopub.com/m/open?v=8");
        URL should contain(@"&id=com.mopub.Specs");
        URL should contain(@"&av=1.0");
        URL should contain(@"&st=1");

        NSString *expectedIdentifierQuery = [NSString stringWithFormat:@"&udid=%@", [MPIdentityProvider identifier]];
        URL should contain(expectedIdentifierQuery);
    });

    context(@"when HTTPS is disabled", ^{
        beforeEach(^{
            [MPAPIEndpoints setUsesHTTPS:NO];
        });

        afterEach(^{
            [MPAPIEndpoints setUsesHTTPS:YES];
        });

        it(@"should make its API calls over HTTP", ^{
            [NSURLConnection connections] should be_empty;
            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                object:[UIApplication sharedApplication]];

            NSURLRequest *request = [[[NSURLConnection connections] objectAtIndex:0] request];
            NSString *URL = request.URL.absoluteString;
            URL should contain(@"http://ads.mopub.com/m/open?v=8");
        });
    });
});

SPEC_END
