//
//  UIView+Animation.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 20/01/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Animation)

@property (assign) BOOL animating;

- (void) startSpin;
- (void) stopSpin;

@end
