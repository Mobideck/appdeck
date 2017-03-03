#import "MPNativeAdRequest.h"
#import "MPNativeAdRequestTargeting.h"
#import "FakeMPCoreInstanceProvider.h"
#import "MPAdConfigurationFactory.h"
#import "MPNativeCustomEventDelegate.h"
#import "MPLogEventRecorder.h"
#import "FakeMPLogEventRecorder.h"
#import "MPLogEvent.h"
#import "MPIdentityProvider.h"
#import "MPNativeAdRendererConfiguration.h"
#import "FakeNativeAdRenderingClass.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPMoPubNativeAdAdapter.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface MPNativeAdRequest (Specs) <MPNativeCustomEventDelegate, MPAdServerCommunicatorDelegate>

@property (nonatomic) MPAdConfiguration *adConfiguration;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, copy) MPNativeAdRequestHandler completionHandler;

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration;
- (void)completeAdRequestWithAdObject:(MPNativeAd *)adObject error:(NSError *)error;

@end

SPEC_BEGIN(MPNativeAdRequestSpec)

describe(@"MPNativeAdRequest", ^{
    __block MPNativeAdRequest *request;
    __block MPNativeAdRequestTargeting *targeting;
    __block FakeMPAdServerCommunicator *communicator;
    __block FakeMPLogEventRecorder *eventRecorder;
    __block BOOL successfullyLoadedNativeAd;
    __block MPStaticNativeAdRenderer *renderer;
    __block NSArray *nativeAdRendererConfigurations;

    beforeEach(^{
        MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];

        settings.renderingViewClass = [FakeNativeAdRenderingClass class];
        settings.viewSizeHandler = ^(CGFloat maxWidth) {
            return CGSizeMake(70, 113);
        };

        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];

        MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
        nativeAdRendererConfigurations = @[config];

        eventRecorder = [[FakeMPLogEventRecorder alloc] init];
        spy_on(eventRecorder);
        fakeCoreProvider.fakeLogEventRecorder = eventRecorder;
        targeting = [[MPNativeAdRequestTargeting alloc] init];
        targeting.keywords = @"native_ad_request";

        successfullyLoadedNativeAd = NO;

        request = [MPNativeAdRequest requestWithAdUnitIdentifier:@"native_identifier" rendererConfigurations:nativeAdRendererConfigurations];
        request.targeting = targeting;
        [request startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
            NSLog(@"completed");
            successfullyLoadedNativeAd = error == nil;
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

    describe(@"requesting an ad", ^{
        __block NSString *url;
        __block NSURLResponse *response;
        __block NSDictionary *headers;

        beforeEach(^{
            url = communicator.loadedURL.absoluteString;

            headers = @{
                        @"X-Adtype" : @"native",
                        @"X-Creativeid" : @"d06f9bde98134f76931cdf04951b60dd",
                        @"X-Failurl" : @"http://ads.mopub.com/m/ad?v=8&udid=ifa:01C61C79-9EA0-458C-BFBB-C58F084225A7&id=c92be421345c4eab964645f6a1818284&nv=3.5.0&o=p&sc=2.0&z=-0700&mr=1&ct=2&av=1.0&dn=x86_64&exclude=365cd2475e074026b93da14103a36b97&request_id=f43228d3df2643408f9f8dc9c384603d&fail=1",
                        @"X-Height" : @50,
                        @"X-Width" : @320,
                        };

            response = [[NSURLResponse alloc] init];
            spy_on(response);
            response stub_method(@selector(allHeaderFields)).and_return(headers);

            [communicator loadURL:[NSURL URLWithString:url]];
            [communicator connection:nil didReceiveResponse:response];

        });

        // TODO: Add tests for this. For both failure and success.
        xcontext(@"choosing renderers for custom events", ^{

        });

        context(@"when the load succeeds", ^{
            it(@"should log a latency successful event with the data filled out correctly", ^{
                [communicator connectionDidFinishLoading:nil];
                eventRecorder should have_received(@selector(addEvent:));

                NSString *obfuscatedURI = [url stringByReplacingOccurrencesOfString:[MPIdentityProvider identifier]
                                                                         withString:[MPIdentityProvider obfuscatedIdentifier]];

                MPLogEvent *event = eventRecorder.events[0];
                event.requestStatusCode should equal(200);
                event.requestURI should equal(obfuscatedURI);
                // The MPAdConfiguration implementation has not been updated since Native/Rewarded
                // ad types were introduced.
                event.adType should equal(@"native");
            });

            context(@"when the adapter has an adConfiguration property", ^{
                it(@"should set the adapter's adConfiguration to the request's adConfiguration", ^{
                    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] init];
                    MPNativeAd *nativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];
                    request.adConfiguration = [[MPAdConfiguration alloc] init];

                    [request completeAdRequestWithAdObject:nativeAd error:nil];

                    adapter.adConfiguration should equal(request.adConfiguration);
                });
            });

            context(@"when the adapter doesn't have an adConfiguration property", ^{
                it(@"should not attempt to set the adapter's adConfiguration to the request's adConfiguration", ^{
                    ^{
                        // We don't include adConfiguration in the base class (MPNativeAdAdapter), so it is not implemented by default.
                        id<CedarDouble,MPNativeAdAdapter> adapter = nice_fake_for(@protocol(MPNativeAdAdapter));

                        MPNativeAd *nativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];
                        request.adConfiguration = [[MPAdConfiguration alloc] init];

                        [request completeAdRequestWithAdObject:nativeAd error:nil];
                    } should_not raise_exception;
                });
            });
        });

        context(@"when the load fails", ^{
            beforeEach(^{
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
                url = communicator.loadedURL.absoluteString;
                [communicator connection:nil didFailWithError:error];
            });

            it(@"should log an unsuccessful latency event with the data filled out correctly", ^{
                eventRecorder should_not have_received(@selector(addEvent:));
            });
        });
    });

    context(@"when given json that can't be parsed", ^{
        __block MPAdConfiguration *configuration;

        beforeEach(^{
            configuration = [MPAdConfigurationFactory defaultNativeAdConfigurationWithNetworkType:kAdTypeNative];
            spy_on(configuration);
            NSData *jsonData = [@"not {json" dataUsingEncoding:NSUTF8StringEncoding];
            configuration stub_method(@selector(adResponseData)).and_return(jsonData);
        });

        it(@"should record an MPREvent error", ^{
            [request getAdWithConfiguration:configuration];
            eventRecorder should_not have_received(@selector(addEvent:));
        });

    });

    context(@"when the ad unit is warming up", ^{
        beforeEach(^{
            successfullyLoadedNativeAd = YES;
        });

        it(@"should report an error to the completion block", ^{
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultNativeAdConfigurationWithHeaders:@{@"X-Warmup":@"1"} properties:nil];

            [request communicatorDidReceiveAdConfiguration:configuration];
            successfullyLoadedNativeAd should be_falsy;
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
#pragma clang diagnostic pop
