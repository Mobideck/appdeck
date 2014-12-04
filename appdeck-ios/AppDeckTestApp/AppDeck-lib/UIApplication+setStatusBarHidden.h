//
//  UIApplication+setStatusBarHidden.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 25/03/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (setStatusBarHidden)

-(void)altSetStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)altSetStatusBarHidden:(BOOL)hidden;
-(void)altSetStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;

@end
