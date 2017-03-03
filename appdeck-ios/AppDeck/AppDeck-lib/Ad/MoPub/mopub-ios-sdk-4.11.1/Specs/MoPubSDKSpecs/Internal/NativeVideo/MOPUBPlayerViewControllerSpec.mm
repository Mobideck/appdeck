#import <AVFoundation/AVFoundation.h>
#import "MOPUBPlayerViewController.h"
#import "MOPUBPlayerView.h"
#import "MOPUBAVPlayer.h"
#import "MPVideoConfig.h"
#import "MOPUBNativeVideoAdConfigValues.h"
#import "MPVASTTracking.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPVideoConfig()

@property (readwrite) NSURL *mediaURL;

@end

@interface MOPUBPlayerViewController()

@property (nonatomic) MOPUBPlayerView *playerView;
@property (nonatomic) UIButton *muteButton;

- (void)initOnVideoReady;
- (void)muteButtonTapped;
- (void)avPlayer:(MOPUBAVPlayer *)player playbackTimeDidProgress:(NSTimeInterval)currentPlaybackTime;

@end

@interface MOPUBAVPlayer()

- (void)avPlayer:(MOPUBAVPlayer *)player playbackTimeDidProgress:(NSTimeInterval)currentPlaybackTime;
- (void)avPlayerDidStall;
- (void)playbackDidFinish;

@end

@interface MOPUBPlayerView()

- (void)avPlayerTapped;

@end

SPEC_BEGIN(MOPUBPlayerViewControllerSpec)

describe(@"MOPUBPlayerViewController", ^{
    __block MOPUBPlayerViewController *controller;
    __block MOPUBAVPlayer *avPlayer;
    __block MOPUBPlayerView *playerView;
    __block id<MOPUBPlayerViewDelegate> playerViewDelegate;
    __block id<MOPUBAVPlayerDelegate, CedarDouble> avPlayerDelegate;


    beforeEach(^{
        MPVideoConfig *videoConfig = [[MPVideoConfig alloc] init];
        MOPUBNativeVideoAdConfigValues *nativeVideoAdConfig = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50 pauseVisiblePercent:25 impressionMinVisiblePercent:50 impressionVisible:2000 maxBufferingTime:2000];
        videoConfig.mediaURL = [NSURL URLWithString:@""];
        controller = [[MOPUBPlayerViewController alloc] initWithVideoConfig:videoConfig nativeVideoAdConfig:nativeVideoAdConfig logEventProperties:nil];
        controller.vastTracking = [[MPVASTTracking alloc] initWithMPVideoConfig:videoConfig videoView:controller.playerView];
        AVPlayerItem<CedarDouble> *fakePlayerItem = nice_fake_for([AVPlayerItem class]);
        avPlayerDelegate = nice_fake_for(@protocol(MOPUBAVPlayerDelegate));
        avPlayer = [[MOPUBAVPlayer alloc] initWithDelegate:avPlayerDelegate playerItem:fakePlayerItem];

        playerViewDelegate = nice_fake_for(@protocol(MOPUBPlayerViewDelegate));
        playerView = [[MOPUBPlayerView alloc] initWithFrame:CGRectZero delegate:playerViewDelegate];
    });

    context(@"Init player view controller", ^{
        it(@"should be in inline mode", ^{
            controller.displayMode should equal(MOPUBPlayerDisplayModeInline);
        });

        it(@"should have playerView", ^{
            controller.playerView should_not be_nil;
        });

        it(@"should have mediaURL", ^{
            controller.mediaURL should_not be_nil;
        });

        it(@"should have video config", ^{
            controller.nativeVideoAdConfig should_not be_nil;
        });

        it(@"should have vast config", ^{
            controller.vastTracking should_not be_nil;
        });
    });

    context(@"when the video is muted/unmuted", ^{

        it(@"Vast tracker mute event should be called", ^{
            spy_on(controller.vastTracking);
            [controller muteButtonTapped];
            controller.vastTracking should have_received(@selector(handleVideoEvent:videoTimeOffset:));
        });

        it(@"Vast tracker mute event should not be called by setting mute enabled directly", ^{
            spy_on(controller.vastTracking);
            [controller setMuted:YES];
            controller.vastTracking should_not have_received(@selector(handleVideoEvent:videoTimeOffset:));
        });

    });

    context(@"when video is loaded", ^{
        beforeEach(^{
            [controller loadAndPlayVideo];
            [controller initOnVideoReady];
        });

        it(@"should have startedLoading flag set to YES", ^{
            controller.startedLoading should equal(YES);
        });

        it(@"should not be paused", ^{
            controller.paused should be_falsy;
        });

        it(@"should be playing", ^{
            controller.playing should be_truthy;
        });
    });

    context(@"MOPUBAVPlayerDelegate", ^{
        context(@"avPlayer:playbackTimeDidProgress:", ^{
            beforeEach(^{
                [avPlayer avPlayer:avPlayer playbackTimeDidProgress:0];
                [controller avPlayer:avPlayer playbackTimeDidProgress:0];
            });

            it(@"should forward the call to avPlayer delegate responds to the method", ^{
                avPlayerDelegate should have_received(@selector(avPlayer:playbackTimeDidProgress:));
            });

            it(@"should have mute button", ^{
                controller.muteButton should_not be_nil;
            });
        });

        context(@"avPlayerDidStall", ^{
            beforeEach(^{
                [avPlayer avPlayerDidStall];
            });
            it(@"should forward the call to avPlayer delegate responds to the method", ^{
                avPlayerDelegate should have_received(@selector(avPlayerDidStall:));
            });

            it(@"should not forward the call to avPlayer again because it should only called once", ^{
                [avPlayerDelegate reset_sent_messages];
                [avPlayer avPlayerDidStall];
                avPlayerDelegate should_not have_received(@selector(avPlayerDidStall:));
            });

            it(@"should forward the call after recover from stall", ^{
                [avPlayerDelegate reset_sent_messages];
                [avPlayer avPlayer:avPlayer playbackTimeDidProgress:0];
                [avPlayer avPlayerDidStall];
                avPlayerDelegate should have_received(@selector(avPlayerDidStall:));
            });

        });

        context(@"playbackDidFinish", ^{
            beforeEach(^{
                [avPlayer playbackDidFinish];
            });
            it(@"should forward the call to avPlayer delegate responds to the method", ^{
                avPlayerDelegate should have_received(@selector(avPlayerDidFinishPlayback:));
            });
        });
    });

    context(@"MOPUBPlayerViewDelegate", ^{
        context(@"playerViewWillEnterFullscreen:", ^{
            beforeEach(^{
                [playerView avPlayerTapped];
            });
            it(@"should forward the call to avPlayer delegate responds to the method", ^{
                playerViewDelegate should have_received(@selector(playerViewWillEnterFullscreen:));
            });
        });
    });
});

SPEC_END
