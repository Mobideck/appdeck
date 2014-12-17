//
//  UIView+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MPSpecs)

- (BOOL)mp_viewIntersectsParentWindowWithPercent:(CGFloat)percentVisible;
- (BOOL)mp_viewIsVisible;

@end
