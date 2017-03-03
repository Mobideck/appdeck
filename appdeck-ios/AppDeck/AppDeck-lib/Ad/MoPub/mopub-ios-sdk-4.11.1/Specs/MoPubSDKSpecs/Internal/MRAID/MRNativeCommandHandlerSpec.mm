#import "MRNativeCommandHandler+Specs.h"
#import "MRVideoPlayerManager.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRNativeCommandHandlerSpec)

describe(@"MRNativeCommandHandler", ^{
    __block MRNativeCommandHandler *handler;
    __block id <CedarDouble, MRNativeCommandHandlerDelegate> delegate;
    __block MRVideoPlayerManager<CedarDouble> *videoPlayerManager;
    __block UIViewController *presentingViewController;
    __block NSString *mraidCommand;
    __block NSDictionary *mraidProperties;
    beforeEach(^{
        videoPlayerManager = nice_fake_for([MRVideoPlayerManager class]);
        fakeProvider.fakeMRVideoPlayerManager = videoPlayerManager;

        presentingViewController = [[UIViewController alloc] init];

        delegate = nice_fake_for(@protocol(MRNativeCommandHandlerDelegate));
        delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingViewController);

        handler = [[MPInstanceProvider sharedProvider] buildMRNativeCommandHandlerWithDelegate:delegate];
    });

    context(@"when the command is 'playVideo'", ^{
        beforeEach(^{
            delegate stub_method(@selector(userInteractedWithWebView)).and_return(YES);
            delegate stub_method(@selector(handlingWebviewRequests)).and_return(YES);
            mraidCommand = @"playVideo";
            mraidProperties = @{@"uri" : @"a_video"};
            [handler handleNativeCommand:mraidCommand withProperties:mraidProperties];
        });

        it(@"should tell its video manager to play the video", ^{
            videoPlayerManager should have_received(@selector(playVideo:)).with([NSURL URLWithString:@"a_video"]);
        });

        context(@"when the video is about to appear on-screen", ^{
            beforeEach(^{
                [handler videoPlayerManagerWillPresentVideo:videoPlayerManager];
            });

            it(@"should tell its delegate that modal content will be presented", ^{
                delegate should have_received(@selector(nativeCommandWillPresentModalView));
            });

            it(@"should present the video player from the proper view controller", ^{
                UIViewController *viewController = [handler viewControllerForPresentingVideoPlayer];
                viewController should_not be_nil;
                viewController should be_same_instance_as(presentingViewController);
            });

            context(@"when the video has finished playing", ^{
                it(@"should tell its delegate that modal content has been dismissed", ^{
                    [handler videoPlayerManagerDidDismissVideo:videoPlayerManager];
                    delegate should have_received(@selector(nativeCommandDidDismissModalView));
                });
            });
        });
    });

    context(@"when the command is 'playVideo' from an interstitial", ^{
        beforeEach(^{
            delegate stub_method(@selector(adViewPlacementType)).and_return((NSUInteger)MRAdViewPlacementTypeInterstitial);
            delegate stub_method(@selector(handlingWebviewRequests)).and_return(YES);
        });

        context(@"when the user did not click the webview", ^{
            beforeEach(^{
                delegate stub_method(@selector(userInteractedWithWebView)).and_return(NO);
            });

            it(@"should tell its video manager to play the video", ^{
                mraidCommand = @"playVideo";
                mraidProperties = @{@"uri" : @"a_video"};
                [handler handleNativeCommand:mraidCommand withProperties:mraidProperties];

                videoPlayerManager should have_received(@selector(playVideo:));
            });
        });

        context(@"when the user did click the webview", ^{
            beforeEach(^{
                delegate stub_method(@selector(userInteractedWithWebView)).and_return(YES);
            });

            it(@"should tell its video manager to play the video", ^{
                mraidCommand = @"playVideo";
                mraidProperties = @{@"uri" : @"a_video"};
                [handler handleNativeCommand:mraidCommand withProperties:mraidProperties];
                videoPlayerManager should have_received(@selector(playVideo:));
            });
        });
    });

    context(@"when the command is 'playVideo' and the user did not tap the banner webview and we are handling webview requests", ^{
        it(@"should NOT tell its video manager to play the video", ^{
            delegate stub_method(@selector(userInteractedWithWebView)).and_return(NO);
            delegate stub_method(@selector(handlingWebviewRequests)).and_return(YES);
            mraidCommand = @"playVideo";
            mraidProperties = @{@"uri" : @"a_video"};
            [handler handleNativeCommand:mraidCommand withProperties:mraidProperties];
            videoPlayerManager should_not have_received(@selector(playVideo:));
        });
    });

    context(@"when the command is 'playVideo' and the user did tap the banner webview and we aren't handling webview requests", ^{
        it(@"should NOT tell its video manager to play the video", ^{
            delegate stub_method(@selector(userInteractedWithWebView)).and_return(YES);
            delegate stub_method(@selector(handlingWebviewRequests)).and_return(NO);
            mraidCommand = @"playVideo";
            mraidProperties = @{@"uri" : @"a_video"};
            [handler handleNativeCommand:mraidCommand withProperties:mraidProperties];
            videoPlayerManager should_not have_received(@selector(playVideo:));
        });
    });
});

SPEC_END
