#import "MPInstanceProvider.h"
#import "MPAdConfigurationFactory.h"
#import "FakeInterstitialCustomEvent.h"
#import "MPInterstitialCustomEventAdapter.h"
#import "MPReachability.h"
#import "MPBannerCustomEventAdapter.h"
#import "MPAnalyticsTracker.h"
#import "MPHTMLInterstitialViewController.h"
#import <Cedar/Cedar.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(MPInstanceProviderSpec)

describe(@"MPInstanceProvider", ^{
    __block MPInstanceProvider *provider;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        provider = [[MPInstanceProvider alloc] init];
    });

    describe(@"providing interstitial adapters", ^{
        context(@"when the configuration network type is 'custom'", ^{
            context(@"when the configuration has a custom event class", ^{
                context(@"when the class exists", ^{
                    it(@"should return an MPInterstitialCustomEventAdapter", ^{
                        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];
                        [provider buildInterstitialAdapterForConfiguration:configuration
                                                                  delegate:nil] should be_instance_of([MPInterstitialCustomEventAdapter class]);
                    });
                });

                context(@"when the class does not exist", ^{
                    it(@"should return nil", ^{
                        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"NSMonkeyToastEndocrineParadigmBean"];
                        [provider buildInterstitialAdapterForConfiguration:configuration
                                                                  delegate:nil] should be_nil;
                    });
                });
            });

            context(@"when the configuration has a custom selector name", ^{
                it(@"should return nil", ^{
                    configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"custom"];
                    configuration.customSelectorName = @"buildTheThing";
                    [provider buildInterstitialAdapterForConfiguration:configuration
                                                              delegate:nil] should be_nil;
                });
            });

            context(@"when the configuration has neither", ^{
                it(@"should return nil", ^{
                    configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"custom"];
                    [provider buildInterstitialAdapterForConfiguration:configuration
                                                              delegate:nil] should be_nil;
                });
            });
        });

        context(@"when the configuration network type is invalid", ^{
            it(@"should return nil", ^{
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"no_chance"];
                [provider buildInterstitialAdapterForConfiguration:configuration
                                                          delegate:nil] should be_nil;
            });
        });
    });

    describe(@"providing banner adapters", ^{
        context(@"when the configuration network type is 'custom'", ^{
            context(@"when the configuration has a custom event class", ^{
                context(@"when the class exists", ^{
                    it(@"should return an MPInterstitialCustomEventAdapter", ^{
                        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                        [provider buildBannerAdapterForConfiguration:configuration
                                                            delegate:nil] should be_instance_of([MPBannerCustomEventAdapter class]);
                    });
                });

                context(@"when the class does not exist", ^{
                    it(@"should return nil", ^{
                        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"NSMonkeyToastEndocrineParadigmBean"];
                        [provider buildBannerAdapterForConfiguration:configuration
                                                            delegate:nil] should be_nil;
                    });
                });
            });

            context(@"when the configuration has a custom selector name", ^{
                it(@"should return nil", ^{
                    configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:@"custom"];
                    configuration.customSelectorName = @"buildTheThing";
                    [provider buildBannerAdapterForConfiguration:configuration
                                                        delegate:nil] should be_nil;
                });
            });

            context(@"when the configuration has neither", ^{
                it(@"should return nil", ^{
                    configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"custom"];
                    [provider buildBannerAdapterForConfiguration:configuration
                                                        delegate:nil] should be_nil;
                });
            });
        });

        context(@"when the configuration network type is invalid", ^{
            it(@"should return nil", ^{
                configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:@"no_chance"];
                [provider buildBannerAdapterForConfiguration:configuration
                                                    delegate:nil] should be_nil;
            });
        });
    });

    describe(@"providing an HTML interstitial view controller", ^{
        it(@"should provide a correctly configured interstitial view controller", ^{
            id<CedarDouble, MPInterstitialViewControllerDelegate> delegate = nice_fake_for(@protocol(MPInterstitialViewControllerDelegate));
            MPHTMLInterstitialViewController *controller = [provider buildMPHTMLInterstitialViewControllerWithDelegate:delegate
                                                                                                       orientationType:MPInterstitialOrientationTypePortrait];
            controller.delegate should equal(delegate);
            controller.orientationType should equal(MPInterstitialOrientationTypePortrait);
        });
    });
});

SPEC_END
