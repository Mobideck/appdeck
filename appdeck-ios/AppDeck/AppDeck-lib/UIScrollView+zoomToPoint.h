//
//  UIScrollView+zoomToPoint.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 27/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (zoomToPoint)

- (void)zoomToPoint:(CGPoint)zoomPoint withScale: (CGFloat)scale animated: (BOOL)animated;

@end
