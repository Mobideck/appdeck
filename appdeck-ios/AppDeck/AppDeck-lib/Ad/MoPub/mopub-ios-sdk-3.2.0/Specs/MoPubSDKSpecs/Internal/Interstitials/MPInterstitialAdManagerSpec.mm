#import "MPInterstitialAdManager.h"
#import <CoreLocation/CoreLocation.h>
#import "MPAdServerURLBuilder.h"
#import "MPAdConfigurationFactory.h"
#import "MPLegacyInterstitialCustomEventAdapter.h"
#import "MPInterstitialAdManagerDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialAdManagerSpec)

describe(@"MPInterstitialAdManager", ^{
    __block MPInterstitialAdManager *manager;
    __block id<CedarDouble, MPInterstitialAdManagerDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
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

        beforeEach(^{
            location = [[CLLocation alloc] initWithLatitude:50 longitude:50];
            [manager loadInterstitialWithAdUnitID:@"1138"
                                         keywords:@"hi=2,ho=3"
                                         location:location
                                          testing:YES];
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
        });

        context(@"when the ad request fails", ^{
            beforeEach(^{
                [communicator failWithError:nil];
            });

            it(@"should notify the delegate", ^{
                delegate should have_received(@selector(manager:didFailToLoadInterstitialWithError:)).with(manager).and_with(nil);
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
                delegate should have_received(@selector(manager:didFailToLoadInterstitialWithError:)).with(manager).and_with(nil);
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

    describe(@"when notified about legacy custom event status", ^{
        context(@"when not actually managing a legacy custom event", ^{
            __block FakeInterstitialAdapter *adapter;

            beforeEach(^{
                [manager loadInterstitialWithAdUnitID:@"gimme_adapter" keywords:@"" location:nil testing:YES];
                adapter = [[FakeInterstitialAdapter alloc] init];
                fakeProvider.fakeInterstitialAdapter = adapter;

                configuration = [MPAdConfigurationFactory defaultFakeInterstitialConfiguration];
                [communicator receiveConfiguration:configuration];
            });

            it(@"should not explode", ^{
                [manager customEventDidLoadAd];
                [manager customEventDidFailToLoadAd];
                [manager customEventActionWillBegin];
            });
        });

        context(@"when actually managing a legacy custom event", ^{
            __block MPLegacyInterstitialCustomEventAdapter<CedarDouble> *adapter;

            beforeEach(^{
                adapter = nice_fake_for([MPLegacyInterstitialCustomEventAdapter class]);
                fakeProvider.fakeInterstitialAdapter = adapter;

                [manager loadInterstitialWithAdUnitID:@"gimme_adapter" keywords:@"" location:nil testing:YES];
                [communicator receiveConfiguration:configuration];
            });

            itShouldBehaveLike(@"a manager that is in the midst of loading an interstitial");

            context(@"and the custom event loaded", ^{
                beforeEach(^{
                    [manager customEventDidLoadAd];
                });

                it(@"should inform the legacy adapter", ^{
                    adapter should have_received(@selector(customEventDidLoadAd));
                });

                itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
            });

            context(@"and the custom event failed to load", ^{
                beforeEach(^{
                    [manager customEventDidFailToLoadAd];
                });

                it(@"should inform the legacy adapter", ^{
                    adapter should have_received(@selector(customEventDidFailToLoadAd));
                });

                itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
            });

            context(@"and the custom event action will begin", ^{
                it(@"should inform the legacy adapter", ^{
                    [manager customEventActionWillBegin];
                    adapter should have_received(@selector(customEventActionWillBegin));
                });
            });
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
            delegate should have_received(@selector(manager:didFailToLoadInterstitialWithError:)).with(manager).and_with(nil);
        });

        itShouldBehaveLike(@"a manager that is able to handle a new interstitial request");
    });
});

SPEC_END
