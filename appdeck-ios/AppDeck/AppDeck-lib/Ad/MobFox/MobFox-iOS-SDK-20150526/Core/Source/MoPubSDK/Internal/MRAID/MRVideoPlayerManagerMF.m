//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRVideoPlayerManagerMF.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPInstanceProviderMF.h"
#import "UIViewController+MPAdditionsMF.h"

@implementation MRVideoPlayerManagerMF

@synthesize delegate = _delegate;

- (id)initWithDelegate:(id<MRVideoPlayerManagerDelegateMF>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];

    [super dealloc];
}

- (void)playVideo:(NSURL *)url
{
    if (!url) {
        [self.delegate videoPlayerManager:self didFailToPlayVideoWithErrorMessage:@"URI was not valid."];
        return;
    }

    MPMoviePlayerViewController *controller = [[MPInstanceProviderMF sharedProvider] buildMPMoviePlayerViewControllerWithURL:url];

    [self.delegate videoPlayerManagerWillPresentVideo:self];
    [[self.delegate viewControllerForPresentingVideoPlayer] mp_presentModalViewController:controller
                                                                                 animated:MP_ANIMATED];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    [self.delegate videoPlayerManagerDidDismissVideo:self];
}

@end
