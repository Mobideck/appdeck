#import "MRVideoPlayerManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRVideoPlayerManagerSpec)

describe(@"MRVideoPlayerManager", ^{
    __block MRVideoPlayerManager *manager;
    __block id<MRVideoPlayerManagerDelegate, CedarDouble> delegate;
    __block UIViewController *presentingViewController;
    __block MPMoviePlayerViewController *moviePlayerViewController;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MRVideoPlayerManagerDelegate));

        presentingViewController = [[UIViewController alloc] init];
        delegate stub_method("viewControllerForPresentingVideoPlayer").and_return(presentingViewController);

        moviePlayerViewController = nice_fake_for([MPMoviePlayerViewController class]);
        fakeProvider.fakeMoviePlayerViewController = moviePlayerViewController;

        manager = [[MRVideoPlayerManager alloc] initWithDelegate:delegate];
    });

    describe(@"-playVideo:", ^{
        context(@"if the provided URL is a valid video", ^{
            beforeEach(^{
                [manager playVideo:[NSURL URLWithString:@"http://shapeshed.com/examples/HTML5-video-element/video/320x240.m4v"]];
            });

            it(@"should inform the delegate that it will present a video player", ^{
                delegate should have_received(@selector(videoPlayerManagerWillPresentVideo:)).with(manager);
            });

            it(@"should present a video player", ^{
                presentingViewController.presentedViewController should be_same_instance_as(moviePlayerViewController);
            });

            context(@"when the video finishes playing", ^{
                beforeEach(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
                });

                it(@"should inform the delegate that it dismissed the video player", ^{
                    delegate should have_received(@selector(videoPlayerManagerDidDismissVideo:)).with(manager);
                });

                context(@"when playing the video again and dismissing", ^{
                    xit(@"should only tell the delegate once", ^{
                    });
                });
            });
        });

        context(@"if the provided URL is nil", ^{
            beforeEach(^{
                [manager playVideo:nil];
            });

            it(@"should inform the delegate that an error occurred", ^{
                delegate should have_received(@selector(videoPlayerManager:didFailToPlayVideoWithErrorMessage:)).with(manager).and_with(Arguments::anything);
            });
        });
    });
});

SPEC_END
