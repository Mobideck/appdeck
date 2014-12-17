//
//  UITouch+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITouch (MPSpecs)

- (id)initInView:(UIView *)view atPoint:(CGPoint)point;
- (id)initInView:(UIView *)view;
- (void)setLocationInWindow:(CGPoint)location;
- (void)changeToPhase:(UITouchPhase)phase;

@end
