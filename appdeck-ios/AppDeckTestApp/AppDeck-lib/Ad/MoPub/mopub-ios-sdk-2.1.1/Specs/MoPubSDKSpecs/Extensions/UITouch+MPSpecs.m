//
//  UITouch+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UITouch+MPSpecs.h"

@interface UITouch () {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    // ivars declarations removed in 6.0
    NSTimeInterval  _timestamp;
    UITouchPhase    _phase;
    UITouchPhase    _savedPhase;
    NSUInteger      _tapCount;
    
    UIWindow        *_window;
    UIView          *_view;
    UIView          *_warpedIntoView;
    NSMutableArray  *_gestureRecognizers;
    NSMutableArray  *_forwardingRecord;
    
    CGPoint         _locationInWindow;
    CGPoint         _previousLocationInWindow;
    UInt8           _pathIndex;
    UInt8           _pathIdentity;
    float           _pathMajorRadius;
    struct {
        unsigned int _firstTouchForView:1;
        unsigned int _isTap:1;
        unsigned int _isDelayed:1;
        unsigned int _sentTouchesEnded:1;
        unsigned int _abandonForwardingRecord:1;
    } _touchFlags;
#endif
}
@end

@implementation UITouch (MPSpecs)

- (id)initInView:(UIView *)view atPoint:(CGPoint)point
{
    self = [super init];
    if(self != nil)
    {
        CGRect frameInWindow;
        if([view isKindOfClass:[UIWindow class]])
        {
            frameInWindow = view.frame;
        }
        else
        {
            frameInWindow =
            [view.window convertRect:view.frame fromView:view.superview];
        }
        
        _tapCount = 1;
        _locationInWindow = point;
        _previousLocationInWindow = _locationInWindow;
        
        UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
        _view = [target retain];
        _window = [view.window retain];
        _phase = UITouchPhaseBegan;
        _touchFlags._firstTouchForView = 1;
        _touchFlags._isTap = 1;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

- (void)setLocationInWindow:(CGPoint)location
{
	_previousLocationInWindow = _locationInWindow;
	_locationInWindow = location;
	_timestamp = [[NSProcessInfo processInfo] systemUptime];
}

- (void)changeToPhase:(UITouchPhase)phase
{
    _phase = phase;
    _timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end
