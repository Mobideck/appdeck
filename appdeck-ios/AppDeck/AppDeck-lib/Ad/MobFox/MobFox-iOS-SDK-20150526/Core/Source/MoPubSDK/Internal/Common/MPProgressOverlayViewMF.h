//
//  MPProgressOverlayView.h
//  MoPub
//
//  Created by Andrew He on 7/18/12.
//  Copyright 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPProgressOverlayViewDelegateMF;

@interface MPProgressOverlayViewMF : UIView {
    id<MPProgressOverlayViewDelegateMF> _delegate;
    UIView *_outerContainer;
    UIView *_innerContainer;
    UIActivityIndicatorView *_activityIndicator;
    UIButton *_closeButton;
    CGPoint _closeButtonPortraitCenter;
}

@property (nonatomic, assign) id<MPProgressOverlayViewDelegateMF> delegate;
@property (nonatomic, retain) UIButton *closeButton;

- (id)initWithDelegate:(id<MPProgressOverlayViewDelegateMF>)delegate;
- (void)show;
- (void)hide;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPProgressOverlayViewDelegateMF <NSObject>

@optional
- (void)overlayCancelButtonPressed;
- (void)overlayDidAppear;

@end
