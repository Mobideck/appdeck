#import "MPBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPAdConfigurationFactory.h"
#import "FakeBannerCustomEvent.h"
#import "MPConstants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerAdManagerSpec)

describe(@"MPBannerAdManager", ^{
    __block MPBannerAdManager *manager;
    __block id<CedarDouble, MPBannerAdManagerDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerAdManagerDelegate));
        manager = [[[MPBannerAdManager alloc] initWithDelegate:delegate] autorelease];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
    });

    describe(@"loading requests", ^{
        it(@"should request the correct URL", ^{
            delegate stub_method("adUnitId").and_return(@"panther");
            delegate stub_method("keywords").and_return(@"liono");
            delegate stub_method("location").and_return([[[CLLocation alloc] initWithLatitude:30 longitude:20] autorelease]);
            delegate stub_method("isTesting").and_return(YES);

            [manager loadAd];

            NSString *URL = communicator.loadedURL.absoluteString;
            URL should contain(@"id=panther");
            URL should contain(@"q=liono");
            URL should contain(@"ll=30,20");
            URL should contain(@"http://testing.ads.mopub.com");
        });
    });

    describe(@"refresh timer edge cases", ^{
        context(@"when the requested ad unit loads successfully and it has a refresh interval", ^{
            it(@"should schedule the refresh timer with the given refresh interval", ^{
                [manager loadAd];

                FakeBannerCustomEvent *event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero] autorelease];
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

                FakeBannerCustomEvent *event = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectZero] autorelease];
                fakeProvider.fakeBannerCustomEvent = event;

                MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                configuration.refreshInterval = -1;
                [fakeCoreProvider.lastFakeMPAdServerCommunicator receiveConfiguration:configuration];

                int numberOfTimers = fakeCoreProvider.fakeTimers.count;

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
