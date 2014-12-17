//
//  UINavigationBar+Progress.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 03/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UINavigationBar+Progress.h"
#import "QuartzCore/QuartzCore.h"

@implementation UINavigationBar (Progress)

-(CGRect)getProgressViewFrameWithProgress:(CGFloat)progress
{
    CGRect frame = self.bounds;
    frame.origin.y -= 20;
    frame.size.height += 20;
    frame.size.width = frame.size.width * progress;
    return frame;
}

-(UIView *)getProgressView
{
    UIView *progressView = [self viewWithTag:789];
    if (progressView == nil)
    {
        progressView = [[UIView alloc] initWithFrame:[self getProgressViewFrameWithProgress:0]];
        progressView.backgroundColor = [UIColor whiteColor];
        progressView.alpha = 0.10;
        progressView.tag = 789;
        progressView.userInteractionEnabled = NO;
        [self insertSubview:progressView atIndex:1];
    }
    return progressView;
}

-(void)progressStart:(float)expectedProgress inTime:(float)duration
{
    UIView *progressView = [self getProgressView];
    progressView.hidden = NO;
    progressView.alpha = 0.1;
    progressView.frame = [self getProgressViewFrameWithProgress:0];
    
    if (expectedProgress > 0 && duration > 0)
    {
        [UIView beginAnimations:@"UINavigationBar+Progress" context:NULL];
        [UIView setAnimationBeginsFromCurrentState:NO];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];

        //frame.origin.x = - self.frame.size.width + self.frame.size.width * expectedProgress;
        progressView.frame = [self getProgressViewFrameWithProgress:expectedProgress];
        
        [UIView commitAnimations];
    }
}

-(void)progressUpdate:(float)progress duration:(float)duration
{
    UIView *progressView = [self getProgressView];

    [UIView beginAnimations:@"UINavigationBar+Progress" context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];

    progressView.frame = [self getProgressViewFrameWithProgress:progress];
    
    [UIView commitAnimations];
}

-(void)progressEnd:(float)duration
{
    UIView *progressView = [self getProgressView];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         progressView.alpha = 0;
                         progressView.frame = [self getProgressViewFrameWithProgress:1.0];
                     }
                     completion:^(BOOL finished){
                         progressView.alpha = 0.1;
                         progressView.hidden = YES;
                         progressView.frame = [self getProgressViewFrameWithProgress:0.0];
                     }];
}


@end
