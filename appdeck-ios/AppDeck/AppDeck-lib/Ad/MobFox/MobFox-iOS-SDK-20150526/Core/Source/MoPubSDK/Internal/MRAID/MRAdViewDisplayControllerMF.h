//
//  MRAdViewDisplayController.h
//  MoPub
//
//  Created by Andrew He on 12/22/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRAdViewMF.h"

@class MRAdViewMF, MPTimerMF, MRDimmingViewMF, MRJavaScriptEventEmitterMF;

@interface MRAdViewDisplayControllerMF : NSObject <MRAdViewDelegateMF> {
    MRAdViewMF *_view;
    MRAdViewMF *_expansionContentView;
    MRAdViewMF *_twoPartExpansionView;

    // Timer to periodically update the value of _isViewable.
    MPTimerMF *_viewabilityTimer;

    MRDimmingViewMF *_dimmingView;

    BOOL _allowsExpansion;
    MRAdViewCloseButtonStyle _closeButtonStyle;
    MRAdViewState _currentState;

    // Indicates whether any part of the ad is visible on-screen.
    BOOL _isViewable;

    // Variables for resizable ads.
    CGSize _maxSize;

    // Variables for expandable ads.
    CGRect _defaultFrame;
    CGRect _defaultFrameInKeyWindow;
    CGRect _expandedFrame;
    NSInteger _originalTag;
    NSInteger _parentTag;
    CGAffineTransform _originalTransform;
}

@property (nonatomic, assign) MRAdViewMF *view;
@property (nonatomic, readonly) MRAdViewState currentState;
@property (nonatomic, retain) MRJavaScriptEventEmitterMF *jsEventEmitter;

- (id)initWithAdView:(MRAdViewMF *)adView
     allowsExpansion:(BOOL)allowsExpansion
    closeButtonStyle:(MRAdViewCloseButtonStyle)closeButtonStyle
     jsEventEmitter:(MRJavaScriptEventEmitterMF *)jsEventEmitter;
- (void)initializeJavascriptStateWithViewProperties:(NSArray *)viewProperties;
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;
- (void)revertViewToDefaultState;
- (void)close;
- (void)expandToFrame:(CGRect)frame withURL:(NSURL *)url
       useCustomClose:(BOOL)shouldUseCustomClose isModal:(BOOL)isModal
shouldLockOrientation:(BOOL)shouldLockOrientation;
- (void)expandToFrame:(CGRect)frame withURL:(NSURL *)url blockingColor:(UIColor *)blockingColor
      blockingOpacity:(CGFloat)blockingOpacity shouldLockOrientation:(BOOL)shouldLockOrientation;
- (void)useCustomClose:(BOOL)shouldUseCustomClose;
- (void)additionalModalViewWillPresent;
- (void)additionalModalViewDidDismiss;

@end
