//
//  UITouch+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITouch (MPSpecs)

- (id)initInView:(UIView *)view atPoint:(CGPoint)point;
- (void)changeToPhase:(UITouchPhase)phase;
- (void)setLocationInWindow:(CGPoint)location;

@end
