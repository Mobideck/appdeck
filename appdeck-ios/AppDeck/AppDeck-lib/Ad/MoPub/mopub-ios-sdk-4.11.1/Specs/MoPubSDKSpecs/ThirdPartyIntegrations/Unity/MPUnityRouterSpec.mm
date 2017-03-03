#import "MPUnityRouter.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPUnityRouter (Specs)

@property (nonatomic, assign) BOOL isAdPlaying;

@end

SPEC_BEGIN(MPUnityRouterSpec)

describe(@"MPUnityRouter", ^{
    __block MPUnityRouter *router;
    __block UnityAds *SDK;
    __block id<CedarDouble, MPUnityRouterDelegate> delegate;
    __block UIViewController *controller;

    beforeEach(^{
        router = [MPUnityRouter sharedRouter];
        SDK = [UnityAds sharedInstance];
        spy_on(SDK);
        delegate = nice_fake_for(@protocol(MPUnityRouterDelegate));
        controller = [[UIViewController alloc] init];
    });

    afterEach(^{
        router.isAdPlaying = NO;
    });

    context(@"when the Unity SDK can show an ad", ^{
        context(@"when an ad is not already playing", ^{
            beforeEach(^{
                SDK stub_method(@selector(canShow)).and_return(YES);
                SDK stub_method(@selector(canShowAds)).and_return(YES);
            });

            it(@"should attempt to play a rewarded video ad", ^{
                [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" zoneId:nil settings:nil delegate:delegate];
                SDK should have_received(@selector(show:));
            });
            xit(@"should attempt to play the rewarded video ad without a customerId", ^{});
        });

        context(@"when a rewarded video ad is already playing", ^{
            beforeEach(^{
                SDK stub_method(@selector(canShow)).and_return(YES);
                SDK stub_method(@selector(canShowAds)).and_return(YES);
                [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" zoneId:nil settings:nil delegate:delegate];
            });

            it(@"should fail to play another rewarded video", ^{
                [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" zoneId:nil settings:nil delegate:delegate];
                delegate should have_received(@selector(unityAdsDidFailWithError:));
            });
        });

        context(@"when a rewarded video ad closes", ^{
            beforeEach(^{
                SDK stub_method(@selector(canShow)).and_return(YES);
                SDK stub_method(@selector(canShowAds)).and_return(YES);
                [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" zoneId:nil settings:nil delegate:delegate];
                router.isAdPlaying should be_truthy;
            });

            it(@"should set isAdPlaying to NO and allow another ad to play", ^{
                [router unityAdsVideoCompleted:@"reward" skipped:NO];
                [router unityAdsDidHide];
                router.isAdPlaying should be_falsy;
                [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" zoneId:nil settings:nil delegate:delegate];
                router.isAdPlaying should be_truthy;
            });

            it(@"should notify delegate that a reward was granted", ^{
                [router unityAdsVideoCompleted:@"reward" skipped:NO];
                [router unityAdsDidHide];
                delegate should have_received(@selector(unityAdsDidHide));
                delegate should have_received(@selector(unityAdsVideoCompleted:skipped:)).with(@"reward").and_with(NO);
            });

        });
    });

    context(@"when an ad is not available from the Unity SDK", ^{
        beforeEach(^{
            SDK stub_method(@selector(canShow)).and_return(NO);
            router.isAdPlaying = NO;
        });

        it(@"should not play a rewarded video ad", ^{
            [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" zoneId:nil settings:nil delegate:delegate];
            delegate should have_received(@selector(unityAdsDidFailWithError:));
        });
    });
});

SPEC_END
