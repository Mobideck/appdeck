#import "MPCoreInstanceProvider.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPCoreInstanceProvider (Spec)

@property (nonatomic, copy) NSString *userAgent;

@end

SPEC_BEGIN(MPCoreInstanceProviderSpec)

describe(@"MPCoreInstanceProvider", ^{
    __block MPCoreInstanceProvider *provider;

    beforeEach(^{
        provider = [[MPCoreInstanceProvider alloc] init];
    });


    describe(@"providing a reachability object", ^{
        it(@"should always provide the same singleton object", ^{
            MPReachability *firstReachability = [provider sharedMPReachability];
            MPReachability *secondReachability = [provider sharedMPReachability];
            firstReachability should be_instance_of([MPReachability class]);
            firstReachability should be_same_instance_as(secondReachability);
        });
    });

    describe(@"providing an analytics tracker", ^{
        it(@"should always provide the same singleton object", ^{
            MPAnalyticsTracker *firstTracker = [provider sharedMPAnalyticsTracker];
            MPAnalyticsTracker *secondTracker = [provider sharedMPAnalyticsTracker];
            firstTracker should be_instance_of([MPAnalyticsTracker class]);
            firstTracker should be_same_instance_as(secondTracker);
        });
    });

    describe(@"building a URL request", ^{
        it(@"should build the URL request, setting the user agent appropriately", ^{
            provider.userAgent = @"foo";

            NSURL *URL = [NSURL URLWithString:@"http://www.foo.com/"];
            NSMutableURLRequest *request = [provider buildConfiguredURLRequestWithURL:URL];
            [request valueForHTTPHeaderField:@"User-Agent"] should equal(@"foo");
            request.URL should equal(URL);
        });

        it(@"should still succeed in building a request when the URL is nil", ^{
            provider.userAgent = @"foo";

            NSMutableURLRequest *request = [provider buildConfiguredURLRequestWithURL:nil];
            [request valueForHTTPHeaderField:@"User-Agent"] should equal(@"foo");
            request.URL should be_nil;
        });
    });

});

SPEC_END
