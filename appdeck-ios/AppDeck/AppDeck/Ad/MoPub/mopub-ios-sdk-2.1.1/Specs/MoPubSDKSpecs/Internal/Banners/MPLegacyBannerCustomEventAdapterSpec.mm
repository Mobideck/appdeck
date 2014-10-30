#import "MPLegacyBannerCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol BobTheBuilderProtocol <NSObject>
- (void)buildGuy:(MPInterstitialAdController *)controller;
@end

@protocol VerilyBobTheBuilderProtocol <BobTheBuilderProtocol>
- (void)buildGuy;
@end


SPEC_BEGIN(MPLegacyBannerCustomEventAdapterSpec)

describe(@"MPLegacyBannerCustomEventAdapter", ^{
    __block MPLegacyBannerCustomEventAdapter *adapter;
    __block id<CedarDouble, MPBannerAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerAdapterDelegate));
        adapter = [[MPLegacyBannerCustomEventAdapter alloc] initWithDelegate:delegate];
        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
        configuration.customEventClass = nil;
        configuration.customSelectorName = @"buildGuy";
    });

    context(@"when asked to get an ad for a configuration", ^{
        context(@"when the banner delegate implements the zero-argument selector", ^{
            __block id<CedarDouble, VerilyBobTheBuilderProtocol> bob;
            beforeEach(^{
                bob = nice_fake_for(@protocol(VerilyBobTheBuilderProtocol));
                delegate stub_method("bannerDelegate").and_return(bob);
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should perform the selector on the interstitial delegate", ^{
                bob should have_received(@selector(buildGuy));
            });
        });

        context(@"when the banner delegate implements the one-argument selector", ^{
            __block id<CedarDouble, BobTheBuilderProtocol> bob;
            beforeEach(^{
                bob = nice_fake_for(@protocol(BobTheBuilderProtocol));
                delegate stub_method("bannerDelegate").and_return(bob);
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should perform the selector on the interstitial delegate", ^{
                NSObject *adViewProxy = [[[NSObject alloc] init] autorelease];
                delegate stub_method("banner").and_return(adViewProxy);

                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];

                bob should have_received(@selector(buildGuy:)).with(adViewProxy);
            });
        });

        context(@"when the banner delegate does not implement the selector", ^{
            beforeEach(^{
                NSObject *cake = [[[NSObject alloc] init] autorelease];

                delegate stub_method("bannerDelegate").and_return(cake);
                [adapter _getAdWithConfiguration:configuration containerSize:CGSizeZero];
            });

            it(@"should tell the delegate that it failed", ^{
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
            });
        });
    });
});

SPEC_END
