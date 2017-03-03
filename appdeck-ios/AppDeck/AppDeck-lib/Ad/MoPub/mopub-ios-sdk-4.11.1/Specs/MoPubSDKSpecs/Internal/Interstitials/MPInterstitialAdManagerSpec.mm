#import "MPInterstitialAdManager.h"
#import <CoreLocation/CoreLocation.h>
#import "MPAdServerURLBuilder.h"
#import "MPAdConfigurationFactory.h"
#import "MPInterstitialAdManagerDelegate.h"
#import "MPLogEventRecorder.h"
#import "MPLogEvent.h"
#import "FakeMPLogEventRecorder.h"
#import "NSDate+MPSpecs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialAdManagerSpec)

describe(@"MPInterstitialAdManager", ^{
    __block MPInterstitialAdManager *manager;
    __block id<CedarDouble, MPInterstitialAdManagerDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;
    __block FakeMPLogEventRecorder *eventRecorder;

    beforeEach(^{
        eventRecorder = [[FakeMPLogEventRecorder alloc] init];
        spy_on(eventRecorder);
        fakeCoreProvider.fakeLogEventRecorder = eventRecorder;
        delegate = nice_fake_for(@protocol(MPInterstitialAdManagerDelegate));
        manager = [[MPInterstitialAdManager alloc] initWithDelegate:delegate];
        communicator = fakeCoreProvider.lastFakeMPAdServerCommunicator;
    });

    sharedExamplesFor(@"a manager that is in the midst of loading an interstitial", ^(NSDictionary *sharedContext) {
        context(@"when told to load an interstitial", ^{
            it(@"should not make a new request", ^{
                NSURL *originalURL = communicator.loadedURL;
                [manager loadInterstitialWithAdUnitID:@"ad_unit_to_load_when_your_already_loading_something" keywords:@"" location:nil testing:YES];
                if (originalURL) {
                    communicator.loadedURL should equal(originalURL);
                } else {
                    communicator.loadedURL should be_nil;
                }
            });
        });
    });

    sharedExamplesFor(@"a manager that is able to handle a new interstitial request", ^(NSDictionary *sharedContext) {
        context(@"when subsequently told to load a different interstitial", ^{
            it(@"should make a new request", ^{
                [manager loadInterstitialWithAdUnitID:@"the_next_interstitial" keywords:@"" location:nil testing:YES];
                communicator.loadedURL should equal([MPAdServerURLBuilder URLWithAdUnitID:@"the_next_interstitial" keywords:@"" location:nil testing:YES]);
            });
        });
    });

    context(@"when told to load an interstitial", ^{
        __block CLLocation *location;
        __block NSString *url;

        beforeEach(^{
            // We swizzle the date here because the URL string's value (location's age in seconds) depends on the current time. We're just making sure
            // the same date is always returned for all calls to [NSDate date] so it's easier to test URLs against one another.
            [NSDate mp_swizzleDateMethod];
            [NSDate mp_setFakeDate:[NSDate dateWithTimeIntervalSinceReferenceDate:1000]];

            location = [[CLLocation alloc] initWithLatitude:50 longitude:50];

            [NSDate mp_setFakeDate:[NSDate dateWithTimeIntervalSinceReferenceDate:2000]];
            [manager loadInterstitialWithAdUnitID:@"1138"
                                         keywords:@"hi=2,ho=3"
                                         location:location
                                          testing:YES];
            url = communicator.loadedURL.absoluteString;
        });

        afterEach(^{
            [NSDate mp_swizzleDateMethod];
        });

        it(@"should request an ad", ^{
            communicator.loadedURL should equal([MPAdServerURLBuilder URLWithAdUnitID:@"1138" keywords:@"hi=2,ho=3" location:location testing:YES]);
        });

        itShouldBehaveLike(@"a manager that is in the midst of loading an interstitial");

        context(@"when the ad request succeeds", ^{
            __block FakeInterstitialAdapter *adapter;

            beforeEach(^{
                adapter = [[FakeInterstitialAdapter alloc] init];
                fakeProvider.fakeInterstitialAdapter = adapter;

                configuration = [MPAdConfigurationFactory defaultFakeInterstitialConfiguration];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should make an appropriate adapter and ask it to fetch the ad", ^{
                adapter.configurationForLastRequest should equal(configuration);
            });

            it(@"should add an event with data from the request", ^{
                eventRecorder should_not have_received(@selector(addEvent:));
            });
        });

        context(@"when the ad request fails", ^{
            __block NSError *error;

            beforeEach(^{
                error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
                [communicator failWithError:error];
            });

            it(@"should notify the delegate", ^{
                delegate should have_received(@selector(manager:didFailToLoadInterstitialWithError:)).with(manager).and_with(error);
            });

            it(@"should log an unsuccessful latency event", ^{
                eventRecorder should_not have_received(@selector(addEvent:));
            });

            itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
        });
    });

    describe(@"various ad configuration edge cases", ^{
        beforeEach(^{
            [manager loadInterstitialWithAdUnitID:@"edge_cases" keywords:@"" location:nil testing:YES];
        });

        context(@"when the configuration's network type is 'clear'", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"clear"];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should tell its delegate that the interstitial failed", ^{
                delegate should have_received(@selector(manager:didFailToLoadInterstitialWithError:));
            });

            itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
        });

        context(@"when the configuration indicates the ad unit is warming up", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:@{@"X-Warmup":@"1"} HTMLString:nil];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should tell its delegate that the interstitial failed", ^{
                delegate should have_received(@selector(manager:didFailToLoadInterstitialWithError:));
            });

            itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
        });

        context(@"when the configuration's network type is something invalid", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"no_way"];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should try the failover URL", ^{
                communicator.loadedURL should equal(configuration.failoverURL);
            });

            itShouldBehaveLike(@"a manager that is in the midst of loading an interstitial");
        });
    });

    context(@"with an adapter installed", ^{
        __block FakeInterstitialAdapter *adapter;
        beforeEach(^{
            [manager loadInterstitialWithAdUnitID:@"gimme_adapter" keywords:@"" location:nil testing:YES];
            adapter = [[FakeInterstitialAdapter alloc] init];
            fakeProvider.fakeInterstitialAdapter = adapter;

            configuration = [MPAdConfigurationFactory defaultFakeInterstitialConfiguration];
            [communicator receiveConfiguration:configuration];
        });

        describe(@"adapter behavior", ^{
            context(@"when the adapter finishes loading", ^{
                beforeEach(^{
                    [adapter loadSuccessfully];
                });

                it(@"should tell its delegate", ^{
                    delegate should have_received(@selector(managerDidLoadInterstitial:)).with(manager);
                });

                context(@"when told to load an interstitial again", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [manager loadInterstitialWithAdUnitID:@"different_guy" keywords:@"" location:nil testing:YES];
                    });

                    it(@"should immediately tell its delegate that it did load an ad, and not try to load again", ^{
                        delegate should have_received(@selector(managerDidLoadInterstitial:)).with(manager);
                        communicator.loadedURL should be_nil;
                    });
                });
            });

            context(@"when the adapter fails to load", ^{
                __block NSError *error;

                beforeEach(^{
                    error = [NSErrorFactory genericError];
                    [adapter failToLoad];
                });

                it(@"should try the failover URL", ^{
                    communicator.loadedURL should equal(configuration.failoverURL);
                });

                itShouldBehaveLike(@"a manager that is in the midst of loading an interstitial");
            });

            context(@"when the adapter is about to present an interstitial", ^{
                it(@"should tell its delegate", ^{
                    [adapter.delegate interstitialWillAppearForAdapter:adapter];
                    delegate should have_received(@selector(managerWillPresentInterstitial:)).with(manager);
                });
            });

            context(@"when the adapter has presented an interstitial", ^{
                it(@"should tell its delegate", ^{
                    [adapter.delegate interstitialDidAppearForAdapter:adapter];
                    delegate should have_received(@selector(managerDidPresentInterstitial:)).with(manager);
                });
            });

            context(@"when the adapter is about to dismiss an interstitial", ^{
                it(@"should tell its delegate", ^{
                    [adapter.delegate interstitialWillDisappearForAdapter:adapter];
                    delegate should have_received(@selector(managerWillDismissInterstitial:)).with(manager);
                });
            });

            context(@"when the adapter has dismissed an interstitial", ^{
                beforeEach(^{
                    [adapter loadSuccessfully];
                    [adapter.delegate interstitialDidDisappearForAdapter:adapter];
                });

                it(@"should tell its delegate", ^{
                    delegate should have_received(@selector(managerDidDismissInterstitial:)).with(manager);
                });

                itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
            });

            context(@"when the adapter's interstitial has expired", ^{
                it(@"should tell its delegate", ^{
                    [adapter.delegate interstitialDidExpireForAdapter:adapter];
                    delegate should have_received(@selector(managerDidExpireInterstitial:)).with(manager);
                });
            });
        });

        context(@"when told to present an interstitial", ^{
            __block UIViewController *controller;
            beforeEach(^{
                controller = [[UIViewController alloc] init];
            });

            context(@"and the interstitial is ready to be presented", ^{
                beforeEach(^{
                    [adapter.delegate adapterDidFinishLoadingAd:adapter];
                    [manager presentInterstitialFromViewController:controller];
                });

                it(@"should tell the adapter to display the interstitial", ^{
                    adapter.presentingViewController should equal(controller);
                });
            });

            context(@"and the interstitial is not ready for prime time", ^{
                beforeEach(^{
                    [manager presentInterstitialFromViewController:controller];
                });

                it(@"should not tell the adapter to display the interstitial", ^{
                    adapter.presentingViewController should be_nil;
                });
            });
        });
    });

    describe(@"-interstitialDelegate", ^{
        it(@"should return its delegate's interstitialDelegate", ^{
            NSObject *interstitialDelegateProxy = [[NSObject alloc] init];
            delegate stub_method("interstitialDelegate").and_return(interstitialDelegateProxy);
            [manager interstitialDelegate] should equal(interstitialDelegateProxy);
        });
    });

    describe(@"when asked to load a configuration that is not an interstitial", ^{
        beforeEach(^{
            [manager loadInterstitialWithAdUnitID:@"banner_id" keywords:@"" location:nil testing:YES];
            configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
            [communicator receiveConfiguration:configuration];
        });

        it(@"should not load anything, and should inform the delegate that it failed", ^{
            // It should not try to fail over.
            communicator.loadedURL should be_nil;
            delegate should have_received(@selector(manager:didFailToLoadInterstitialWithError:));
        });

        itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
    });
});

SPEC_END
