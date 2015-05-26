//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRVideoPlayerManagerDelegateMF;

@interface MRVideoPlayerManagerMF : NSObject

@property (nonatomic, assign) id<MRVideoPlayerManagerDelegateMF> delegate;

- (id)initWithDelegate:(id<MRVideoPlayerManagerDelegateMF>)delegate;
- (void)playVideo:(NSURL *)url;

@end

@protocol MRVideoPlayerManagerDelegateMF <NSObject>

- (UIViewController *)viewControllerForPresentingVideoPlayer;
- (void)videoPlayerManagerWillPresentVideo:(MRVideoPlayerManagerMF *)manager;
- (void)videoPlayerManagerDidDismissVideo:(MRVideoPlayerManagerMF *)manager;
- (void)videoPlayerManager:(MRVideoPlayerManagerMF *)manager
        didFailToPlayVideoWithErrorMessage:(NSString *)message;

@end
