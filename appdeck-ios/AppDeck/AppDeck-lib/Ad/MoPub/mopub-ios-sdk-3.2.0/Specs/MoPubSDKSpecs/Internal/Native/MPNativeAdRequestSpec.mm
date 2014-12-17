#import "MPNativeAdRequest.h"
#import "MPNativeAdRequestTargeting.h"
#import "FakeMPCoreInstanceProvider.h"
#import "MPAdConfigurationFactory.h"
#import "MPNativeCustomEventDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPNativeAdRequest (Specs) <MPNativeCustomEventDelegate, MPAdServerCommunicatorDelegate>

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, copy) MPNativeAdRequestHandler completionHandler;

@end

SPEC_BEGIN(MPNativeAdRequestSpec)

describe(@"MPNativeAdRequest", ^{
    __block MPNativeAdRequest *request;
    __block MPNativeAdRequestTargeting *targeting;
    __block FakeMPAdServerCommunicator *communicator;

    beforeEach(^{
        targeting = [[MPNativeAdRequestTargeting alloc] init];
        targeting.keywords = @"native_ad_request";

        request = [MPNativeAdRequest requestWithAdUnitIdentifier:@"native_identifier"];
        request.targeting = targeting;
        [request startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
            NSLog(@"completed");
        }];

        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
    });

    context(@"Building the Request", ^{

        it(@"should include the ad unit id", ^{
            communicator.loadedURL.absoluteString should contain(@"native_identifier");
        });

        it(@"should include the correct targeting keywords", ^{
            communicator.loadedURL.absoluteString should contain(@"native_ad_request");
        });
    });

    context(@"when the native custom event failed to be created", ^{
        it(@"should start the failover waterfall", ^{
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"NSFluffyMonkeyPandas"];

            [request communicatorDidReceiveAdConfiguration:configuration];
            communicator.loadedURL should equal(configuration.failoverURL);
        });
    });

    context(@"when the native custom event fails", ^{
        it(@"should start the failover waterfall", ^{
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultNativeAdConfigurationWithCustomEventClassName:@"NSFluffyMonkeyPandas"];
            [communicator receiveConfiguration:configuration];

            [request nativeCustomEvent:nil didFailToLoadAdWithError:nil];

            communicator.loadedURL should equal(configuration.failoverURL);
        });
    });

    context(@"when failoverURL is blank", ^{
        it(@"should call the completion block with an error", ^{
            __block BOOL completionCalled = NO;
            __block NSError *requestError = nil;

            request.completionHandler = ^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
                requestError = error;
                completionCalled = YES;
            };

            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultNativeAdConfigurationWithHeaders:@{kFailUrlHeaderKey: @""} properties:nil];
            [communicator receiveConfiguration:configuration];

            completionCalled should be_truthy;
            requestError should_not be_nil;
            request.loading should be_falsy;
        });
    });

    context(@"when failoverURL is nil", ^{
        it(@"should call the completion block with an error", ^{
            __block BOOL completionCalled = NO;
            __block NSError *requestError = nil;

            request.completionHandler = ^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
                requestError = error;
                completionCalled = YES;
            };

            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultNativeAdConfiguration];
            configuration.failoverURL = nil;
            [communicator receiveConfiguration:configuration];

            completionCalled should be_truthy;
            requestError should_not be_nil;
            request.loading should be_falsy;
        });
    });
});

SPEC_END
