//
//  UIView+Animation.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 20/01/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIImageView+Animation.h"

@implementation UIImageView (Animation)

@dynamic animating;

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.transform = CGAffineTransformRotate(self.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
/*                             if (self.animating) {*/
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
/*                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }*/
                         }
                     }];
}

- (void) startSpin {
/*    if (!self.animating) {
        self.animating = YES;*/
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
//    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
//    self.animating = NO;
    [self stopAnimating];
    //[self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
}

@end
