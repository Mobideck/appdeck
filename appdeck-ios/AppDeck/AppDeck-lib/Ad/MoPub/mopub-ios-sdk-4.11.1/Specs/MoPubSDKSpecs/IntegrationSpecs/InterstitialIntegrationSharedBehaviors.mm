#import "InterstitialIntegrationSharedBehaviors.h"
#import "MPInterstitialAdController.h"
#import "MPAdConfigurationFactory.h"
#import <Cedar/Cedar.h>

NSString *anInterstitialThatStartsLoadingAnAdUnit = @"an interstitial that starts loading an ad unit";
NSString *anInterstitialThatHasAlreadyLoaded = @"an interstitial that has already loaded";
NSString *anInterstitialThatPreventsLoading = @"an interstitial that prevents loading";
NSString *anInterstitialThatPreventsShowing = @"an interstitial that prevents showing";
NSString *anInterstitialThatLoadsTheFailoverURL = @"an interstitial that loads the failover URL";
NSString *anInterstitialThatTimesOut = @"an interstitial that times out";
NSString *anInterstitialThatDoesNotTimeOut = @"an interstitial that does not time out";

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

void setUpInterstitialSharedContext(FakeMPAdServerCommunicator *communicator, id<MPInterstitialAdControllerDelegate, CedarDouble> delegate, MPInterstitialAdController *interstitial, NSString *adUnitId, id<FakeInterstitialAd>fakeInterstitialAd, NSURL *failoverURL) {
    [SpecHelper specHelper].sharedExampleContext[@"communicator"] = communicator;
    [SpecHelper specHelper].sharedExampleContext[@"delegate"] = delegate;
    [SpecHelper specHelper].sharedExampleContext[@"interstitial"] = interstitial;
    [SpecHelper specHelper].sharedExampleContext[@"adUnitId"] = adUnitId;
    [SpecHelper specHelper].sharedExampleContext[@"fakeInterstitialAd"] = fakeInterstitialAd;
    [SpecHelper specHelper].sharedExampleContext[@"failoverURL"] = failoverURL;
}

#define SET_UP_BLOCK_VARIABLES \
__block FakeMPAdServerCommunicator *communicator;\
__block id<MPInterstitialAdControllerDelegate, CedarDouble> delegate;\
__block MPInterstitialAdController *interstitial;\
__block NSString *adUnitId;\
__block id<FakeInterstitialAd> fakeInterstitialAd;\
__block NSURL *failoverURL;

#define INITIALIZE_BLOCK_VARIABLES \
communicator = sharedContext[@"communicator"];\
delegate = sharedContext[@"delegate"];\
interstitial = sharedContext[@"interstitial"];\
adUnitId = sharedContext[@"adUnitId"];\
fakeInterstitialAd = sharedContext[@"fakeInterstitialAd"];\
failoverURL = sharedContext[@"failoverURL"];

SHARED_EXAMPLE_GROUPS_BEGIN(InterstitialIntegrationSharedBehaviors)

sharedExamplesFor(anInterstitialThatTimesOut, ^(NSDictionary *sharedContext) {
    SET_UP_BLOCK_VARIABLES

    beforeEach(^{
        INITIALIZE_BLOCK_VARIABLES
        [communicator resetLoadedURL];
    });

    it(@"should time out", ^{
        [fakeCoreProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL];
        communicator.loadedURL should equal(failoverURL);
    });
});

sharedExamplesFor(anInterstitialThatDoesNotTimeOut, ^(NSDictionary *sharedContext) {
    SET_UP_BLOCK_VARIABLES

    beforeEach(^{
        INITIALIZE_BLOCK_VARIABLES
        [communicator resetLoadedURL];
    });

    it(@"should not time out", ^{
        [fakeCoreProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL];
        communicator.loadedURL should be_nil;
    });
});

sharedExamplesFor(anInterstitialThatStartsLoadingAnAdUnit, ^(NSDictionary *sharedContext) {
    SET_UP_BLOCK_VARIABLES

    beforeEach(^{
        INITIALIZE_BLOCK_VARIABLES

        [communicator resetLoadedURL];
        [delegate reset_sent_messages];
    });

    it(@"should start loading the ad", ^{
        [interstitial loadAd];
        communicator.loadedURL.absoluteString should contain(adUnitId);
        delegate.sent_messages should be_empty;
        interstitial.ready should equal(NO);
    });
});

sharedExamplesFor(anInterstitialThatHasAlreadyLoaded, ^(NSDictionary *sharedContext) {
    SET_UP_BLOCK_VARIABLES

    beforeEach(^{
        INITIALIZE_BLOCK_VARIABLES

        [communicator resetLoadedURL];
        [delegate reset_sent_messages];
    });

    it(@"should not load again, and tell the delegate that it has an ad already", ^{
        [interstitial loadAd];
        communicator.loadedURL.absoluteString should be_nil;
        verify_fake_received_selectors(delegate, @[@"interstitialDidLoadAd:"]);
        interstitial.ready should equal(YES);
    });
});

sharedExamplesFor(anInterstitialThatPreventsLoading, ^(NSDictionary *sharedContext) {
    SET_UP_BLOCK_VARIABLES

    beforeEach(^{
        INITIALIZE_BLOCK_VARIABLES

        [communicator resetLoadedURL];
        [delegate reset_sent_messages];
    });

    it(@"should not try to load the URL or tell the delegate anything", ^{
        [interstitial loadAd];
        communicator.loadedURL should be_nil;
        delegate.sent_messages should be_empty;
    });
});

sharedExamplesFor(anInterstitialThatPreventsShowing, ^(NSDictionary *sharedContext) {
    __block UIViewController *presentingController;
    SET_UP_BLOCK_VARIABLES

    beforeEach(^{
        presentingController = [[UIViewController alloc] init];
        INITIALIZE_BLOCK_VARIABLES

        [communicator resetLoadedURL];
        [delegate reset_sent_messages];
        [fakeCoreProvider.sharedFakeMPAnalyticsTracker reset];
    });

    it(@"should not show the interstitial, or tell the delegate anything, or log an impression", ^{
        [interstitial showFromViewController:presentingController];
        fakeInterstitialAd.presentingViewController should be_nil;
        delegate.sent_messages should be_empty;
        fakeCoreProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
    });
});

sharedExamplesFor(anInterstitialThatLoadsTheFailoverURL, ^(NSDictionary *sharedContext) {
    SET_UP_BLOCK_VARIABLES

    beforeEach(^{
        INITIALIZE_BLOCK_VARIABLES
    });

    it(@"should retry using the failover URL and should not be ready", ^{
        communicator.loadedURL should equal(failoverURL);
        interstitial.ready should equal(NO);
        delegate.sent_messages should be_empty;
    });

    context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatPreventsLoading); });
    context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });

    context(@"when the server returns the terminating (clear) configuration", ^{
        beforeEach(^{
            [delegate reset_sent_messages];

            MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"clear"];
            [communicator receiveConfiguration:configuration];
            [communicator resetLoadedURL];
        });

        it(@"should notify the delegate that the ad failed to load and should not be ready", ^{
            verify_fake_received_selectors(delegate, @[@"interstitialDidFailToLoadAd:"]);
            interstitial.ready should equal(NO);
        });

        context(@"and the user tries to load again", ^{ itShouldBehaveLike(anInterstitialThatStartsLoadingAnAdUnit); });
        context(@"and the user tries to show the ad", ^{ itShouldBehaveLike(anInterstitialThatPreventsShowing); });
    });
});

SHARED_EXAMPLE_GROUPS_END
