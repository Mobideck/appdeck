//
//  UIView+SubViewsWalk.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 10/06/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIViewCallback)(UIView *view);

@interface UIView (SubViewsWalk)

-(void)subViewsWalk:(UIViewCallback)callback;

@end
