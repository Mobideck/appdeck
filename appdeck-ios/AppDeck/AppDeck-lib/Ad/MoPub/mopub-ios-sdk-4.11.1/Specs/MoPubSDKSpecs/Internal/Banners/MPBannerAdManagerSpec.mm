#import "MPBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPAdConfigurationFactory.h"
#import "FakeBannerCustomEvent.h"
#import "MPConstants.h"
#import "MPLogEventRecorder.h"
#import "MPLogEvent.h"
#import "CedarAsync.h"
#import "FakeMPLogEventRecorder.h"
#import "MPIdentityProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface MPTimer (Specs)

@property (nonatomic, assign) BOOL isPaused;

@end

SPEC_BEGIN(MPBannerAdManagerSpec)

describe(@"MPBannerAdManager", ^{
    __block MPBannerAdManager *manager;
    __block id<CedarDouble, MPBannerAdManagerDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;
    __block FakeMPLogEventRecorder *eventRecorder;

    beforeEach(^{
        // XXX: The geolocation provider can cause these tests to be flaky, since it can potentially
        // override the `location` property of MPAdView. For this reason, we substitute a fake
        // geolocation provider that never establishes a known location.
        FakeMPGeolocationProvider *fakeGeolocationProvider = [[FakeMPGeolocationProvider alloc] init];
        fakeCoreProvider.fakeGeolocationProvider = fakeGeolocationProvider;

        eventRecorder = [[FakeMPLogEventRecorder alloc] init];
        spy_on(eventRecorder);
        fakeCoreProvider.fakeLogEventRecorder = eventRecorder;
        delegate = nice_fake_for(@protocol(MPBannerAdManagerDelegate));
        manager = [[MPBannerAdManager alloc] initWithDelegate:delegate];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
    });

    describe(@"loading requests", ^{
        it(@"should request the correct URL", ^{
            delegate stub_method("adUnitId").and_return(@"panther");
            delegate stub_method("keywords").and_return(@"liono");
            delegate stub_method("location").and_return([[CLLocation alloc] initWithLatitude:30 longitude:20]);
            delegate stub_method("isTesting").and_return(YES);

            [manager loadAd];

            NSString *URL = communicator.loadedURL.absoluteString;
            URL should contain(@"id=panther");
            URL should contain(@"q=liono");
            URL should contain(@"ll=30,20");
            URL should contain(@"https://testing.ads.mopub.com");
        });
    });

    describe(@"logging events on requests", ^{
        __block NSString *url;
        __block NSURLResponse *response;
        __block NSDictionary *headers;
        beforeEach(^{
            [manager loadAd];
            url = communicator.loadedURL.absoluteString;

            headers = @{
                        @"X-Adtype" : @"banner",
                        @"X-Creativeid" : @"d06f9bde98134f76931cdf04951b60dd",
                        @"X-Failurl" : @"http://ads.mopub.com/m/ad?v=8&udid=ifa:01C61C79-9EA0-458C-BFBB-C58F084225A7&id=c92be421345c4eab964645f6a1818284&nv=3.5.0&o=p&sc=2.0&z=-0700&mr=1&ct=2&av=1.0&dn=x86_64&exclude=365cd2475e074026b93da14103a36b97&request_id=f43228d3df2643408f9f8dc9c384603d&fail=1",
                        @"X-Height" : @50,
                        @"X-Width" : @320,
                        };

            response = [[NSURLResponse alloc] init];
            spy_on(response);
            response stub_method(@selector(allHeaderFields)).and_return(headers);
        });

        afterEach(^{
            [eventRecorder.events removeAllObjects];
            [(id<CedarDouble>)eventRecorder reset_sent_messages];
        });

        context(@"when the request is successful", ^{
            it(@"should log an event with data about the request", ^{
                [communicator loadURL:[NSURL URLWithString:url]];
                [communicator connection:nil didReceiveResponse:response];
                [communicator connectionDidFinishLoading:nil];
                eventRecorder should have_received(@selector(addEvent:));

                NSString *obfuscatedURI = [url stringByReplacingOccurrencesOfString:[MPIdentityProvider identifier]
                                                                         withString:[MPIdentityProvider obfuscatedIdentifier]];

                MPLogEvent *event = eventRecorder.events[0];
                event.requestStatusCode should equal(200);
                event.requestURI should equal(obfuscatedURI);
                event.adType should equal(@"banner");
            });
        });

        context(@"when the request fails to load", ^{
            it(@"should log an unsuccessful latency event", ^{
                [communicator loadURL:[NSURL URLWithString:url]];
                [communicator failWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                code:NSURLErrorNotConnectedToInternet
                                                            userInfo:nil]];
                eventRecorder should_not have_received(@selector(addEvent:));

            });
        });
    });

    describe(@"responding to application visibility updates", ^{
        __block MPTimer *refreshTimer;
        __block FakeBannerCustomEvent *event;

        beforeEach(^{
            [manager loadAd];

            event = [[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero];
            fakeProvider.fakeBannerCustomEvent = event;

            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
            configuration.refreshInterval = 20;
            [communicator receiveConfiguration:configuration];

            [event simulateLoadingAd];
        });

        context(@"when autorefresh is enabled", ^{
            beforeEach(^{
                refreshTimer = [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                refreshTimer.isPaused should equal(NO);
            });

            it(@"should pause the timer when the app enters the background", ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

                refreshTimer.isPaused should equal(YES);
            });

            it(@"should make a new ad request when the app comes to the foreground", ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

                refreshTimer.isPaused should equal(YES);

                spy_on(manager);
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];

                manager should have_received(@selector(loadAdWithURL:));
            });
        });

        context(@"when autorefresh is disabled", ^{
            beforeEach(^{
                [manager stopAutomaticallyRefreshingContents];

                refreshTimer = [fakeCoreProvider lastFakeMPTimerWithSelector:@selector(refreshTimerDidFire)];
                refreshTimer.isPaused should equal(YES);
            });

            it(@"should pause the timer when the app enters the background", ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

                refreshTimer.isPaused should equal(YES);
            });

            it(@"should not make a new ad request when the app returns to the foreground", ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

                refreshTimer.isPaused should equal(YES);

                spy_on(manager);
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];

                manager should_not have_received(@selector(loadAdWithURL:));
            });
        });
    });

    describe(@"refresh timer edge cases", ^{
        context(@"when the requested ad unit loads successfully and it has a refresh interval", ^{
            it(@"should schedule the refresh timer with the given refresh interval", ^{
                [manager loadAd];

                FakeBannerCustomEvent *event = [[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero];
                fakeProvider.fakeBannerCustomEvent = event;

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                configuration.refreshInterval = 20;
                [communicator receiveConfiguration:configuration];

                [event simulateLoadingAd];

                [communicator resetLoadedURL];
                [fakeCoreProvider advanceMPTimers:20];
                communicator.loadedURL should_not be_nil;
            });
        });

        context(@"when the requested ad unit loads successfully and it has no refresh interval", ^{
            it(@"should not schedule the refresh timer", ^{
                [manager loadAd];

                FakeBannerCustomEvent *event = [[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero];
                fakeProvider.fakeBannerCustomEvent = event;

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                configuration.refreshInterval = -1;
                [fakeCoreProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                NSInteger numberOfTimers = fakeCoreProvider.fakeTimers.count;

                [event simulateLoadingAd];

                fakeCoreProvider.fakeTimers.count should equal(numberOfTimers);
            });
        });

        context(@"when the initial ad server request fails", ^{
            it(@"should schedule the default autorefresh timer", ^{
                [manager loadAd];
                FakeMPAdServerCommunicator *communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
                [communicator failWithError:nil];

                [communicator resetLoadedURL];
                [fakeCoreProvider advanceMPTimers:DEFAULT_BANNER_REFRESH_INTERVAL];
                communicator.loadedURL should_not be_nil;
            });
        });
    });

    describe(@"when the manager receives a malformed/unsupported configuration", ^{
        context(@"when the configuration has no ad type", ^{
            it(@"should start the refresh timer and try again later", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
                configuration.adType = MPAdTypeUnknown;
                [communicator receiveConfiguration:configuration];

                delegate should have_received(@selector(managerDidFailToLoadAd));

                [communicator resetLoadedURL];
                [fakeCoreProvider advanceMPTimers:configuration.refreshInterval];
                communicator.loadedURL should_not be_nil;
            });
        });

        context(@"when the configuration is an interstitial type", ^{
            it(@"should start the refresh timer and try again later", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
                configuration.refreshInterval = 30;
                [communicator receiveConfiguration:configuration];

                delegate should have_received(@selector(managerDidFailToLoadAd));

                [communicator resetLoadedURL];
                [fakeCoreProvider advanceMPTimers:configuration.refreshInterval];
                communicator.loadedURL should_not be_nil;
            });
        });

        context(@"when the configuration is the clear ad type", ^{
            it(@"should start the refresh timer and try again later", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:kAdTypeClear];
                [communicator receiveConfiguration:configuration];

                delegate should have_received(@selector(managerDidFailToLoadAd));

                [communicator resetLoadedURL];
                [fakeCoreProvider advanceMPTimers:configuration.refreshInterval];
                communicator.loadedURL should_not be_nil;
            });
        });

        context(@"when the configuration indicates the ad unit is warming up", ^{
            it(@"should start the refresh timer and try again later", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:@{@"X-Warmup":@"1"} HTMLString:nil];
                [communicator receiveConfiguration:configuration];

                delegate should have_received(@selector(managerDidFailToLoadAd));

                [communicator resetLoadedURL];
                [fakeCoreProvider advanceMPTimers:configuration.refreshInterval];
                communicator.loadedURL should_not be_nil;
            });
        });

        context(@"when the configuration refers to an adapter that does not exist", ^{
            it(@"should start the failover waterfall", ^{
                [manager loadAd];

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"NSFluffyMonkeyPandas"];
                [communicator receiveConfiguration:configuration];

                communicator.loadedURL should equal(configuration.failoverURL);
                delegate should_not have_received(@selector(managerDidFailToLoadAd));
            });
        });
    });

    describe(@"when asked to load a configuration that is not an banner", ^{
        beforeEach(^{
            [manager loadAd];
            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfiguration];
            [communicator receiveConfiguration:configuration];
        });

        it(@"should not load anything, and should inform the delegate that it failed", ^{
            // It should not try to fail over.
            communicator.loadedURL should be_nil;
            delegate should have_received(@selector(managerDidFailToLoadAd));
        });

        it(@"should allow a new request to load", ^{
            [manager loadAd];
            communicator.loadedURL should_not be_nil;
        });
    });
});

SPEC_END

#pragma clang diagnostic pop
